import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';
import 'package:playing_tracker/features/auth/domain/models/student_model.dart';
import 'package:playing_tracker/features/auth/domain/models/teacher_model.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Implementación concreta del [AuthRepository] usando Firebase Auth + Firestore.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance {
    _teachersRef = _firestore.collection('teachers');
    _studentsRef = _firestore.collection('students');
  }

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _teachersRef;
  late final CollectionReference<Map<String, dynamic>> _studentsRef;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<UserRole> getUserRole(String userId) async {
    try {
      // Intentar obtener el rol directamente desde los Custom Claims del token
      // (disponible tras el registro o tras una reauthenticación con refresco forzado).
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        final tokenResult = await currentUser.getIdTokenResult();
        final role = tokenResult.claims?['role'] as String?;
        if (role == 'teacher') return UserRole.teacher;
        if (role == 'student') return UserRole.student;
      }

      // Fallback a Firestore si el claim aún no está disponible
      // (ventana de tiempo entre creación del perfil y la ejecución de la Function).
      final teacherDoc = await _teachersRef.doc(userId).get();
      if (teacherDoc.exists) {
        // Aumentamos los reintentos y el tiempo de espera ya que las Functions
        // pueden tardar varios segundos en ejecutarse en entornos de producción.
        for (var i = 0; i < 5; i++) {
          final tokenResult = await _firebaseAuth.currentUser?.getIdTokenResult(
            true, // Forzar refresco
          );
          final role = tokenResult?.claims?['role'] as String?;
          if (role == 'teacher') return UserRole.teacher;
          // Esperar un poco antes del siguiente reintento (1s, 2s, 3s, 4s, 5s)
          await Future.delayed(Duration(seconds: i + 1));
        }
        return UserRole.teacher;
      }

      final studentDoc = await _studentsRef.doc(userId).get();
      if (studentDoc.exists) {
        for (var i = 0; i < 5; i++) {
          final tokenResult = await _firebaseAuth.currentUser?.getIdTokenResult(
            true,
          );
          final role = tokenResult?.claims?['role'] as String?;
          if (role == 'student') return UserRole.student;
          await Future.delayed(Duration(seconds: i + 1));
        }
        return UserRole.student;
      }

      throw AuthRepositoryException('Usuario no encontrado.');
    } catch (error) {
      if (error is AuthRepositoryException) {
        rethrow;
      }
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<TeacherModel?> getTeacherProfile(String userId) async {
    try {
      final snapshot = await _teachersRef.doc(userId).get();
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return TeacherModel.fromJson(data);
    } catch (error) {
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<StudentModel?> getStudentProfile(String userId) async {
    try {
      final snapshot = await _studentsRef.doc(userId).get();
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return StudentModel.fromJson(data);
    } catch (error) {
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> createTeacher({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final now = Timestamp.now();
      final teacher = TeacherModel(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );
      await _teachersRef.doc(userId).set(teacher.toJson());

      // Ya no forzamos el refresco aquí, ya que getUserRole() se encargará
      // de poll-ear y refrescar hasta que el claim esté listo.
      // await _firebaseAuth.currentUser?.getIdTokenResult(true);
    } catch (error) {
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> createStudent({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final now = Timestamp.now();
      final student = StudentModel(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        createdAt: now,
        updatedAt: now,
        isActive: true,
        totalSessionsCount: 0,
        totalDurationLogged: 0,
        lastSessionDate: null,
      );
      await _studentsRef.doc(userId).set(student.toJson());

      // await _firebaseAuth.currentUser?.getIdTokenResult(true);
    } catch (error) {
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (error) {
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final now = Timestamp.now();
      final updateData = {
        'firstName': firstName,
        'lastName': lastName,
        'updatedAt': now,
      };

      // Intentar actualizar en teachers
      final teacherDoc = await _teachersRef.doc(userId).get();
      if (teacherDoc.exists) {
        await _teachersRef.doc(userId).update(updateData);
        return;
      }

      // Si no es teacher, actualizar en students
      final studentDoc = await _studentsRef.doc(userId).get();
      if (studentDoc.exists) {
        await _studentsRef.doc(userId).update(updateData);
        return;
      }

      throw AuthRepositoryException('Usuario no encontrado.');
    } catch (error) {
      if (error is AuthRepositoryException) {
        rethrow;
      }
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (error) {
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }
}

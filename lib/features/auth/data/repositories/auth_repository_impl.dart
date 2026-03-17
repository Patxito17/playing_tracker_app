import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInException, GoogleSignInExceptionCode;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
  Future<UserCredential> signInWithGoogle() async {
    try {
      // google_sign_in v7: usa el singleton y authenticate().
      // initialize() se llama una sola vez en main.dart.

      // Lanza el selector de cuenta del sistema.
      // Si el usuario cancela, lanza GoogleSignInException con
      // code == GoogleSignInExceptionCode.canceled.
      final googleUser = await GoogleSignIn.instance.authenticate();

      // En v7, authentication es un getter síncrono.
      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw AuthRepositoryException(
          'No se pudo obtener el token de Google. Intenta de nuevo.',
        );
      }

      // Crear la credencial de Firebase con el idToken.
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // Autenticarse en Firebase.
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Verificar si el usuario ya tiene perfil en Firestore.
      final uid = userCredential.user!.uid;
      final teacherDoc = await _teachersRef.doc(uid).get();
      final studentDoc = await _studentsRef.doc(uid).get();

      if (!teacherDoc.exists && !studentDoc.exists) {
        // Usuario nuevo: autenticado en Firebase pero sin perfil.
        // ProfileNotFoundException indica al Cubit que redirija a
        // CompleteProfileScreen.
        throw ProfileNotFoundException();
      }

      return userCredential;
    } on GoogleSignInException catch (e) {
      // Cancelación o interrupción por el usuario: no es un error grave.
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw AuthRepositoryException('googleSignInCanceled');
      }
      throw AuthRepositoryException(e.description ?? e.toString());
    } on ProfileNotFoundException {
      rethrow;
    } on AuthRepositoryException {
      rethrow;
    } catch (error) {
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Verificar si el usuario ya tiene perfil en Firestore.
      final uid = userCredential.user!.uid;
      final teacherDoc = await _teachersRef.doc(uid).get();
      final studentDoc = await _studentsRef.doc(uid).get();

      if (!teacherDoc.exists && !studentDoc.exists) {
        throw ProfileNotFoundException();
      }

      return userCredential;
    } on ProfileNotFoundException {
      rethrow;
    } on AuthRepositoryException {
      rethrow;
    } catch (error) {
      if (error.toString().contains(
            'SignInWithAppleAuthorizationError.canceled',
          ) ||
          error.toString().contains('canceled')) {
        throw AuthRepositoryException('appleSignInCanceled');
      }
      throw AuthRepositoryException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> completeSocialTeacherProfile({
    required String firstName,
    required String lastName,
    String? acceptedTermsVersion,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthRepositoryException(
        'No hay usuario autenticado para completar el perfil.',
      );
    }
    await createTeacher(
      userId: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: user.email ?? '',
      acceptedTermsVersion: acceptedTermsVersion,
    );
  }

  @override
  Future<void> completeSocialStudentProfile({
    required String firstName,
    required String lastName,
    String? acceptedTermsVersion,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthRepositoryException(
        'No hay usuario autenticado para completar el perfil.',
      );
    }
    await createStudent(
      userId: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: user.email ?? '',
      acceptedTermsVersion: acceptedTermsVersion,
    );
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
      const maxRetries = 3;
      const retryDelay = Duration(seconds: 2);

      final teacherDoc = await _teachersRef.doc(userId).get();
      if (teacherDoc.exists) {
        for (var i = 0; i < maxRetries; i++) {
          final tokenResult = await _firebaseAuth.currentUser?.getIdTokenResult(
            true, // Forzar refresco
          );
          final role = tokenResult?.claims?['role'] as String?;
          if (role == 'teacher') return UserRole.teacher;
          await Future.delayed(retryDelay);
        }
        return UserRole.teacher;
      }

      final studentDoc = await _studentsRef.doc(userId).get();
      if (studentDoc.exists) {
        for (var i = 0; i < maxRetries; i++) {
          final tokenResult = await _firebaseAuth.currentUser?.getIdTokenResult(
            true,
          );
          final role = tokenResult?.claims?['role'] as String?;
          if (role == 'student') return UserRole.student;
          await Future.delayed(retryDelay);
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
    String? acceptedTermsVersion,
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
        acceptedTermsVersion: acceptedTermsVersion,
        acceptedTermsAt: acceptedTermsVersion != null ? now : null,
      );
      await _teachersRef.doc(userId).set(teacher.toJson());
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
    String? acceptedTermsVersion,
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
        acceptedTermsVersion: acceptedTermsVersion,
        acceptedTermsAt: acceptedTermsVersion != null ? now : null,
      );
      await _studentsRef.doc(userId).set(student.toJson());
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

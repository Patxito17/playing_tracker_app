import 'package:firebase_auth/firebase_auth.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';

/// Contrato que abstrae las operaciones de autenticación y perfil de usuario.
abstract class AuthRepository {
  /// Usuario actual autenticado en Firebase (puede ser null).
  User? get currentUser;

  /// Stream que emite cambios en la sesión de Firebase Auth.
  Stream<User?> get authStateChanges;

  /// Inicia sesión con email y contraseña.
  Future<UserCredential> signInWithEmail(String email, String password);

  /// Registra un usuario con email y contraseña.
  Future<UserCredential> registerWithEmail(String email, String password);

  /// Obtiene el rol (`teacher` o `student`) de un usuario dado su UID.
  Future<UserRole> getUserRole(String userId);

  /// Crea el documento del docente en Firestore.
  Future<void> createTeacher({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
  });

  /// Crea el documento del alumno en Firestore.
  Future<void> createStudent({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
  });

  /// Envía un email para restablecer la contraseña del usuario.
  Future<void> sendPasswordResetEmail(String email);

  /// Cierra la sesión actual.
  Future<void> signOut();
}

/// Excepción estándar del repositorio de autenticación.
class AuthRepositoryException implements Exception {
  AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'AuthRepositoryException: $message';
}

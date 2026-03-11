import 'package:firebase_auth/firebase_auth.dart';

/// Utilidad para traducir errores de Firebase a mensajes en español
/// alineados con las guías del proyecto.
class FirebaseErrorMapper {
  const FirebaseErrorMapper._();

  /// Retorna una clave de traducción para el error.
  static String map(Object error) {
    if (error is FirebaseAuthException) {
      return _mapAuthError(error);
    }
    if (error is FirebaseException) {
      return _mapGenericFirebaseError(error);
    }
    if (error is FirebaseErrorMapperException) {
      return error.message;
    }
    return 'errorGeneric';
  }

  static String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'emailInvalidFormat';
      case 'user-disabled':
        return 'errorGeneric'; // O uno específico si existe
      case 'user-not-found':
      case 'wrong-password':
        return 'emailInvalidFormat'; // O 'auth/wrong-password'
      case 'email-already-in-use':
        return 'errorGeneric';
      case 'weak-password':
        return 'passwordMinLength';
      case 'too-many-requests':
        return 'errorGeneric';
      default:
        return 'errorGeneric';
    }
  }

  static String _mapGenericFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'errorPermissionDenied';
      case 'failed-precondition':
        return 'errorFailedPrecondition';
      case 'unavailable':
        return 'errorServiceUnavailable';
      default:
        return 'errorGeneric';
    }
  }
}

/// Excepción interna para mantener consistencia en los mensajes.
class FirebaseErrorMapperException implements Exception {
  FirebaseErrorMapperException(this.message);

  final String message;

  @override
  String toString() => 'FirebaseErrorMapperException: $message';
}

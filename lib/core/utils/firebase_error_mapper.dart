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
    if (error is String) {
      return error; // Probablemente ya es una clave l10n
    }
    return 'errorGeneric';
  }

  /// Mapea códigos de [FirebaseAuthException] a claves de localización.
  static String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'authErrorInvalidEmail';
      case 'user-disabled':
        return 'authErrorUserDisabled';
      case 'user-not-found':
        return 'authErrorUserNotFound';
      case 'wrong-password':
        return 'authErrorWrongPassword';
      case 'email-already-in-use':
        return 'authErrorEmailAlreadyInUse';
      case 'weak-password':
        return 'authErrorWeakPassword';
      case 'too-many-requests':
        return 'authErrorTooManyRequests';
      case 'operation-not-allowed':
        return 'authErrorOperationNotAllowed';
      case 'invalid-credential':
        return 'authErrorInvalidCredential';
      case 'network-request-failed':
        return 'errorNetworkRequestFailed';
      default:
        return 'errorGeneric';
    }
  }

  /// Mapea códigos de [FirebaseException] genérica (Firestore, Storage, etc.)
  /// a claves de localización.
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

/// Excepción interna que envuelve un mensaje ya mapeado desde un error de Firebase.
///
/// Usada por los servicios de datos para propagar el mensaje a la capa de
/// repositorio, donde se convierte en la excepción de dominio correspondiente.
class FirebaseErrorMapperException implements Exception {
  FirebaseErrorMapperException(this.message);

  /// Mensaje pre-mapeado (clave l10n o descripción en español).
  final String message;

  @override
  String toString() => 'FirebaseErrorMapperException: $message';
}

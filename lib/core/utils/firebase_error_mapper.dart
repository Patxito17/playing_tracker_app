import 'package:firebase_auth/firebase_auth.dart';

/// Utilidad para traducir errores de Firebase a mensajes en español
/// alineados con las guías del proyecto.
class FirebaseErrorMapper {
  const FirebaseErrorMapper._();

  /// Retorna un mensaje amigable para el usuario final.
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
    return 'Ocurrió un error inesperado. Intenta nuevamente.';
  }

  static String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo electrónico no tiene un formato válido.';
      case 'user-disabled':
        return 'La cuenta fue deshabilitada. Contacta al administrador.';
      case 'user-not-found':
      case 'wrong-password':
        return 'Email o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'too-many-requests':
        return 'Has realizado demasiados intentos. Intenta más tarde.';
      default:
        return 'No fue posible completar la autenticación. Intenta nuevamente.';
    }
  }

  static String _mapGenericFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'No tienes permisos para realizar esta acción.';
      case 'unavailable':
        return 'El servicio no está disponible temporalmente.';
      default:
        return 'Ocurrió un error al comunicarse con el servidor.';
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

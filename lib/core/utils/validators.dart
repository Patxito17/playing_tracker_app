/// Validadores de formularios para la aplicación Playing Tracker
///
/// Proporciona funciones de validación reutilizables para campos de
/// formularios con mensajes de error en español.
///
/// Sprint 0 - Fase 1: Archivo placeholder
/// TODO(Sprint 0 - Fase 5): Implementar validadores para login y registro
library;

class Validators {
  /// Valida que un campo no esté vacío
  ///
  /// Retorna un mensaje de error si el campo está vacío, null si es válido
  /// TODO: Implementar
  static String? required(String? value, String fieldName) {
    // if (value == null || value.trim().isEmpty) {
    //   return '$fieldName es requerido';
    // }
    // return null;
    return null;
  }

  /// Valida formato de email
  ///
  /// Retorna un mensaje de error si el email no es válido, null si es válido
  /// TODO: Implementar con RegExp
  static String? email(String? value) {
    // if (value == null || value.isEmpty) {
    //   return 'El email es requerido';
    // }
    // final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    // if (!emailRegex.hasMatch(value)) {
    //   return 'El formato del email no es válido';
    // }
    // return null;
    return null;
  }

  /// Valida longitud mínima de contraseña
  ///
  /// Retorna un mensaje de error si la contraseña es muy corta, null si es válida
  /// TODO: Implementar con longitud mínima de 6 caracteres
  static String? password(String? value) {
    // if (value == null || value.isEmpty) {
    //   return 'La contraseña es requerida';
    // }
    // if (value.length < 6) {
    //   return 'La contraseña debe tener al menos 6 caracteres';
    // }
    // return null;
    return null;
  }

  /// Valida que un nombre contenga solo letras y espacios
  ///
  /// Retorna un mensaje de error si contiene caracteres inválidos, null si es válido
  /// TODO: Implementar con RegExp
  static String? name(String? value, String fieldName) {
    // if (value == null || value.trim().isEmpty) {
    //   return '$fieldName es requerido';
    // }
    // if (value.trim().length < 3) {
    //   return '$fieldName debe tener al menos 3 caracteres';
    // }
    // final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    // if (!nameRegex.hasMatch(value)) {
    //   return '$fieldName solo puede contener letras y espacios';
    // }
    // return null;
    return null;
  }
}

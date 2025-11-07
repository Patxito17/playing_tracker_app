/// Validadores de formularios para la aplicación Playing Tracker
///
/// Proporciona funciones de validación reutilizables para campos de
/// formularios con mensajes de error en español.
///
/// Sprint 0 - Fase 5: Validadores implementados para pantallas de autenticación
library;

import '../constants/app_strings.dart';

/// Clase con métodos estáticos para validación de formularios
class Validators {
  /// Valida que un campo no esté vacío
  ///
  /// [value] Valor a validar
  /// [fieldName] Nombre del campo para el mensaje de error
  /// Retorna un mensaje de error si el campo está vacío, null si es válido
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationStrings.required(fieldName);
    }
    return null;
  }

  /// Valida formato de email
  ///
  /// [value] Email a validar
  /// Retorna un mensaje de error si el email no es válido, null si es válido
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationStrings.emailRequired;
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return ValidationStrings.emailInvalidFormat;
    }
    return null;
  }

  /// Valida longitud mínima de contraseña
  ///
  /// [value] Contraseña a validar
  /// Retorna un mensaje de error si la contraseña es muy corta, null si es válida
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationStrings.passwordRequired;
    }
    if (value.length < 6) {
      return ValidationStrings.passwordMinLength;
    }
    return null;
  }

  /// Valida que un nombre contenga solo letras y espacios
  ///
  /// [value] Nombre a validar
  /// [fieldName] Nombre del campo para el mensaje de error
  /// Retorna un mensaje de error si contiene caracteres inválidos, null si es válido
  static String? name(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationStrings.nameRequired(fieldName);
    }
    if (value.trim().length < 3) {
      return ValidationStrings.nameMinLength(fieldName);
    }
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return ValidationStrings.nameInvalidCharacters(fieldName);
    }
    return null;
  }

  /// Valida que dos contraseñas coincidan
  ///
  /// [password] Contraseña original
  /// [confirmPassword] Contraseña de confirmación
  /// Retorna un mensaje de error si no coinciden, null si coinciden
  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return ValidationStrings.confirmPasswordRequired;
    }
    if (password != confirmPassword) {
      return ValidationStrings.passwordsDoNotMatch;
    }
    return null;
  }
}

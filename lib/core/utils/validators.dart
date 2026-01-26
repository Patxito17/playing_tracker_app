/// Validadores de formularios para la aplicación Playing Tracker
///
/// Proporciona funciones de validación reutilizables para campos de
/// formularios. Los mensajes deben ser pasados desde el UI para soporte l10n.
class Validators {
  /// Valida que un campo no esté vacío
  ///
  /// [value] Valor a validar
  /// [errorMsg] Mensaje de error a mostrar si falla
  /// Retorna [errorMsg] si el campo está vacío, null si es válido
  static String? required(String? value, String errorMsg) {
    if (value == null || value.trim().isEmpty) {
      return errorMsg;
    }
    return null;
  }

  /// Valida formato de email
  ///
  /// [value] Email a validar
  /// [requiredMsg] Mensaje si está vacío
  /// [invalidMsg] Mensaje si el formato es inválido
  static String? email(
    String? value, {
    String? requiredMsg,
    String? invalidMsg,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg;
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return invalidMsg;
    }
    return null;
  }

  /// Valida longitud mínima de contraseña
  ///
  /// [value] Contraseña a validar
  /// [requiredMsg] Mensaje si está vacío
  /// [minLengthMsg] Mensaje si es muy corta
  static String? password(
    String? value, {
    String? requiredMsg,
    String? minLengthMsg,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMsg;
    }
    if (value.length < 6) {
      return minLengthMsg;
    }
    return null;
  }

  /// Valida formato de nombre
  ///
  /// [value] Nombre a validar
  /// [requiredMsg] Mensaje si está vacío
  /// [minLengthMsg] Mensaje si es muy corto
  /// [invalidCharactersMsg] Mensaje si contiene caracteres inválidos
  static String? name(
    String? value, {
    String? requiredMsg,
    String? minLengthMsg,
    String? invalidCharactersMsg,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg;
    }
    if (value.trim().length < 3) {
      return minLengthMsg;
    }
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return invalidCharactersMsg;
    }
    return null;
  }

  /// Valida que dos contraseñas coincidan
  ///
  /// [password] Contraseña original
  /// [confirmPassword] Contraseña de confirmación
  /// [requiredMsg] Mensaje si la confirmación está vacía
  /// [matchMsg] Mensaje si no coinciden
  static String? confirmPassword(
    String? password,
    String? confirmPassword, {
    String? requiredMsg,
    String? matchMsg,
  }) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return requiredMsg;
    }
    if (password != confirmPassword) {
      return matchMsg;
    }
    return null;
  }
}

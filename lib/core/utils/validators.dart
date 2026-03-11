/// Validadores de formularios para la aplicación Playing Tracker
///
/// Proporciona funciones de validación reutilizables para campos de
/// formularios. Los mensajes deben ser pasados desde el UI para soporte l10n.
///
/// **Límites de longitud** (espejo de Firestore Rules para integridad defensiva):
/// - Nombres de persona: 2–60 caracteres
/// - Títulos (clases, tareas): 3–100 caracteres
/// - Email: hasta 100 caracteres
/// - Contraseña: mínimo 6 caracteres
class Validators {
  // Límites máximos que espejean las reglas de Firestore
  static const int _maxNameLength = 60;
  static const int _maxEmailLength = 100;
  static const int _maxTitleLength = 100;

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
    if (value.trim().length > _maxEmailLength) {
      return invalidMsg;
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

  /// Valida formato de nombre de persona (firstName, lastName).
  ///
  /// Aplica sanitización mínima: trim y colapso de espacios múltiples.
  /// No altera el contenido más allá de lo estrictamente necesario.
  ///
  /// [value] Nombre a validar
  /// [requiredMsg] Mensaje si está vacío
  /// [minLengthMsg] Mensaje si es muy corto
  /// [maxLengthMsg] Mensaje si supera el límite máximo
  /// [invalidCharactersMsg] Mensaje si contiene caracteres inválidos
  static String? name(
    String? value, {
    String? requiredMsg,
    String? minLengthMsg,
    String? maxLengthMsg,
    String? invalidCharactersMsg,
  }) {
    // Sanitización mínima: trim + colapsar espacios múltiples adyacentes
    final normalized = value?.trim().replaceAll(RegExp(r'\s{2,}'), ' ');

    if (normalized == null || normalized.isEmpty) {
      return requiredMsg;
    }
    if (normalized.length < 2) {
      return minLengthMsg;
    }
    if (normalized.length > _maxNameLength) {
      return maxLengthMsg;
    }
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');
    if (!nameRegex.hasMatch(normalized)) {
      return invalidCharactersMsg;
    }
    return null;
  }

  /// Valida un título de clase o tarea (texto libre).
  ///
  /// Aplica sanitización mínima: trim y colapso de espacios múltiples.
  ///
  /// [value] Título a validar
  /// [requiredMsg] Mensaje si está vacío
  /// [minLengthMsg] Mensaje si es muy corto (mínimo 2 caracteres)
  /// [maxLengthMsg] Mensaje si supera el límite máximo
  static String? title(
    String? value, {
    String? requiredMsg,
    String? minLengthMsg,
    String? maxLengthMsg,
  }) {
    // Sanitización mínima: trim + colapsar espacios múltiples adyacentes
    final normalized = value?.trim().replaceAll(RegExp(r'\s{2,}'), ' ');

    if (normalized == null || normalized.isEmpty) {
      return requiredMsg;
    }
    if (normalized.length < 2) {
      return minLengthMsg;
    }
    if (normalized.length > _maxTitleLength) {
      return maxLengthMsg;
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

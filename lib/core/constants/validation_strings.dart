/// Strings relacionados con validación de formularios
class ValidationStrings {
  // Validación de campos requeridos
  static String required(String fieldName) => '$fieldName es requerido';

  // Validación de email
  static const String emailRequired = 'El email es requerido';
  static const String emailInvalidFormat = 'El formato del email no es válido';

  // Validación de contraseña
  static const String passwordRequired = 'La contraseña es requerida';
  static const String passwordMinLength =
      'La contraseña debe tener al menos 6 caracteres';

  // Validación de confirmación de contraseña
  static const String confirmPasswordRequired = 'Debes confirmar tu contraseña';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';

  // Validación de nombres
  static String nameRequired(String fieldName) => '$fieldName es requerido';
  static String nameMinLength(String fieldName) =>
      '$fieldName debe tener al menos 3 caracteres';
  static String nameInvalidCharacters(String fieldName) =>
      '$fieldName solo puede contener letras y espacios';

  // Validación de clases
  static const String atLeastOneClassRequired =
      'Debes seleccionar al menos una clase';

  // Nombres de campos para validación
  static const String firstNameField = 'El nombre';
  static const String lastNameField = 'Los apellidos';
}

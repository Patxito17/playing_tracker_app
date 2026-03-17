/// Interfaz común para los perfiles de usuario de Playing Tracker.
///
/// Implementada por [TeacherModel] y [StudentModel] para evitar el uso de
/// `dynamic` en [AuthAuthenticated] y permitir acceso seguro a los campos
/// compartidos sin casteos.
abstract interface class UserProfile {
  /// Identificador único del usuario (UID de Firebase Authentication).
  String get id;

  /// Nombre(s) del usuario.
  String get firstName;

  /// Apellido(s) del usuario.
  String get lastName;

  /// Correo electrónico del usuario.
  String get email;

  /// Nombre completo derivado de [firstName] y [lastName].
  String get fullName;
}

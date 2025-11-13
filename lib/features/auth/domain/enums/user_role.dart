import 'package:json_annotation/json_annotation.dart';

/// Enum que representa el rol de un usuario en el sistema Playing Tracker.
///
/// Los roles disponibles son:
/// - [teacher]: Docente que puede crear clases, asignar tareas y ver el progreso de alumnos
/// - [student]: Alumno que puede unirse a clases, completar tareas y registrar sesiones de estudio
///
/// Este enum utiliza serialización JSON para almacenamiento en Firestore.
///
/// Ejemplo de uso:
/// ```dart
/// final UserRole rol = UserRole.teacher;
/// print(rol.displayName); // Output: "Docente"
/// ```
enum UserRole {
  /// Rol de docente con permisos para crear y gestionar clases y tareas
  @JsonValue('teacher')
  teacher,

  /// Rol de alumno con permisos para unirse a clases y registrar sesiones
  @JsonValue('student')
  student;

  /// Retorna el nombre para mostrar en la interfaz de usuario
  String get displayName {
    switch (this) {
      case UserRole.teacher:
        return 'Docente';
      case UserRole.student:
        return 'Alumno';
    }
  }
}

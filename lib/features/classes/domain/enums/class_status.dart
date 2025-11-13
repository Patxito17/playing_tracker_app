import 'package:json_annotation/json_annotation.dart';

/// Enum que representa el estado operacional de una clase.
///
/// Los estados disponibles son:
/// - [active]: Clase activa y operativa (los alumnos pueden unirse y registrar sesiones)
/// - [inactive]: Clase inactiva o archivada (no se permiten nuevas uniones ni sesiones)
///
/// Este enum utiliza serialización JSON para almacenamiento en Firestore.
///
/// Ejemplo de uso:
/// ```dart
/// final ClassStatus status = ClassStatus.active;
/// print(status.displayName); // Output: "Activa"
/// ```
enum ClassStatus {
  /// Clase activa y operativa - permite uniones de alumnos y registro de sesiones
  @JsonValue('active')
  active,

  /// Clase inactiva o archivada - no permite nuevas operaciones
  @JsonValue('inactive')
  inactive;

  /// Retorna el nombre para mostrar en la interfaz de usuario
  String get displayName {
    switch (this) {
      case ClassStatus.active:
        return 'Activa';
      case ClassStatus.inactive:
        return 'Inactiva';
    }
  }
}

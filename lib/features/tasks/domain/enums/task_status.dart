import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Enum que representa el estado de progreso de una tarea asignada a un alumno.
///
/// Los estados disponibles son:
/// - [pending]: Tarea pendiente de iniciar
/// - [inProgress]: Tarea en progreso (al menos una sesión registrada)
/// - [completed]: Tarea completada exitosamente
///
/// Este enum utiliza serialización JSON para almacenamiento en Firestore.
///
/// Ejemplo de uso:
/// ```dart
/// final TaskStatus status = TaskStatus.inProgress;
/// print(status.displayName); // Output: "En progreso"
/// final color = status.color; // Color naranja para en progreso
/// ```
enum TaskStatus {
  /// Tarea asignada pero sin sesiones de estudio registradas
  @JsonValue('pending')
  pending,

  /// Tarea con al menos una sesión de estudio registrada
  @JsonValue('in_progress')
  inProgress,

  /// Tarea completada exitosamente
  @JsonValue('completed')
  completed;

  /// Retorna el nombre para mostrar en la interfaz de usuario
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pendiente';
      case TaskStatus.inProgress:
        return 'En progreso';
      case TaskStatus.completed:
        return 'Completada';
    }
  }

  /// Retorna el color asociado al estado para uso en UI
  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
    }
  }
}

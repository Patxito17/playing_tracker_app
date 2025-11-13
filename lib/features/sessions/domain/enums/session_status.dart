import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Enum que representa el estado actual de una sesión de estudio.
///
/// Los estados disponibles son:
/// - [idle]: Sesión sin iniciar (estado inicial del timer)
/// - [running]: Sesión en curso con timer activo
/// - [paused]: Sesión pausada temporalmente
/// - [completed]: Sesión finalizada y guardada
///
/// Este enum utiliza serialización JSON para almacenamiento en Firestore.
///
/// Ejemplo de uso:
/// ```dart
/// final SessionStatus status = SessionStatus.running;
/// print(status.displayName); // Output: "En curso"
/// final color = status.color; // Color verde para sesión activa
/// ```
enum SessionStatus {
  /// Sesión sin iniciar - estado inicial del timer
  @JsonValue('idle')
  idle,

  /// Sesión activa con timer en curso
  @JsonValue('running')
  running,

  /// Sesión pausada temporalmente
  @JsonValue('paused')
  paused,

  /// Sesión finalizada y guardada en Firestore
  @JsonValue('completed')
  completed;

  /// Retorna el nombre para mostrar en la interfaz de usuario
  String get displayName {
    switch (this) {
      case SessionStatus.idle:
        return 'Sin iniciar';
      case SessionStatus.running:
        return 'En curso';
      case SessionStatus.paused:
        return 'Pausada';
      case SessionStatus.completed:
        return 'Completada';
    }
  }

  /// Retorna el color asociado al estado para uso en UI
  Color get color {
    switch (this) {
      case SessionStatus.idle:
        return Colors.grey;
      case SessionStatus.running:
        return Colors.green;
      case SessionStatus.paused:
        return Colors.orange;
      case SessionStatus.completed:
        return Colors.blue;
    }
  }
}

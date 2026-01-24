import 'package:equatable/equatable.dart';

/// Estados posibles del cronómetro de práctica.
sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial cuando no hay ninguna sesión activa.
final class SessionInitial extends SessionState {
  const SessionInitial();
}

/// Estado cuando el cronómetro está corriendo.
///
/// Contiene la duración actual en segundos y los IDs necesarios
/// para persistir la sesión.
final class SessionRunning extends SessionState {
  const SessionRunning({
    required this.taskId,
    required this.studentId,
    required this.teacherId,
    required this.duration,
    this.notes,
  });

  /// ID de la tarea para la cual se está registrando la sesión
  final String taskId;

  /// ID del estudiante que está practicando
  final String studentId;

  /// ID del docente dueño de la tarea
  final String teacherId;

  /// Duración actual de la sesión en segundos
  final int duration;

  /// Notas opcionales de la sesión
  final String? notes;

  @override
  List<Object?> get props => [taskId, studentId, teacherId, duration, notes];

  /// Crea una copia del estado con los campos especificados modificados
  SessionRunning copyWith({
    String? taskId,
    String? studentId,
    String? teacherId,
    int? duration,
    String? notes,
  }) {
    return SessionRunning(
      taskId: taskId ?? this.taskId,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }
}

/// Estado cuando el cronómetro está pausado.
///
/// Similar a [SessionRunning] pero indica que el timer está detenido
/// temporalmente.
final class SessionPaused extends SessionState {
  const SessionPaused({
    required this.taskId,
    required this.studentId,
    required this.teacherId,
    required this.duration,
    this.notes,
  });

  /// ID de la tarea para la cual se está registrando la sesión
  final String taskId;

  /// ID del estudiante que está practicando
  final String studentId;

  /// ID del docente dueño de la tarea
  final String teacherId;

  /// Duración actual de la sesión en segundos
  final int duration;

  /// Notas opcionales de la sesión
  final String? notes;

  @override
  List<Object?> get props => [taskId, studentId, teacherId, duration, notes];

  /// Crea una copia del estado con los campos especificados modificados
  SessionPaused copyWith({
    String? taskId,
    String? studentId,
    String? teacherId,
    int? duration,
    String? notes,
  }) {
    return SessionPaused(
      taskId: taskId ?? this.taskId,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }
}

/// Estado cuando la sesión se está guardando.
final class SessionSaving extends SessionState {
  const SessionSaving({required this.duration});

  /// Duración final de la sesión que se está guardando
  final int duration;

  @override
  List<Object?> get props => [duration];
}

/// Estado exitoso después de guardar la sesión.
///
/// Contiene un resumen de la sesión guardada.
final class SessionSuccess extends SessionState {
  const SessionSuccess({required this.duration, required this.message});

  /// Duración total de la sesión guardada en segundos
  final int duration;

  /// Mensaje de éxito para mostrar al usuario
  final String message;

  @override
  List<Object?> get props => [duration, message];
}

/// Estado de error cuando algo falla en el cronómetro o al guardar la sesión.
final class SessionError extends SessionState {
  const SessionError({required this.message, this.cause});

  /// Mensaje de error human-readable
  final String message;

  /// Excepción original que causó el error (opcional)
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

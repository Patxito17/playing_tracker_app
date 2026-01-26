import 'package:json_annotation/json_annotation.dart';

part 'task_stats_model.g.dart';

/// Modelo que representa estadísticas agregadas por tarea.
///
/// Contiene métricas de una tarea específica para un alumno,
/// facilitando el seguimiento de progreso por actividad.
///
/// Características principales:
/// - Enfocado en una tarea específica
/// - Incluye tiempo total, sesiones, y estado de completitud
/// - Comparativa con tiempo sugerido
/// - Utilizado en vista detallada de tareas y progreso individual
///
/// Ejemplo de uso:
/// ```dart
/// final taskStats = TaskStatsModel(
///   taskId: 'task_123',
///   taskTitle: 'Escalas mayores',
///   totalDuration: 3600, // 1 hora
///   totalSessions: 4,
///   suggestedDuration: 1800, // 30 minutos sugeridos
///   isCompleted: false,
///   lastSessionDate: Timestamp.fromDate(DateTime(2026, 1, 25)),
/// );
/// ```
@JsonSerializable()
class TaskStatsModel {
  /// ID de la tarea
  final String taskId;

  /// Título de la tarea
  final String taskTitle;

  /// Duración total de estudio en segundos para esta tarea
  final int totalDuration;

  /// Número total de sesiones completadas para esta tarea
  final int totalSessions;

  /// Duración sugerida por el docente en segundos
  final int? suggestedDuration;

  /// Indica si la tarea está marcada como completada
  final bool isCompleted;

  /// Fecha de la última sesión (opcional)
  final DateTime? lastSessionDate;

  /// Constructor del modelo de estadísticas por tarea
  const TaskStatsModel({
    required this.taskId,
    required this.taskTitle,
    required this.totalDuration,
    required this.totalSessions,
    this.suggestedDuration,
    this.isCompleted = false,
    this.lastSessionDate,
  });

  /// Crea una instancia desde un mapa JSON
  factory TaskStatsModel.fromJson(Map<String, dynamic> json) =>
      _$TaskStatsModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$TaskStatsModelToJson(this);

  /// Retorna la duración total formateada
  String get durationFormatted {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? "$minutes min" : ""}';
    } else if (minutes > 0) {
      return '$minutes min';
    }
    return '${totalDuration % 60} s';
  }

  /// Retorna el promedio de duración por sesión en segundos
  int get averageDurationPerSession {
    if (totalSessions == 0) return 0;
    return totalDuration ~/ totalSessions;
  }

  /// Retorna el porcentaje de progreso respecto al tiempo sugerido
  /// Retorna null si no hay tiempo sugerido
  double? get progressPercentage {
    if (suggestedDuration == null || suggestedDuration == 0) return null;
    return (totalDuration / suggestedDuration!) * 100;
  }

  /// Retorna el porcentaje formateado
  String get progressPercentageFormatted {
    final progress = progressPercentage;
    if (progress == null) return 'N/A';
    return '${progress.toStringAsFixed(0)}%';
  }

  /// Retorna true si se ha alcanzado o superado el tiempo sugerido
  bool get hasReachedGoal {
    if (suggestedDuration == null) return false;
    return totalDuration >= suggestedDuration!;
  }

  /// Retorna el tiempo restante para alcanzar el objetivo en segundos
  /// Retorna 0 si ya se alcanzó o no hay tiempo sugerido
  int get remainingTime {
    if (suggestedDuration == null || hasReachedGoal) return 0;
    return suggestedDuration! - totalDuration;
  }

  /// Retorna el tiempo restante formateado
  String get remainingTimeFormatted {
    final remaining = remainingTime;
    final minutes = remaining ~/ 60;

    if (minutes > 0) {
      return '$minutes min';
    }
    return '${remaining % 60} s';
  }

  /// Crea una copia del modelo con los campos especificados modificados
  TaskStatsModel copyWith({
    String? taskId,
    String? taskTitle,
    int? totalDuration,
    int? totalSessions,
    int? suggestedDuration,
    bool? isCompleted,
    DateTime? lastSessionDate,
  }) {
    return TaskStatsModel(
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      totalDuration: totalDuration ?? this.totalDuration,
      totalSessions: totalSessions ?? this.totalSessions,
      suggestedDuration: suggestedDuration ?? this.suggestedDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatsModel &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          taskTitle == other.taskTitle &&
          totalDuration == other.totalDuration &&
          totalSessions == other.totalSessions &&
          suggestedDuration == other.suggestedDuration &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      taskId.hashCode ^
      taskTitle.hashCode ^
      totalDuration.hashCode ^
      totalSessions.hashCode ^
      (suggestedDuration?.hashCode ?? 0) ^
      isCompleted.hashCode;

  @override
  String toString() =>
      'TaskStatsModel(task: $taskTitle, duration: $durationFormatted, '
      'sessions: $totalSessions, completed: $isCompleted)';
}

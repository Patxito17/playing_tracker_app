import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';

part 'class_stats_model.g.dart';

/// Modelo que representa estadísticas agregadas de una clase (vista docente).
///
/// Contiene métricas de todos los alumnos de una clase,
/// facilitando al docente monitorear el progreso general.
///
/// Características principales:
/// - Vista agregada de toda la clase
/// - Incluye número de alumnos activos
/// - Desglose por tareas
/// - Rankings y comparativas
///
/// Ejemplo de uso:
/// ```dart
/// final classStats = ClassStatsModel(
///   classId: 'class_123',
///   className: 'Piano Nivel 1',
///   totalStudents: 15,
///   activeStudents: 12, // Estudiantes con actividad esta semana
///   totalDuration: 54000, // 15 horas totales
///   totalSessions: 45,
///   taskBreakdown: [
///     TaskStatsModel(...),
///     TaskStatsModel(...),
///   ],
/// );
/// ```
@JsonSerializable()
class ClassStatsModel {
  /// ID de la clase
  final String classId;

  /// Nombre de la clase
  final String className;

  /// Número total de estudiantes en la clase
  final int totalStudents;

  /// Número de estudiantes con actividad reciente (última semana)
  final int activeStudents;

  /// Duración total de estudio de todos los estudiantes en segundos
  final int totalDuration;

  /// Número total de sesiones de todos los estudiantes
  final int totalSessions;

  /// Desglose de estadísticas por tarea
  final List<TaskStatsModel> taskBreakdown;

  /// Constructor del modelo de estadísticas por clase
  const ClassStatsModel({
    required this.classId,
    required this.className,
    required this.totalStudents,
    required this.activeStudents,
    required this.totalDuration,
    required this.totalSessions,
    this.taskBreakdown = const [],
  });

  /// Crea una instancia desde un mapa JSON
  factory ClassStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ClassStatsModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$ClassStatsModelToJson(this);

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

  /// Retorna el promedio de duración por estudiante en segundos
  int get averageDurationPerStudent {
    if (totalStudents == 0) return 0;
    return totalDuration ~/ totalStudents;
  }

  /// Retorna el promedio por estudiante formateado
  String get averageDurationPerStudentFormatted {
    final avg = averageDurationPerStudent;
    final hours = avg ~/ 3600;
    final minutes = (avg % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? "$minutes min" : ""}';
    } else if (minutes > 0) {
      return '$minutes min';
    }
    return '${avg % 60} s';
  }

  /// Retorna el porcentaje de estudiantes activos
  double get activeStudentsPercentage {
    if (totalStudents == 0) return 0;
    return (activeStudents / totalStudents) * 100;
  }

  /// Retorna el porcentaje de estudiantes activos formateado
  String get activeStudentsPercentageFormatted {
    return '${activeStudentsPercentage.toStringAsFixed(0)}%';
  }

  /// Retorna el promedio de sesiones por estudiante
  double get averageSessionsPerStudent {
    if (totalStudents == 0) return 0;
    return totalSessions / totalStudents;
  }

  /// Retorna el número de tareas asignadas
  int get totalTasks => taskBreakdown.length;

  /// Retorna el número de tareas completadas (al menos un alumno la completó)
  int get completedTasks {
    return taskBreakdown.where((task) => task.isCompleted).length;
  }

  /// Crea una copia del modelo con los campos especificados modificados
  ClassStatsModel copyWith({
    String? classId,
    String? className,
    int? totalStudents,
    int? activeStudents,
    int? totalDuration,
    int? totalSessions,
    List<TaskStatsModel>? taskBreakdown,
  }) {
    return ClassStatsModel(
      classId: classId ?? this.classId,
      className: className ?? this.className,
      totalStudents: totalStudents ?? this.totalStudents,
      activeStudents: activeStudents ?? this.activeStudents,
      totalDuration: totalDuration ?? this.totalDuration,
      totalSessions: totalSessions ?? this.totalSessions,
      taskBreakdown: taskBreakdown ?? this.taskBreakdown,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassStatsModel &&
          runtimeType == other.runtimeType &&
          classId == other.classId &&
          className == other.className &&
          totalStudents == other.totalStudents &&
          activeStudents == other.activeStudents &&
          totalDuration == other.totalDuration &&
          totalSessions == other.totalSessions;

  @override
  int get hashCode =>
      classId.hashCode ^
      className.hashCode ^
      totalStudents.hashCode ^
      activeStudents.hashCode ^
      totalDuration.hashCode ^
      totalSessions.hashCode;

  @override
  String toString() =>
      'ClassStatsModel(class: $className, students: $totalStudents, '
      'duration: $durationFormatted, sessions: $totalSessions)';
}

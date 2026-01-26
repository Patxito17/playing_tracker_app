import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';

part 'student_progress_model.g.dart';

/// Modelo que representa el progreso individual de un alumno.
///
/// Contiene métricas de resumen del progreso general del estudiante,
/// incluyendo rachas, tiempos totales y tendencias.
///
/// Características principales:
/// - Vista global del progreso del alumno
/// - Incluye rachas de práctica consecutivas
/// - Tiempo total acumulado
/// - Última sesión registrada
/// - Tendencias y comparativas
///
/// Ejemplo de uso:
/// ```dart
/// final progress = StudentProgressModel(
///   studentId: 'student_123',
///   studentName: 'Juan Pérez',
///   totalDuration: 36000, // 10 horas totales
///   totalSessions: 20,
///   currentStreak: 5, // 5 días consecutivos
///   longestStreak: 12,
///   lastSessionDate: Timestamp.fromDate(DateTime(2026, 1, 26)),
///   totalTasks: 8,
///   completedTasks: 3,
/// );
/// ```
@JsonSerializable()
class StudentProgressModel {
  /// ID del estudiante
  final String studentId;

  /// Nombre completo del estudiante
  final String studentName;

  /// Duración total acumulada en segundos
  final int totalDuration;

  /// Número total de sesiones completadas
  final int totalSessions;

  /// Racha actual de días consecutivos con práctica
  final int currentStreak;

  /// Racha más larga de días consecutivos
  final int longestStreak;

  /// Fecha de la última sesión registrada
  @TimestampConverter()
  final Timestamp? lastSessionDate;

  /// Número total de tareas asignadas
  final int totalTasks;

  /// Número de tareas completadas
  final int completedTasks;

  /// Promedio de duración por sesión en segundos (calculado)
  final int? averageSessionDuration;

  /// Constructor del modelo de progreso del estudiante
  const StudentProgressModel({
    required this.studentId,
    required this.studentName,
    required this.totalDuration,
    required this.totalSessions,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSessionDate,
    required this.totalTasks,
    required this.completedTasks,
    this.averageSessionDuration,
  });

  /// Crea una instancia desde un mapa JSON
  factory StudentProgressModel.fromJson(Map<String, dynamic> json) =>
      _$StudentProgressModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$StudentProgressModelToJson(this);

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
  int get calculatedAverageSessionDuration {
    if (totalSessions == 0) return 0;
    return totalDuration ~/ totalSessions;
  }

  /// Retorna el promedio de sesión formateado
  String get averageSessionFormatted {
    final avg = averageSessionDuration ?? calculatedAverageSessionDuration;
    final minutes = avg ~/ 60;

    if (minutes > 0) {
      return '$minutes min';
    }
    return '${avg % 60} s';
  }

  /// Retorna el porcentaje de tareas completadas
  double get completionPercentage {
    if (totalTasks == 0) return 0;
    return (completedTasks / totalTasks) * 100;
  }

  /// Retorna el porcentaje de completitud formateado
  String get completionPercentageFormatted {
    return '${completionPercentage.toStringAsFixed(0)}%';
  }

  /// Retorna true si el estudiante practicó hoy
  bool get practicedToday {
    if (lastSessionDate == null) return false;
    final today = DateTime.now();
    final lastSession = lastSessionDate!.toDate();
    return lastSession.year == today.year &&
        lastSession.month == today.month &&
        lastSession.day == today.day;
  }

  /// Retorna el número de días desde la última sesión
  int get daysSinceLastSession {
    if (lastSessionDate == null) return -1;
    final now = DateTime.now();
    final lastSession = lastSessionDate!.toDate();
    return now.difference(lastSession).inDays;
  }

  /// Crea una copia del modelo con los campos especificados modificados
  StudentProgressModel copyWith({
    String? studentId,
    String? studentName,
    int? totalDuration,
    int? totalSessions,
    int? currentStreak,
    int? longestStreak,
    Timestamp? lastSessionDate,
    int? totalTasks,
    int? completedTasks,
    int? averageSessionDuration,
  }) {
    return StudentProgressModel(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      totalDuration: totalDuration ?? this.totalDuration,
      totalSessions: totalSessions ?? this.totalSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      averageSessionDuration:
          averageSessionDuration ?? this.averageSessionDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentProgressModel &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          studentName == other.studentName &&
          totalDuration == other.totalDuration &&
          totalSessions == other.totalSessions &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          totalTasks == other.totalTasks &&
          completedTasks == other.completedTasks;

  @override
  int get hashCode =>
      studentId.hashCode ^
      studentName.hashCode ^
      totalDuration.hashCode ^
      totalSessions.hashCode ^
      currentStreak.hashCode ^
      longestStreak.hashCode ^
      totalTasks.hashCode ^
      completedTasks.hashCode;

  @override
  String toString() =>
      'StudentProgressModel(student: $studentName, duration: $durationFormatted, '
      'streak: $currentStreak days, completion: $completionPercentageFormatted)';
}

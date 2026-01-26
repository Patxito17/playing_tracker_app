import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';
import 'package:playing_tracker/features/statistics/domain/models/daily_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';

part 'weekly_stats_model.g.dart';

/// Modelo que representa estadísticas agregadas de una semana completa.
///
/// Contiene métricas de estudio de un alumno para una semana,
/// incluyendo desglose diario y comparativa con semanas anteriores.
///
/// Características principales:
/// - Agregadas por semana (lunes a domingo)
/// - Incluye desglose diario para visualización de tendencias
/// - Campo `weekStart` para identificar la semana
/// - Comparativa opcional con la semana anterior
///
/// Ejemplo de uso:
/// ```dart
/// final weeklyStats = WeeklyStatsModel(
///   weekStart: Timestamp.fromDate(DateTime(2026, 1, 20)),
///   weekEnd: Timestamp.fromDate(DateTime(2026, 1, 26)),
///   totalDuration: 10800, // 3 horas
///   totalSessions: 7,
///   uniqueTasks: 3,
///   dailyBreakdown: [
///     DailyStatsModel(...), // Lunes
///     DailyStatsModel(...), // Martes
///     // ...
///   ],
///   previousWeekDuration: 7200, // 2 horas semana anterior
/// );
/// ```
@JsonSerializable()
class WeeklyStatsModel {
  /// Fecha de inicio de la semana (lunes)
  @TimestampConverter()
  final Timestamp weekStart;

  /// Fecha de fin de la semana (domingo)
  @TimestampConverter()
  final Timestamp weekEnd;

  /// Duración total de estudio en segundos para la semana
  final int totalDuration;

  /// Número total de sesiones completadas en la semana
  final int totalSessions;

  /// Número de tareas únicas trabajadas en la semana
  final int uniqueTasks;

  /// Desglose diario de estadísticas (lunes a domingo)
  final List<DailyStatsModel> dailyBreakdown;

  /// Desglose por tareas trabajadas en la semana
  final List<TaskStatsModel> taskBreakdown;

  /// Duración total de la semana anterior (para comparativa)
  final int? previousWeekDuration;

  /// Constructor del modelo de estadísticas semanales
  const WeeklyStatsModel({
    required this.weekStart,
    required this.weekEnd,
    required this.totalDuration,
    required this.totalSessions,
    required this.uniqueTasks,
    this.dailyBreakdown = const [],
    this.taskBreakdown = const [],
    this.previousWeekDuration,
  });

  /// Crea una instancia desde un mapa JSON
  factory WeeklyStatsModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatsModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$WeeklyStatsModelToJson(this);

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

  /// Retorna el promedio de duración diaria en segundos
  int get averageDailyDuration {
    if (dailyBreakdown.isEmpty) return 0;
    return totalDuration ~/ 7; // 7 días en una semana
  }

  /// Retorna el promedio diario formateado
  String get averageDailyFormatted {
    final avg = averageDailyDuration;
    final minutes = avg ~/ 60;

    if (minutes > 0) {
      return '$minutes min';
    }
    return '${avg % 60} s';
  }

  /// Retorna el cambio porcentual respecto a la semana anterior
  /// Retorna null si no hay datos de la semana anterior
  double? get percentageChangeFromPreviousWeek {
    if (previousWeekDuration == null || previousWeekDuration == 0) return null;
    return ((totalDuration - previousWeekDuration!) / previousWeekDuration!) *
        100;
  }

  /// Retorna el cambio porcentual formateado con signo
  String get percentageChangeFormatted {
    final change = percentageChangeFromPreviousWeek;
    if (change == null) return 'N/A';

    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }

  /// Retorna el número de días con actividad (al menos una sesión)
  int get activeDays {
    return dailyBreakdown.where((day) => day.totalSessions > 0).length;
  }

  /// Crea una copia del modelo con los campos especificados modificados
  WeeklyStatsModel copyWith({
    Timestamp? weekStart,
    Timestamp? weekEnd,
    int? totalDuration,
    int? totalSessions,
    int? uniqueTasks,
    List<DailyStatsModel>? dailyBreakdown,
    int? previousWeekDuration,
  }) {
    return WeeklyStatsModel(
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      totalDuration: totalDuration ?? this.totalDuration,
      totalSessions: totalSessions ?? this.totalSessions,
      uniqueTasks: uniqueTasks ?? this.uniqueTasks,
      dailyBreakdown: dailyBreakdown ?? this.dailyBreakdown,
      previousWeekDuration: previousWeekDuration ?? this.previousWeekDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyStatsModel &&
          runtimeType == other.runtimeType &&
          weekStart == other.weekStart &&
          weekEnd == other.weekEnd &&
          totalDuration == other.totalDuration &&
          totalSessions == other.totalSessions &&
          uniqueTasks == other.uniqueTasks;

  @override
  int get hashCode =>
      weekStart.hashCode ^
      weekEnd.hashCode ^
      totalDuration.hashCode ^
      totalSessions.hashCode ^
      uniqueTasks.hashCode;

  @override
  String toString() =>
      'WeeklyStatsModel(week: ${weekStart.toDate()} - ${weekEnd.toDate()}, '
      'duration: $durationFormatted, sessions: $totalSessions)';
}

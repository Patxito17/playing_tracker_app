import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';

part 'daily_stats_model.g.dart';

/// Modelo que representa estadísticas agregadas de un día específico.
///
/// Contiene métricas de estudio de un alumno para un día en particular,
/// facilitando la visualización de progreso diario y comparativas.
///
/// Características principales:
/// - Agregadas por día (sin descomposición horaria)
/// - Incluye total de tiempo, sesiones y tareas únicas trabajadas
/// - Campo `date` para identificar el día
/// - Utilizada en gráficos diarios y vista de calendario
///
/// Ejemplo de uso:
/// ```dart
/// final dailyStats = DailyStatsModel(
///   date: Timestamp.fromDate(DateTime(2026, 1, 26)),
///   totalDuration: 3600, // 1 hora en segundos
///   totalSessions: 3,
///   uniqueTasks: 2,
/// );
///
/// // Serializar a JSON
/// final json = dailyStats.toJson();
///
/// // Deserializar desde JSON
/// final statsFromJson = DailyStatsModel.fromJson(json);
/// ```
@JsonSerializable()
class DailyStatsModel {
  /// Fecha del día (sin hora, para agrupación)
  @TimestampConverter()
  final Timestamp date;

  /// Duración total de estudio en segundos
  final int totalDuration;

  /// Número total de sesiones completadas
  final int totalSessions;

  /// Número de tareas únicas trabajadas ese día
  final int uniqueTasks;

  /// Constructor del modelo de estadísticas diarias
  const DailyStatsModel({
    required this.date,
    required this.totalDuration,
    required this.totalSessions,
    required this.uniqueTasks,
  });

  /// Crea una instancia desde un mapa JSON
  factory DailyStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$DailyStatsModelToJson(this);

  /// Retorna la duración total formateada en formato legible
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

  /// Retorna el promedio formateado
  String get averageDurationFormatted {
    final avg = averageDurationPerSession;
    final minutes = avg ~/ 60;
    final seconds = avg % 60;

    if (minutes > 0) {
      return '$minutes min ${seconds > 0 ? "$seconds s" : ""}';
    }
    return '$seconds s';
  }

  /// Crea una copia del modelo con los campos especificados modificados
  DailyStatsModel copyWith({
    Timestamp? date,
    int? totalDuration,
    int? totalSessions,
    int? uniqueTasks,
  }) {
    return DailyStatsModel(
      date: date ?? this.date,
      totalDuration: totalDuration ?? this.totalDuration,
      totalSessions: totalSessions ?? this.totalSessions,
      uniqueTasks: uniqueTasks ?? this.uniqueTasks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStatsModel &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          totalDuration == other.totalDuration &&
          totalSessions == other.totalSessions &&
          uniqueTasks == other.uniqueTasks;

  @override
  int get hashCode =>
      date.hashCode ^
      totalDuration.hashCode ^
      totalSessions.hashCode ^
      uniqueTasks.hashCode;

  @override
  String toString() =>
      'DailyStatsModel(date: ${date.toDate()}, duration: $durationFormatted, sessions: $totalSessions)';
}

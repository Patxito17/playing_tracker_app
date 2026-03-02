import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/daily_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';

/// Contrato del repositorio de estadísticas.
///
/// Define las operaciones para obtener métricas y estadísticas desde la capa de datos.
abstract interface class StatisticsRepository {
  /// Obtiene estadísticas diarias para un estudiante.
  Future<DailyStatsModel> getDailyStats({
    required String studentId,
    required DateTime date,
    String? classId,
  });

  /// Obtiene estadísticas semanales para un estudiante.
  Future<WeeklyStatsModel> getWeeklyStats({
    required String studentId,
    required DateTime weekStart,
    String? classId,
  });

  /// Obtiene estadísticas mensuales para un estudiante.
  Future<DailyStatsModel> getMonthlyStats({
    required String studentId,
    required int month,
    required int year,
    String? classId,
  });

  /// Obtiene estadísticas de una tarea específica.
  Future<TaskStatsModel> getTaskStats({
    required String taskId,
    String? studentId,
  });

  /// Obtiene estadísticas agregadas de una clase (vista docente).
  Future<ClassStatsModel> getClassStats({
    required String classId,
    required String teacherId,
    TimeFilter? timeFilter,
    bool forceRefresh = false,
  });

  /// Obtiene estadísticas detalladas de un estudiante con filtro de tiempo.
  Future<WeeklyStatsModel> getStudentStats({
    required String studentId,
    TimeFilter timeFilter = TimeFilter.thisWeek,
    String? classId,
    bool forceRefresh = false,
  });

  /// Obtiene el progreso individual de un estudiante.
  Future<StudentProgressModel> getStudentProgress({
    required String studentId,
    bool forceRefresh = false,
  });
}

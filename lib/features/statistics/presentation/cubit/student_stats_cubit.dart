import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_state.dart';

/// Cubit para gestionar el estado de las estadísticas del alumno.
///
/// Carga en paralelo el progreso general (`StudentProgressModel`) y las
/// estadísticas semanales (`WeeklyStatsModel`) con desglose de tareas.
class StudentStatsCubit extends Cubit<StudentStatsState> {
  StudentStatsCubit(this._repository) : super(const StudentStatsInitial());

  final StatisticsRepository _repository;

  /// Carga las estadísticas del alumno.
  ///
  /// Obtiene:
  /// - Progreso general (tiempo total, rachas, tareas completadas)
  /// - Estadísticas de la semana actual (gráfico de barras y circular)
  Future<void> loadStats({required String studentId, String? classId}) async {
    emit(const StudentStatsLoading());

    try {
      log(
        'StudentStatsCubit: Cargando estadísticas para estudiante $studentId${classId != null ? " en clase $classId" : ""}',
        name: 'StudentStatsCubit',
      );

      // Calcular inicio de semana (lunes)
      final now = DateTime.now();
      final weekStart = _getWeekStart(now);

      // Cargar en paralelo
      final results = await Future.wait([
        _repository.getStudentProgress(studentId: studentId),
        _repository.getWeeklyStats(
          studentId: studentId,
          weekStart: weekStart,
          classId: classId,
        ),
      ]);

      final progress = results[0] as StudentProgressModel;
      final weeklyStats = results[1] as WeeklyStatsModel;

      emit(StudentStatsLoaded(progress: progress, weeklyStats: weeklyStats));

      log(
        'StudentStatsCubit: Estadísticas cargadas exitosamente',
        name: 'StudentStatsCubit',
      );
    } catch (error, stackTrace) {
      log(
        'StudentStatsCubit: Error al cargar estadísticas',
        error: error,
        stackTrace: stackTrace,
        name: 'StudentStatsCubit',
      );

      emit(
        StudentStatsError(
          message: 'No se pudieron cargar las estadísticas: $error',
        ),
      );
    }
  }

  /// Refresca las estadísticas del alumno.
  Future<void> refreshStats({
    required String studentId,
    String? classId,
  }) async {
    // Mantener el estado actual mientras refrescamos
    await loadStats(studentId: studentId, classId: classId);
  }

  /// Calcula el lunes de la semana actual
  DateTime _getWeekStart(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }
}

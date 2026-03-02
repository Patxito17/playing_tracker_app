import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_state.dart';

/// Cubit para gestionar el estado de las estadísticas del alumno.
///
/// Soporta filtros de tiempo y carga en paralelo métricas de progreso
/// y desgloses de sesiones/tareas.
class StudentStatsCubit extends Cubit<StudentStatsState> {
  StudentStatsCubit(this._repository) : super(const StudentStatsInitial());

  final StatisticsRepository _repository;

  /// Carga las estadísticas del alumno con un filtro específico.
  Future<void> loadStats({
    required String studentId,
    String? classId,
    TimeFilter? timeFilter,
  }) async {
    final activeFilter = timeFilter ?? state.timeFilter;

    // Preservar datos actuales mientras cargamos para evitar parpadeos
    StudentProgressModel? currentProgress;
    WeeklyStatsModel? currentWeeklyStats;

    if (state is StudentStatsLoaded) {
      final loaded = state as StudentStatsLoaded;
      currentProgress = loaded.progress;
      currentWeeklyStats = loaded.weeklyStats;
    } else if (state is StudentStatsLoading) {
      final loading = state as StudentStatsLoading;
      currentProgress = loading.progress;
      currentWeeklyStats = loading.weeklyStats;
    }

    emit(
      StudentStatsLoading(
        timeFilter: activeFilter,
        progress: currentProgress,
        weeklyStats: currentWeeklyStats,
      ),
    );

    try {
      log(
        'StudentStatsCubit: Cargando estadísticas para estudiante $studentId '
        'con filtro $activeFilter ${classId != null ? "en clase $classId" : ""}',
        name: 'StudentStatsCubit',
      );

      // Cargar en paralelo
      final results = await Future.wait([
        _repository.getStudentProgress(studentId: studentId),
        _repository.getStudentStats(
          studentId: studentId,
          timeFilter: activeFilter,
          classId: classId,
        ),
      ]);

      final progress = results[0] as StudentProgressModel;
      final weeklyStats = results[1] as WeeklyStatsModel;

      emit(
        StudentStatsLoaded(
          timeFilter: activeFilter,
          progress: progress,
          weeklyStats: weeklyStats,
        ),
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
          timeFilter: activeFilter,
          message: 'No se pudieron cargar las estadísticas: $error',
          progress: currentProgress,
          weeklyStats: currentWeeklyStats,
        ),
      );
    }
  }

  /// Cambia el filtro de tiempo y recarga las estadísticas.
  Future<void> changeFilter({
    required String studentId,
    required TimeFilter newFilter,
    String? classId,
  }) async {
    if (state.timeFilter == newFilter) return;
    await loadStats(
      studentId: studentId,
      timeFilter: newFilter,
      classId: classId,
    );
  }

  /// Refresca las estadísticas con el filtro actual.
  Future<void> refreshStats({
    required String studentId,
    String? classId,
  }) async {
    await loadStats(
      studentId: studentId,
      classId: classId,
      timeFilter: state.timeFilter,
    );
  }
}

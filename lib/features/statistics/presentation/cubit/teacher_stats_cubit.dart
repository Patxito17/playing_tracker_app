import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_state.dart';

/// Cubit para gestionar el estado de las estadísticas del docente.
///
/// Carga las estadísticas de una clase específica (y en un periodo concreto)
/// para que el docente pueda ver el progreso agregado de sus alumnos,
/// incluyendo el ranking individual por alumno.
class TeacherStatsCubit extends Cubit<TeacherStatsState> {
  TeacherStatsCubit(this._repository) : super(const TeacherStatsInitial());

  final StatisticsRepository _repository;

  /// Carga las estadísticas de una clase con filtros opcionales.
  ///
  /// Realiza en paralelo:
  /// - Estadísticas agregadas de la clase ([getClassStats])
  /// - Ranking individual de alumnos ([getStudentsClassStats])
  Future<void> loadClassStats({
    required String classId,
    required String teacherId,
    TimeFilter? timeFilter,
    bool forceRefresh = false,
  }) async {
    final activeFilter = timeFilter ?? state.timeFilter;

    final previousClassStats = state is TeacherStatsLoaded
        ? (state as TeacherStatsLoaded).classStats
        : (state is TeacherStatsLoading
              ? (state as TeacherStatsLoading).classStats
              : null);
    final previousStudentsStats = state is TeacherStatsLoaded
        ? (state as TeacherStatsLoaded).studentsStats
        : (state is TeacherStatsLoading
              ? (state as TeacherStatsLoading).studentsStats
              : null);

    emit(
      TeacherStatsLoading(
        timeFilter: activeFilter,
        classStats: previousClassStats,
        studentsStats: previousStudentsStats,
      ),
    );

    try {
      log(
        'TeacherStatsCubit: Cargando estadísticas clase $classId con filtro $activeFilter',
        name: 'TeacherStatsCubit',
      );

      final results = await Future.wait([
        _repository.getClassStats(
          classId: classId,
          teacherId: teacherId,
          timeFilter: activeFilter,
          forceRefresh: forceRefresh,
        ),
        _repository.getStudentsClassStats(
          classId: classId,
          teacherId: teacherId,
          timeFilter: activeFilter,
          forceRefresh: forceRefresh,
        ),
      ]);

      emit(
        TeacherStatsLoaded(
          classStats: results[0] as ClassStatsModel,
          studentsStats: results[1] as List<StudentClassStatsModel>,
          timeFilter: activeFilter,
        ),
      );

      log(
        'TeacherStatsCubit: Estadísticas cargadas exitosamente',
        name: 'TeacherStatsCubit',
      );
    } catch (error, stackTrace) {
      log(
        'TeacherStatsCubit: Error al cargar estadísticas',
        error: error,
        stackTrace: stackTrace,
        name: 'TeacherStatsCubit',
      );

      emit(
        TeacherStatsError(
          message: 'No se pudieron cargar las estadísticas: $error',
          timeFilter: activeFilter,
        ),
      );
    }
  }

  /// Cambia el filtro de tiempo y recarga los datos.
  Future<void> changeFilter({
    required String classId,
    required String teacherId,
    required TimeFilter newFilter,
  }) async {
    if (state.timeFilter == newFilter) return;

    await loadClassStats(
      classId: classId,
      teacherId: teacherId,
      timeFilter: newFilter,
    );
  }

  /// Refresca los datos forzando la descarga desde Firestore.
  Future<void> refreshClassStats({
    required String classId,
    required String teacherId,
  }) async {
    await loadClassStats(
      classId: classId,
      teacherId: teacherId,
      timeFilter: state.timeFilter,
      forceRefresh: true,
    );
  }
}

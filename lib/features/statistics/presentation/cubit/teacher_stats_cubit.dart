import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_state.dart';

/// Cubit para gestionar el estado de las estadísticas del docente.
///
/// Carga las estadísticas de una clase específica para que el docente
/// pueda ver el progreso agregado de sus alumnos.
class TeacherStatsCubit extends Cubit<TeacherStatsState> {
  TeacherStatsCubit(this._repository) : super(const TeacherStatsInitial());

  final StatisticsRepository _repository;

  /// Carga las estadísticas de una clase específica.
  ///
  /// Parámetros:
  /// - [classId]: ID de la clase
  /// - [teacherId]: ID del docente
  Future<void> loadClassStats({
    required String classId,
    required String teacherId,
  }) async {
    emit(const TeacherStatsLoading());

    try {
      log(
        'TeacherStatsCubit: Cargando estadísticas de clase $classId para docente $teacherId',
        name: 'TeacherStatsCubit',
      );

      final classStats = await _repository.getClassStats(
        classId: classId,
        teacherId: teacherId,
      );

      emit(TeacherStatsLoaded(classStats: classStats));

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
        ),
      );
    }
  }

  /// Refresca las estadísticas de la clase.
  Future<void> refreshClassStats({
    required String classId,
    required String teacherId,
  }) async {
    // Mantener el estado actual mientras refrescamos
    await loadClassStats(classId: classId, teacherId: teacherId);
  }
}

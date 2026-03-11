import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/assignment_state.dart';

/// Cubit encargado de gestionar la lógica de asignaciones para alumnos.
final class AssignmentCubit extends Cubit<AssignmentState> {
  AssignmentCubit(this._repository) : super(const AssignmentInitial());

  final TaskRepository _repository;
  StreamSubscription? _assignmentsSubscription;
  String? _currentStudentId;
  TaskFilters? _currentFilters;

  /// Observa en tiempo real las asignaciones del alumno autenticado.
  Future<void> watchAssignments({
    required String studentId,
    TaskFilters? filters,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      emit(const AssignmentError(message: ''));
      return;
    }

    _currentStudentId = sanitizedId;
    _currentFilters = filters;
    emit(const AssignmentLoading());
    await _assignmentsSubscription?.cancel();

    _assignmentsSubscription = _repository
        .watchStudentAssignments(sanitizedId, filters: filters)
        .listen(
          (assignments) {
            if (assignments.isEmpty) {
              emit(const AssignmentEmpty());
              return;
            }
            emit(
              AssignmentSuccess(
                assignments: List.unmodifiable(assignments),
                filters: _currentFilters,
              ),
            );
          },
          onError: (error, stackTrace) {
            addError(error, stackTrace);
            if (error is TaskRepositoryException) {
              emit(AssignmentError(message: error.message, cause: error));
              return;
            }
            emit(AssignmentError(message: '', cause: error));
          },
        );
  }

  /// Vuelve a suscribirse al stream utilizando los últimos parámetros.
  Future<void> refreshAssignments() async {
    final studentId = _currentStudentId;
    if (studentId == null) {
      emit(const AssignmentError(message: ''));
      return;
    }
    await watchAssignments(studentId: studentId, filters: _currentFilters);
  }

  /// Actualiza los filtros activos y vuelve a suscribirse.
  Future<void> applyFilters(TaskFilters filters) async {
    _currentFilters = filters;
    final studentId = _currentStudentId;
    if (studentId == null) {
      emit(const AssignmentError(message: ''));
      return;
    }
    await watchAssignments(studentId: studentId, filters: filters);
  }

  @override
  Future<void> close() async {
    await _assignmentsSubscription?.cancel();
    return super.close();
  }
}

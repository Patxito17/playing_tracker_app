import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_state.dart';

/// Cubit encargado de gestionar la lógica de tareas para docentes.
final class TaskCubit extends Cubit<TaskState> {
  TaskCubit(this._repository) : super(const TaskInitial());

  final TaskRepository _repository;
  StreamSubscription? _tasksSubscription;
  String? _currentTeacherId;
  TaskFilters? _currentFilters;

  /// Observa en tiempo real las tareas del docente autenticado.
  Future<void> watchTasks({
    required String teacherId,
    TaskFilters? filters,
  }) async {
    final sanitizedId = teacherId.trim();
    if (sanitizedId.isEmpty) {
      emit(const TaskError(message: TaskStrings.taskGenericError));
      return;
    }
    _currentTeacherId = sanitizedId;
    _currentFilters = filters;
    emit(const TaskLoading());
    await _tasksSubscription?.cancel();

    _tasksSubscription = _repository
        .watchTeacherTasks(sanitizedId, filters: filters)
        .listen(
          (tasks) {
            if (tasks.isEmpty) {
              emit(const TaskEmpty());
              return;
            }
            emit(
              TaskSuccess(
                tasks: List.unmodifiable(tasks),
                filters: _currentFilters,
              ),
            );
          },
          onError: (error, stackTrace) {
            addError(error, stackTrace);
            if (error is TaskRepositoryException) {
              emit(TaskError(message: error.message, cause: error));
              return;
            }
            emit(
              TaskError(message: TaskStrings.taskGenericError, cause: error),
            );
          },
        );
  }

  /// Vuelve a suscribirse al stream utilizando los últimos parámetros.
  Future<void> refreshTasks() async {
    final teacherId = _currentTeacherId;
    if (teacherId == null) {
      emit(const TaskError(message: TaskStrings.taskGenericError));
      return;
    }
    await watchTasks(teacherId: teacherId, filters: _currentFilters);
  }

  /// Actualiza los filtros activos y vuelve a suscribirse.
  Future<void> applyFilters(TaskFilters filters) async {
    _currentFilters = filters;
    final teacherId = _currentTeacherId;
    if (teacherId == null) {
      emit(const TaskError(message: TaskStrings.taskGenericError));
      return;
    }
    await watchTasks(teacherId: teacherId, filters: filters);
  }

  /// Crea una nueva tarea y delega la persistencia al repositorio.
  Future<void> createTask(CreateTaskInput input) async {
    emit(const TaskLoading());
    try {
      await _repository.createTask(input);
      emit(
        const TaskActionSuccess(
          action: TaskAction.created,
          message: TaskStrings.taskCreateSuccess,
        ),
      );
    } on TaskRepositoryException catch (error) {
      emit(TaskError(message: error.message, cause: error));
    } catch (error) {
      emit(TaskError(message: TaskStrings.taskGenericError, cause: error));
    }
  }

  /// Actualiza una tarea existente.
  Future<void> updateTask(UpdateTaskInput input) async {
    emit(const TaskLoading());
    try {
      await _repository.updateTask(input);
      emit(
        const TaskActionSuccess(
          action: TaskAction.updated,
          message: TaskStrings.taskUpdateSuccess,
        ),
      );
    } on TaskRepositoryException catch (error) {
      emit(TaskError(message: error.message, cause: error));
    } catch (error) {
      emit(TaskError(message: TaskStrings.taskGenericError, cause: error));
    }
  }

  /// Elimina (o archiva) una tarea existente.
  Future<void> deleteTask(String taskId) async {
    emit(const TaskLoading());
    try {
      await _repository.deleteTask(taskId);
      emit(
        const TaskActionSuccess(
          action: TaskAction.deleted,
          message: TaskStrings.taskDeleteSuccess,
        ),
      );
    } on TaskRepositoryException catch (error) {
      emit(TaskError(message: error.message, cause: error));
    } catch (error) {
      emit(TaskError(message: TaskStrings.taskGenericError, cause: error));
    }
  }

  /// Asigna una tarea a una clase utilizando fan-out.
  Future<void> assignTaskToClass(AssignTaskInput input) async {
    emit(const TaskLoading());
    try {
      await _repository.assignTaskToClass(input);
      emit(
        const TaskActionSuccess(
          action: TaskAction.assigned,
          message: TaskStrings.taskAssignSuccess,
        ),
      );
    } on TaskRepositoryException catch (error) {
      emit(TaskError(message: error.message, cause: error));
    } catch (error) {
      emit(TaskError(message: TaskStrings.taskGenericError, cause: error));
    }
  }

  @override
  Future<void> close() async {
    await _tasksSubscription?.cancel();
    return super.close();
  }
}

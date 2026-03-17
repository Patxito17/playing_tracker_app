import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_state.dart';

/// Cubit encargado de gestionar la lógica de tareas para docentes.
final class TaskCubit extends Cubit<TaskState> {
  TaskCubit(this._repository) : super(const TaskInitial());

  final TaskRepository _repository;

  /// Suscripción activa al stream de tareas del docente.
  StreamSubscription? _tasksSubscription;

  /// ID del docente cuyas tareas se están observando.
  String? _currentTeacherId;

  /// Filtros activos aplicados a la última suscripción.
  TaskFilters? _currentFilters;

  /// Observa en tiempo real las tareas del docente autenticado.
  Future<void> watchTasks({
    required String teacherId,
    TaskFilters? filters,
  }) async {
    final sanitizedId = teacherId.trim();
    if (sanitizedId.isEmpty) {
      emit(const TaskError(message: 'ID de docente no válido.'));
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
              emit(const TaskEmpty(message: null));
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
              TaskError(
                message: 'Ocurrió un error inesperado al cargar tareas.',
                cause: error,
              ),
            );
          },
        );
  }

  /// Vuelve a suscribirse al stream utilizando los últimos parámetros.
  Future<void> refreshTasks() async {
    final teacherId = _currentTeacherId;
    if (teacherId == null) {
      emit(
        const TaskError(message: 'No hay docente autenticado para refrescar.'),
      );
      return;
    }
    await watchTasks(teacherId: teacherId, filters: _currentFilters);
  }

  /// Actualiza los filtros activos y vuelve a suscribirse.
  Future<void> applyFilters(TaskFilters filters) async {
    _currentFilters = filters;
    final teacherId = _currentTeacherId;
    if (teacherId == null) {
      emit(
        const TaskError(message: 'No hay docente autenticado para filtrar.'),
      );
      return;
    }
    await watchTasks(teacherId: teacherId, filters: filters);
  }

  /// Crea una nueva tarea y delega la persistencia al repositorio.
  Future<void> createTask(CreateTaskInput input) async {
    emit(const TaskLoading());
    try {
      final task = await _repository.createTask(input);
      emit(
        TaskActionSuccess(
          action: TaskAction.created,
          message: null,
          taskId: task.id,
        ),
      );
    } on TaskRepositoryException catch (error) {
      emit(TaskError(message: error.message, cause: error));
    } catch (error) {
      emit(TaskError(message: '', cause: error));
    }
  }

  /// Actualiza una tarea existente.
  Future<void> updateTask(UpdateTaskInput input) async {
    emit(const TaskLoading());
    try {
      await _repository.updateTask(input);
      emit(const TaskActionSuccess(action: TaskAction.updated));
    } on TaskRepositoryException catch (error) {
      emit(TaskError(message: error.message, cause: error));
    } catch (error) {
      emit(TaskError(message: '', cause: error));
    }
  }

  /// Archiva una tarea.
  Future<void> archiveTask(String taskId) async {
    emit(const TaskLoading());
    try {
      await _repository.archiveTask(taskId);
      emit(
        const TaskActionSuccess(
          action: TaskAction.updated,
          message: 'Tarea archivada correctamente',
        ),
      );
    } on TaskRepositoryException catch (error) {
      emit(TaskError(message: error.message, cause: error));
    } catch (error) {
      emit(TaskError(message: '', cause: error));
    }
  }

  /// Elimina una tarea permanentemente.
  Future<void> deleteTask(String taskId) async {
    emit(const TaskLoading());
    try {
      await _repository.deleteTask(taskId);
      emit(const TaskActionSuccess(action: TaskAction.deleted));
    } on TaskRepositoryException catch (error) {
      emit(TaskError(message: error.message, cause: error));
    } catch (error) {
      emit(TaskError(message: '', cause: error));
    }
  }

  /// Asigna una tarea a una clase utilizando fan-out.
  Future<void> assignTaskToClass(AssignTaskInput input) async {
    emit(const TaskLoading());
    try {
      await _repository.assignTaskToClass(input);
      emit(const TaskActionSuccess(action: TaskAction.assigned));
    } on TaskRepositoryException catch (error) {
      emit(TaskError(message: error.message, cause: error));
    } catch (error) {
      emit(TaskError(message: '', cause: error));
    }
  }

  /// Observa en tiempo real todas las asignaciones de una tarea concreta.
  Stream<List<AssignmentModel>> watchTaskAssignments(
    String taskId, {
    String? teacherId,
  }) {
    return _repository.watchTaskAssignments(taskId, teacherId: teacherId);
  }

  /// Obtiene las asignaciones actuales de una tarea para una clase.
  Future<List<AssignmentModel>> getAssignmentsByTaskAndClass({
    required String taskId,
    required String classId,
    String? teacherId,
  }) async {
    return _repository.getAssignmentsByTaskAndClass(
      taskId: taskId,
      classId: classId,
      teacherId: teacherId,
    );
  }

  /// Cancela la suscripción al stream de tareas antes de cerrar el cubit.
  @override
  Future<void> close() async {
    await _tasksSubscription?.cancel();
    return super.close();
  }
}

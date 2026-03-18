import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/task_filters.dart';

/// Estados posibles del [TaskCubit] para la vista de docente.
sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial sin información cargada.
final class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Estado utilizado cuando se ejecutan operaciones de red o base de datos.
final class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Estado que representa ausencia de tareas disponibles.
final class TaskEmpty extends TaskState {
  const TaskEmpty({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Estado exitoso con la lista de tareas disponibles.
final class TaskSuccess extends TaskState {
  const TaskSuccess({required this.tasks, this.filters});

  /// Lista inmutable de tareas del docente.
  final List<TaskModel> tasks;

  /// Filtros activos cuando se recibió este estado.
  final TaskFilters? filters;

  @override
  List<Object?> get props => [tasks, filters];
}

/// Acciones que pueden reflejarse como éxito puntual.
enum TaskAction { created, updated, deleted, assigned }

/// Estado de éxito para operaciones puntuales (crear/actualizar/asignar).
final class TaskActionSuccess extends TaskState {
  const TaskActionSuccess({required this.action, this.message, this.taskId});

  /// Tipo de acción que se completó exitosamente.
  final TaskAction action;

  /// Mensaje opcional de confirmación para la UI.
  final String? message;

  /// ID de la tarea afectada (presente solo para [TaskAction.created]).
  final String? taskId;

  @override
  List<Object?> get props => [action, message, taskId];
}

/// Estado que encapsula errores de negocio o de infraestructura.
final class TaskError extends TaskState {
  const TaskError({this.message, this.cause});

  /// Mensaje legible para la UI.
  final String? message;

  /// Excepción original que provocó el error (para logging).
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

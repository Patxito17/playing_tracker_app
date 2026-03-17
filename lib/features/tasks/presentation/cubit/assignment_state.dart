import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/task_filters.dart';

/// Estados posibles del [AssignmentCubit] para la vista de alumno.
sealed class AssignmentState extends Equatable {
  const AssignmentState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial sin información cargada.
final class AssignmentInitial extends AssignmentState {
  const AssignmentInitial();
}

/// Estado utilizado cuando se ejecutan operaciones de red o base de datos.
final class AssignmentLoading extends AssignmentState {
  const AssignmentLoading();
}

/// Estado que representa ausencia de tareas asignadas.
final class AssignmentEmpty extends AssignmentState {
  const AssignmentEmpty({this.message = ''});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Estado exitoso con la lista de asignaciones disponibles.
final class AssignmentSuccess extends AssignmentState {
  const AssignmentSuccess({required this.assignments, this.filters});

  /// Lista inmutable de asignaciones del alumno.
  final List<AssignmentModel> assignments;

  /// Filtros activos cuando se recibió este estado.
  final TaskFilters? filters;

  @override
  List<Object?> get props => [assignments, filters];
}

/// Estado que encapsula errores de negocio o de infraestructura.
final class AssignmentError extends AssignmentState {
  const AssignmentError({required this.message, this.cause});

  /// Mensaje legible para la UI.
  final String message;

  /// Excepción original que provocó el error (para logging).
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

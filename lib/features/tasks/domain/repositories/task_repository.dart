import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/assign_task_input.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/create_task_input.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/task_filters.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/update_task_input.dart';

export 'package:playing_tracker/features/tasks/domain/value_objects/assign_task_input.dart';
export 'package:playing_tracker/features/tasks/domain/value_objects/create_task_input.dart';
export 'package:playing_tracker/features/tasks/domain/value_objects/task_filters.dart';
export 'package:playing_tracker/features/tasks/domain/value_objects/update_task_input.dart';

/// Contrato de dominio responsable de orquestar la lógica de tareas y
/// asignaciones.
///
/// Este repositorio actúa como capa anti-corrupción entre los Cubits y los
/// servicios de acceso a datos (Firestore, helpers de fan-out, etc.).
/// Ningún widget o Cubit debe comunicarse con servicios directamente.
abstract interface class TaskRepository {
  /// Crea una tarea asociada a un docente y retorna el modelo persistido.
  ///
  /// Implementación esperada:
  /// - Validar los campos del [CreateTaskInput].
  /// - Persistir en la colección `tasks`.
  /// - Devolver el [TaskModel] resultante con IDs y timestamps definitivos.
  Future<TaskModel> createTask(CreateTaskInput input);

  /// Actualiza una tarea existente con los campos indicados.
  ///
  /// La implementación debe:
  /// - Validar que exista la tarea.
  /// - Aplicar únicamente los campos presentes en [UpdateTaskInput].
  Future<void> updateTask(UpdateTaskInput input);

  /// Archiva una tarea existente (eliminación lógica).
  ///
  /// Establece `isActive = false` para que la tarea no aparezca en listas activas,
  /// pero mantiene los datos y asignaciones para histórico.
  Future<void> archiveTask(String taskId);

  /// Elimina una tarea permanentemente y todas sus asignaciones asociadas.
  ///
  /// Esta es una operación destructiva e irreversible.
  Future<void> deleteTask(String taskId);

  /// Observa en tiempo real las tareas creadas por un docente.
  ///
  /// Los filtros deben respetar las combinaciones soportadas por Firestore:
  /// - Docente: `createdBy + isActive + createdAt`
  /// - Docente: `createdBy + isActive + dueDate`
  Stream<List<TaskModel>> watchTeacherTasks(
    String teacherId, {
    TaskFilters? filters,
  });

  /// Observa en tiempo real las asignaciones de un alumno.
  ///
  /// Los filtros deben respetar las combinaciones soportadas por Firestore:
  /// - Alumno: `studentId + status + assignedAt`
  Stream<List<AssignmentModel>> watchStudentAssignments(
    String studentId, {
    TaskFilters? filters,
  });

  /// Observa en tiempo real las tareas asignadas a una clase (assignments).
  Stream<List<AssignmentModel>> watchClassAssignments(
    String classId, {
    String? teacherId,
    int limit,
  });

  /// Asigna una tarea a una clase concreta utilizando fan-out.
  ///
  /// La implementación real debe:
  /// - Validar que la tarea y la clase existan.
  /// - Delegar el fan-out en el helper correspondiente (Sprint 4 Fase 3).
  Future<void> assignTaskToClass(AssignTaskInput input);

  /// Obtiene una tarea específica por su identificador.
  ///
  /// Retorna `null` cuando la tarea no existe o el usuario no tiene permisos.
  Future<TaskModel?> getTaskById(String taskId);

  /// Obtiene una asignación específica por su identificador.
  ///
  /// Retorna `null` cuando la asignación no existe o el usuario no tiene
  /// permisos para consultarla.
  Future<AssignmentModel?> getAssignmentById(String assignmentId);
}

/// Excepción base del repositorio de tareas.
///
/// Esta jerarquía se utiliza para mapear errores de infraestructura (Firestore,
/// red, validaciones avanzadas) a mensajes de dominio legibles para la UI sin
/// exponer detalles sensibles.
sealed class TaskRepositoryException implements Exception {
  /// Crea una excepción de repositorio con un [message] legible y una
  /// [cause] opcional con el error original.
  const TaskRepositoryException(this.message, {this.cause});

  /// Mensaje human-readable (no exponer detalles sensibles a la UI).
  final String message;

  /// Excepción original u objeto asociado (opcional).
  final Object? cause;

  @override
  String toString() => 'TaskRepositoryException: $message';
}

/// Se lanza cuando una tarea solicitada no existe o no es accesible.
final class TaskNotFoundException extends TaskRepositoryException {
  /// Crea una excepción indicando que la tarea no fue encontrada.
  const TaskNotFoundException(super.message, {super.cause});
}

/// Se lanza cuando una asignación solicitada no existe o no es accesible.
final class AssignmentNotFoundException extends TaskRepositoryException {
  /// Crea una excepción indicando que la asignación no fue encontrada.
  const AssignmentNotFoundException(super.message, {super.cause});
}

/// Excepción genérica para errores no clasificados del repositorio.
final class UnknownTaskRepositoryException extends TaskRepositoryException {
  /// Crea una excepción genérica de repositorio de tareas.
  const UnknownTaskRepositoryException(super.message, {super.cause});
}

/// Excepción que indica parámetros inválidos al invocar métodos del repositorio.
final class InvalidTaskArgumentException extends TaskRepositoryException {
  /// Crea una excepción para argumentos inválidos en operaciones del
  /// repositorio de tareas.
  const InvalidTaskArgumentException(super.message, {super.cause});
}

import 'dart:developer';

import 'package:playing_tracker/features/classes/data/services/membership_service.dart';
import 'package:playing_tracker/features/tasks/data/services/assignment_service.dart';
import 'package:playing_tracker/features/tasks/data/services/task_service.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';

/// Contrato para helpers de fan-out.
abstract interface class FanOutHelperContract {
  Future<void> prepareFanOut(
    String taskId,
    String classId, {
    List<String>? studentIds,
  });

  Future<void> propagateToAssignments(String taskId, String classId);
}

/// Helper encargado de preparar y propagar el fan-out de tareas hacia
/// la colección `assignments`.
///
/// Durante el Sprint 3 únicamente registra logs y valida contratos para
/// dejar la infraestructura lista para el Sprint 4.
final class FanOutHelper implements FanOutHelperContract {
  /// Crea una instancia permitiendo inyectar dependencias para pruebas.
  FanOutHelper({
    MembershipServiceContract? membershipService,
    AssignmentServiceContract? assignmentService,
    TaskServiceContract? taskService,
  }) : _membershipService = membershipService ?? MembershipService(),
       _assignmentService = assignmentService ?? AssignmentService(),
       _taskService = taskService ?? TaskService();

  final MembershipServiceContract _membershipService;
  final AssignmentServiceContract _assignmentService;
  final TaskServiceContract _taskService;
  final Map<String, _FanOutContext> _pendingFanOuts = {};

  /// Prepara la información necesaria para un fan-out.
  ///
  /// Actualmente sólo valida los parámetros y registra logs explicativos.
  @override
  Future<void> prepareFanOut(
    String taskId,
    String classId, {
    List<String>? studentIds,
  }) async {
    _assertIds(taskId, classId);
    final task = await _taskService.getTaskById(taskId);
    if (task == null) {
      throw ArgumentError(
        'La tarea $taskId no existe o no está disponible para fan-out.',
      );
    }
    final allParams = await _membershipService.getStudentsForClass(classId);

    // Si se especifican studentIds, filtramos. Si es null/vacío, son todos.
    final targetIds = (studentIds != null && studentIds.isNotEmpty)
        ? allParams.where((id) => studentIds.contains(id)).toList()
        : allParams;

    final contextKey = _buildContextKey(taskId, classId);
    _pendingFanOuts[contextKey] = _FanOutContext(
      task: task,
      studentIds: targetIds,
      classId: classId,
    );
    log(
      'Fan-out preparado para tarea $taskId y clase $classId. '
      'Alumnos objetivo: ${targetIds.length} (de ${allParams.length} totales)',
      name: 'FanOutHelper',
    );
  }

  /// Propaga la tarea a los documentos `assignments`.
  ///
  /// Implementación pendiente hasta Sprint 4: únicamente registra el hook.
  @override
  Future<void> propagateToAssignments(String taskId, String classId) async {
    _assertIds(taskId, classId);
    final contextKey = _buildContextKey(taskId, classId);
    final context = _pendingFanOuts.remove(contextKey);
    if (context == null) {
      log(
        'No existe preparación previa para fan-out $taskId / $classId',
        name: 'FanOutHelper',
        level: 900, // warning
      );
      return;
    }
    if (context.studentIds.isEmpty) {
      log(
        'Fan-out omitido: la clase $classId no tiene alumnos activos.',
        name: 'FanOutHelper',
      );
      return;
    }
    final payloads = <AssignmentFanOutData>[
      for (final studentId in context.studentIds)
        (
          taskId: context.task.id,
          studentId: studentId,
          teacherId: context.task.createdBy,
          classId: context.classId,
          taskTitle: context.task.title,
          taskDescription: context.task.description,
          durationSuggested: context.task.durationSuggested,
        ),
    ];
    await _assignmentService.createAssignmentsBatch(payloads);
    log(
      'Fan-out completado: ${payloads.length} assignments creadas para '
      'task $taskId / class $classId',
      name: 'FanOutHelper',
    );
  }

  void _assertIds(String taskId, String classId) {
    if (taskId.trim().isEmpty) {
      throw ArgumentError('El identificador de la tarea es obligatorio');
    }
    if (classId.trim().isEmpty) {
      throw ArgumentError('El identificador de la clase es obligatorio');
    }
  }

  String _buildContextKey(String taskId, String classId) =>
      '${taskId.trim()}|${classId.trim()}';
}

final class _FanOutContext {
  _FanOutContext({
    required this.task,
    required this.studentIds,
    required this.classId,
  });

  final TaskModel task;
  final List<String> studentIds;
  final String classId;
}

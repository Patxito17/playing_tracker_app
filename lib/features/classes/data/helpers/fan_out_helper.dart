import 'dart:developer';

import 'package:playing_tracker/features/classes/data/services/class_service.dart';
import 'package:playing_tracker/features/classes/data/services/membership_service.dart';
import 'package:playing_tracker/features/tasks/data/services/assignment_service.dart';
import 'package:playing_tracker/features/tasks/data/services/task_service.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
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
/// Dado un [taskId] y un [classId], obtiene los alumnos activos de la clase
/// y crea (o actualiza) un documento de asignación por alumno en Firestore.
final class FanOutHelper implements FanOutHelperContract {
  /// Crea una instancia permitiendo inyectar dependencias para pruebas.
  FanOutHelper({
    MembershipServiceContract? membershipService,
    AssignmentServiceContract? assignmentService,
    TaskServiceContract? taskService,
    ClassServiceContract? classService,
  }) : _membershipService = membershipService ?? MembershipService(),
       _assignmentService = assignmentService ?? AssignmentService(),
       _taskService = taskService ?? TaskService(),
       _classService = classService ?? ClassService();

  final MembershipServiceContract _membershipService;
  final AssignmentServiceContract _assignmentService;
  final TaskServiceContract _taskService;
  final ClassServiceContract _classService;
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

    final classModel = await _classService.getClassById(classId);
    if (classModel == null) {
      throw ArgumentError('La clase $classId no existe o no está disponible.');
    }

    final contextKey = _buildContextKey(taskId, classId);
    _pendingFanOuts[contextKey] = _FanOutContext(
      task: task,
      studentIds: targetIds,
      classId: classId,
      className: classModel.name,
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

    // 1. Obtener asignaciones actuales para identificar desasignaciones
    List<AssignmentModel> currentAssignments = [];
    try {
      currentAssignments = await _assignmentService
          .getAssignmentsByTaskAndClass(
            taskId: taskId,
            classId: classId,
            teacherId: context.task.createdBy,
          );
    } catch (e) {
      log(
        'FanOutHelper: Error no crítico recuperando asignaciones actuales: $e',
        name: 'FanOutHelper',
        level: 900,
      );
    }

    final currentStudentIds = currentAssignments
        .map((a) => a.studentId)
        .toSet();
    final targetStudentIds = context.studentIds.toSet();

    // 2. Eliminar alumnos que ya no están en la lista (desasignación)
    final studentsToRemove = currentStudentIds.difference(targetStudentIds);
    if (studentsToRemove.isNotEmpty) {
      try {
        await _assignmentService.deleteSpecificAssignments(
          taskId: taskId,
          classId: classId,
          studentIds: studentsToRemove.toList(),
        );
      } catch (e) {
        log(
          'FanOutHelper: Error eliminando asignaciones antiguas: $e',
          name: 'FanOutHelper',
          level: 900,
        );
      }
    }

    // 3. Crear o actualizar asignaciones para los seleccionados
    if (context.studentIds.isEmpty) {
      log(
        'Fan-out omitido: no hay alumnos seleccionados para la clase $classId.',
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
          className: context.className,
          taskTitle: context.task.title,
          taskDescription: context.task.description,
          durationSuggested: context.task.durationSuggested,
          dueDate: context.task.dueDate,
          // Si el alumno NO tenía la tarea asignada previamente, establecemos status: pending.
          // Si YA la tenía, enviamos status: null para NO sobreescribir su progreso real.
          status: currentStudentIds.contains(studentId)
              ? null
              : TaskStatus.pending,
        ),
    ];
    await _assignmentService.createAssignmentsBatch(payloads);
    log(
      'Fan-out completado: ${payloads.length} assignments procesadas para '
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
    required this.className,
  });

  final TaskModel task;
  final List<String> studentIds;
  final String classId;
  final String className;
}

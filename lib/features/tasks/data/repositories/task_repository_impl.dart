import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/classes/data/helpers/fan_out_helper.dart';
import 'package:playing_tracker/features/tasks/data/services/assignment_service.dart';
import 'package:playing_tracker/features/tasks/data/services/task_service.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';

/// Implementación concreta de [TaskRepository] que orquesta servicios de
/// Firestore y el helper de fan-out respetando la arquitectura
/// Domain → Repository → Service.
final class TaskRepositoryImpl implements TaskRepository {
  /// Crea una instancia con dependencias inyectables para facilitar las pruebas.
  TaskRepositoryImpl({
    TaskServiceContract? taskService,
    AssignmentServiceContract? assignmentService,
    FanOutHelperContract? fanOutHelper,
  }) : _taskService = taskService ?? TaskService(),
       _assignmentService = assignmentService ?? AssignmentService(),
       _fanOutHelper = fanOutHelper ?? FanOutHelper();

  final TaskServiceContract _taskService;
  final AssignmentServiceContract _assignmentService;
  final FanOutHelperContract _fanOutHelper;

  @override
  Future<TaskModel> createTask(CreateTaskInput input) async {
    validateCreateTaskInput(input);
    try {
      return await _taskService.createTask(input);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'createTask',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible crear la tarea.',
      );
    }
  }

  @override
  Future<void> updateTask(UpdateTaskInput input) async {
    validateUpdateTaskInput(input);
    try {
      // 1. Actualizar la tarea
      await _taskService.updateTask(input);

      // 2. Si se está cambiando el campo isActive, propagar el cambio a las asignaciones
      if (input.isActive != null) {
        // Obtener la tarea para conocer el teacherId
        final task = await _taskService.getTaskById(input.taskId);
        final teacherId = task?.createdBy;

        // Propagar el cambio a todas las asignaciones de esta tarea
        await _assignmentService.updateAssignmentsIsActiveByTaskId(
          input.taskId,
          input.isActive!,
          teacherId: teacherId,
        );
      }
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'updateTask',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible actualizar la tarea.',
      );
    }
  }

  @override
  Future<void> archiveTask(String taskId) async {
    final sanitizedId = taskId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidTaskArgumentException(
        'El identificador de la tarea es obligatorio',
      );
    }
    try {
      await _taskService.deleteTask(sanitizedId, hardDelete: false);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'archiveTask',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible archivar la tarea.',
      );
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final sanitizedId = taskId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidTaskArgumentException(
        'El identificador de la tarea es obligatorio',
      );
    }
    try {
      // 1. Obtener la tarea para conocer el dueño (teacherId)
      // Esto es necesario para filtrar las asignaciones y eliminar solo las propias,
      // cumpliendo con las reglas de seguridad de Firestore ("Rules are not filters").
      final task = await _taskService.getTaskById(sanitizedId);
      final teacherId = task?.createdBy;

      // 2. Eliminación física de todas las asignaciones asociadas (si se encontró el owner)
      // Lo hacemos ANTES de borrar la tarea para evitar inconsistencias si esto falla,
      // aunque es una preferencia de diseño (limpiar hijos primero).
      await _assignmentService.deleteAssignmentsByTaskId(
        sanitizedId,
        teacherId: teacherId,
      );

      // 3. Eliminación física de la tarea
      await _taskService.deleteTask(sanitizedId, hardDelete: true);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'deleteTask',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible eliminar la tarea.',
      );
    }
  }

  @override
  Stream<List<TaskModel>> watchTeacherTasks(
    String teacherId, {
    TaskFilters? filters,
  }) {
    final normalizedId = teacherId.trim();
    if (normalizedId.isEmpty) {
      return Stream<List<TaskModel>>.error(
        const InvalidTaskArgumentException(
          'El identificador del docente es obligatorio',
        ),
      );
    }
    if (filters != null) {
      try {
        validateTaskFilters(filters);
      } on ArgumentError catch (error) {
        return Stream<List<TaskModel>>.error(
          InvalidTaskArgumentException(error.message, cause: error),
        );
      }
    }

    final stream = _taskService.watchTeacherTasks(
      teacherId: normalizedId,
      filters: filters,
      limit: _defaultPaginationLimit,
    );
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (tasks, sink) => sink.add(tasks),
        handleError: (error, stackTrace, sink) {
          final mapped = _mapToRepositoryException(
            method: 'watchTeacherTasks',
            error: error,
            fallbackMessage: 'No fue posible cargar las tareas del docente.',
          );
          sink.addError(mapped, stackTrace);
        },
      ),
    );
  }

  @override
  Stream<List<AssignmentModel>> watchStudentAssignments(
    String studentId, {
    TaskFilters? filters,
  }) {
    final normalizedId = studentId.trim();
    if (normalizedId.isEmpty) {
      return Stream<List<AssignmentModel>>.error(
        const InvalidTaskArgumentException(
          'El identificador del alumno es obligatorio',
        ),
      );
    }
    if (filters != null) {
      try {
        validateTaskFilters(filters);
      } on ArgumentError catch (error) {
        return Stream<List<AssignmentModel>>.error(
          InvalidTaskArgumentException(error.message, cause: error),
        );
      }
    }

    final stream = _assignmentService.watchStudentAssignments(
      studentId: normalizedId,
      filters: filters,
      limit: _defaultPaginationLimit,
    );
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (assignments, sink) => sink.add(assignments),
        handleError: (error, stackTrace, sink) {
          final mapped = _mapToRepositoryException(
            method: 'watchStudentAssignments',
            error: error,
            fallbackMessage: 'No fue posible cargar tus tareas asignadas.',
          );
          sink.addError(mapped, stackTrace);
        },
      ),
    );
  }

  @override
  Stream<List<AssignmentModel>> watchClassAssignments(
    String classId, {
    String? teacherId,
    int limit = _defaultPaginationLimit,
  }) {
    final normalizedId = classId.trim();
    if (normalizedId.isEmpty) {
      return Stream<List<AssignmentModel>>.error(
        const InvalidTaskArgumentException(
          'El identificador de la clase es obligatorio',
        ),
      );
    }
    final stream = _assignmentService.watchClassAssignments(
      classId: normalizedId,
      teacherId: teacherId,
      limit: limit,
    );
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (assignments, sink) => sink.add(assignments),
        handleError: (error, stackTrace, sink) {
          final mapped = _mapToRepositoryException(
            method: 'watchClassAssignments',
            error: error,
            fallbackMessage: 'No fue posible cargar las tareas asignadas.',
          );
          sink.addError(mapped, stackTrace);
        },
      ),
    );
  }

  @override
  Future<void> assignTaskToClass(AssignTaskInput input) async {
    validateAssignTaskInput(input);
    try {
      await _fanOutHelper.prepareFanOut(
        input.taskId,
        input.classId,
        studentIds: input.studentIds,
      );
      await _fanOutHelper.propagateToAssignments(input.taskId, input.classId);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'assignTaskToClass',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible asignar la tarea a la clase.',
      );
    }
  }

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    final sanitizedId = taskId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidTaskArgumentException(
        'El identificador de la tarea es obligatorio',
      );
    }
    try {
      return await _taskService.getTaskById(sanitizedId);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getTaskById',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible obtener la tarea solicitada.',
      );
    }
  }

  @override
  Future<AssignmentModel?> getAssignmentById(String assignmentId) async {
    final sanitizedId = assignmentId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidTaskArgumentException(
        'El identificador de la asignación es obligatorio',
      );
    }
    try {
      return await _assignmentService.getAssignmentById(sanitizedId);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getAssignmentById',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible obtener la asignación solicitada.',
      );
    }
  }

  Never _throwRepositoryException({
    required String method,
    required Object error,
    required String fallbackMessage,
    StackTrace? stackTrace,
  }) {
    log(
      'TaskRepositoryImpl#$method error',
      error: error,
      stackTrace: stackTrace,
    );
    if (error is TaskRepositoryException) {
      throw error;
    }
    if (error is FirebaseErrorMapperException) {
      throw UnknownTaskRepositoryException(error.message, cause: error);
    }
    if (error is FirebaseException) {
      final message = FirebaseErrorMapper.map(error);
      throw UnknownTaskRepositoryException(message, cause: error);
    }
    throw UnknownTaskRepositoryException(fallbackMessage, cause: error);
  }

  TaskRepositoryException _mapToRepositoryException({
    required String method,
    required Object error,
    required String fallbackMessage,
  }) {
    TaskRepositoryException mapped = UnknownTaskRepositoryException(
      fallbackMessage,
      cause: error,
    );
    try {
      _throwRepositoryException(
        method: method,
        error: error,
        fallbackMessage: fallbackMessage,
      );
    } on TaskRepositoryException catch (repositoryException) {
      mapped = repositoryException;
    }
    return mapped;
  }
}

const _defaultPaginationLimit = 50;

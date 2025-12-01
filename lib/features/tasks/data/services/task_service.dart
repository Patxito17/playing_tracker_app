import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/create_task_input.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/task_filters.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/update_task_input.dart';

/// Contrato para interactuar con la colección `tasks` de Firestore.
abstract interface class TaskServiceContract {
  Future<TaskModel> createTask(CreateTaskInput input);

  Future<void> updateTask(UpdateTaskInput input);

  Future<void> deleteTask(String taskId, {bool hardDelete = false});

  Stream<List<TaskModel>> watchTeacherTasks({
    required String teacherId,
    TaskFilters? filters,
    int limit,
  });

  Future<TaskModel?> getTaskById(String taskId);
}

/// Servicio dedicado a operaciones CRUD de tareas en Firestore.
final class TaskService implements TaskServiceContract {
  TaskService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection(_tasksCollectionName);

  @override
  Future<TaskModel> createTask(CreateTaskInput input) async {
    validateCreateTaskInput(input);
    try {
      final docRef = _tasksCollection.doc();
      final payload = <String, dynamic>{
        'id': docRef.id,
        'title': input.title.trim(),
        'description': input.description?.trim(),
        'createdBy': input.createdBy.trim(),
        'durationSuggested': input.durationSuggested,
        'attachments': input.attachments
            .map((attachment) => attachment.toJson())
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'dueDate': input.dueDate != null
            ? Timestamp.fromDate(input.dueDate!)
            : null,
        'isActive': true,
      };
      await docRef.set(payload);
      final snapshot = await docRef.get();
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (error, stackTrace) {
      _logError('createTask', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> updateTask(UpdateTaskInput input) async {
    validateUpdateTaskInput(input);
    final taskId = input.taskId.trim();
    if (taskId.isEmpty) {
      throw ArgumentError('El identificador de la tarea es obligatorio');
    }
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (input.title != null) {
      updates['title'] = input.title!.trim();
    }
    if (input.description != null) {
      updates['description'] = input.description!.trim();
    }
    if (input.durationSuggested != null) {
      updates['durationSuggested'] = input.durationSuggested;
    }
    if (input.attachments != null) {
      updates['attachments'] = input.attachments!
          .map((attachment) => attachment.toJson())
          .toList();
    }
    if (input.dueDate != null) {
      updates['dueDate'] = Timestamp.fromDate(input.dueDate!);
    }
    if (input.isActive != null) {
      updates['isActive'] = input.isActive;
    }
    try {
      await _tasksCollection.doc(taskId).update(updates);
    } on FirebaseException catch (error, stackTrace) {
      _logError('updateTask', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> deleteTask(String taskId, {bool hardDelete = false}) async {
    final sanitizedId = taskId.trim();
    if (sanitizedId.isEmpty) {
      throw ArgumentError('El identificador de la tarea es obligatorio');
    }
    try {
      if (hardDelete) {
        await _tasksCollection.doc(sanitizedId).delete();
        return;
      }
      await _tasksCollection.doc(sanitizedId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error, stackTrace) {
      _logError('deleteTask', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Stream<List<TaskModel>> watchTeacherTasks({
    required String teacherId,
    TaskFilters? filters,
    int limit = _defaultPaginationLimit,
  }) {
    final trimmedTeacherId = teacherId.trim();
    if (trimmedTeacherId.isEmpty) {
      return Stream<List<TaskModel>>.error(
        ArgumentError('El identificador del docente es obligatorio'),
      );
    }
    if (filters != null) {
      validateTaskFilters(filters);
    }
    Query<Map<String, dynamic>> query = _tasksCollection.where(
      'createdBy',
      isEqualTo: trimmedTeacherId,
    );

    if (filters?.isActive != null) {
      query = query.where('isActive', isEqualTo: filters!.isActive);
    }

    final usesCreatedRange =
        filters?.createdFrom != null || filters?.createdTo != null;
    final usesDueRange = filters?.dueFrom != null || filters?.dueTo != null;

    if (usesCreatedRange) {
      if (filters?.createdFrom != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filters!.createdFrom!),
        );
      }
      if (filters?.createdTo != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(filters!.createdTo!),
        );
      }
      query = query.orderBy('createdAt', descending: true);
    } else if (usesDueRange) {
      if (filters?.dueFrom != null) {
        query = query.where(
          'dueDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filters!.dueFrom!),
        );
      }
      if (filters?.dueTo != null) {
        query = query.where(
          'dueDate',
          isLessThanOrEqualTo: Timestamp.fromDate(filters!.dueTo!),
        );
      }
      query = query.orderBy('dueDate', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(_mapSnapshot).toList(),
    );
  }

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    final sanitizedId = taskId.trim();
    if (sanitizedId.isEmpty) {
      throw ArgumentError('El identificador de la tarea es obligatorio');
    }
    try {
      final snapshot = await _tasksCollection.doc(sanitizedId).get();
      if (!snapshot.exists) {
        return null;
      }
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (error, stackTrace) {
      _logError('getTaskById', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  TaskModel _mapSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw FirebaseErrorMapperException(
        'La tarea solicitada no contiene datos.',
      );
    }
    data['id'] = data['id'] ?? snapshot.id;
    data['createdAt'] = data['createdAt'] ?? Timestamp.fromDate(DateTime.now());
    data['updatedAt'] =
        data['updatedAt'] ??
        data['createdAt'] ??
        Timestamp.fromDate(DateTime.now());
    data['attachments'] =
        (data['attachments'] as List?)
            ?.map((attachment) => attachment as Map<String, dynamic>)
            .toList() ??
        const <Map<String, dynamic>>[];
    return TaskModel.fromJson(data);
  }

  void _logError(
    String method,
    FirebaseException error,
    StackTrace stackTrace,
  ) {
    log(
      'TaskService#$method FirebaseException: ${error.code}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

const _tasksCollectionName = 'tasks';
const _defaultPaginationLimit = 50;

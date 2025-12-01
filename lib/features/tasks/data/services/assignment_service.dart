import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/task_filters.dart';

/// Datos necesarios para crear asignaciones durante un fan-out.
typedef AssignmentFanOutData = ({
  String taskId,
  String studentId,
  String teacherId,
  String classId,
  String taskTitle,
  int durationSuggested,
});

/// Contrato para interactuar con la colección `assignments`.
abstract interface class AssignmentServiceContract {
  Future<void> createAssignmentsBatch(List<AssignmentFanOutData> assignments);

  Stream<List<AssignmentModel>> watchStudentAssignments({
    required String studentId,
    TaskFilters? filters,
    int limit,
  });

  Future<AssignmentModel?> getAssignmentById(String assignmentId);
}

/// Servicio centrado en operaciones de la colección `assignments`.
final class AssignmentService implements AssignmentServiceContract {
  AssignmentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _assignmentsCollection =>
      _firestore.collection(_assignmentsCollectionName);

  @override
  Future<void> createAssignmentsBatch(
    List<AssignmentFanOutData> assignments,
  ) async {
    if (assignments.isEmpty) {
      return;
    }
    try {
      final chunks = _chunkAssignments(assignments, _batchWriteLimit);
      for (final chunk in chunks) {
        final batch = _firestore.batch();
        for (final assignment in chunk) {
          final assignmentId = AssignmentModel.generateId(
            assignment.taskId,
            assignment.studentId,
          );
          final docRef = _assignmentsCollection.doc(assignmentId);
          batch.set(docRef, {
            'id': assignmentId,
            'taskId': assignment.taskId,
            'studentId': assignment.studentId,
            'teacherId': assignment.teacherId,
            'classId': assignment.classId,
            'taskTitle': assignment.taskTitle,
            'durationSuggested': assignment.durationSuggested,
            'status': _statusToJson(TaskStatus.pending),
            'assignedAt': FieldValue.serverTimestamp(),
            'completedAt': null,
            'sessionsCount': 0,
            'totalDurationLogged': 0,
            'lastSessionDate': null,
          }, SetOptions(merge: false));
        }
        await batch.commit();
      }
    } on FirebaseException catch (error, stackTrace) {
      _logError('createAssignmentsBatch', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Stream<List<AssignmentModel>> watchStudentAssignments({
    required String studentId,
    TaskFilters? filters,
    int limit = _defaultPaginationLimit,
  }) {
    final normalizedId = studentId.trim();
    if (normalizedId.isEmpty) {
      return Stream<List<AssignmentModel>>.error(
        ArgumentError('El identificador del alumno es obligatorio'),
      );
    }
    Query<Map<String, dynamic>> query = _assignmentsCollection.where(
      'studentId',
      isEqualTo: normalizedId,
    );

    if (filters?.status != null) {
      query = query.where('status', isEqualTo: _statusToJson(filters!.status!));
    }

    if (filters?.assignedFrom != null) {
      query = query.where(
        'assignedAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(filters!.assignedFrom!),
      );
    }
    if (filters?.assignedTo != null) {
      query = query.where(
        'assignedAt',
        isLessThanOrEqualTo: Timestamp.fromDate(filters!.assignedTo!),
      );
    }

    query = query.orderBy('assignedAt', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(_mapSnapshot).toList(),
    );
  }

  @override
  Future<AssignmentModel?> getAssignmentById(String assignmentId) async {
    final sanitizedId = assignmentId.trim();
    if (sanitizedId.isEmpty) {
      throw ArgumentError('El identificador de la asignación es obligatorio');
    }
    try {
      final snapshot = await _assignmentsCollection.doc(sanitizedId).get();
      if (!snapshot.exists) {
        return null;
      }
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (error, stackTrace) {
      _logError('getAssignmentById', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  Iterable<List<AssignmentFanOutData>> _chunkAssignments(
    List<AssignmentFanOutData> assignments,
    int size,
  ) sync* {
    for (var i = 0; i < assignments.length; i += size) {
      final end = (i + size).clamp(0, assignments.length).toInt();
      yield assignments.sublist(i, end);
    }
  }

  AssignmentModel _mapSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw FirebaseErrorMapperException(
        'La asignación solicitada no contiene datos.',
      );
    }
    data['id'] = data['id'] ?? snapshot.id;
    data['assignedAt'] =
        data['assignedAt'] ?? Timestamp.fromDate(DateTime.now());
    return AssignmentModel.fromJson(data);
  }

  String _statusToJson(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => 'pending',
      TaskStatus.inProgress => 'in_progress',
      TaskStatus.completed => 'completed',
    };
  }

  void _logError(
    String method,
    FirebaseException error,
    StackTrace stackTrace,
  ) {
    log(
      'AssignmentService#$method FirebaseException: ${error.code}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

const _assignmentsCollectionName = 'assignments';
const _batchWriteLimit = 500;
const _defaultPaginationLimit = 50;

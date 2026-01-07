import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/tasks/data/services/assignment_service.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/task_filters.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AssignmentService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = AssignmentService(firestore: fakeFirestore);
  });

  test(
    'createAssignmentsBatch crea documentos para todos los alumnos',
    () async {
      final assignments = <AssignmentFanOutData>[
        (
          taskId: 'task-1',
          studentId: 'student-1',
          teacherId: 'teacher-1',
          classId: 'class-1',
          taskTitle: 'Escalas',
          taskDescription: 'Descripción 1',
          durationSuggested: 900,
        ),
        (
          taskId: 'task-1',
          studentId: 'student-2',
          teacherId: 'teacher-1',
          classId: 'class-1',
          taskTitle: 'Escalas',
          taskDescription: 'Descripción 1',
          durationSuggested: 900,
        ),
      ];

      await service.createAssignmentsBatch(assignments);

      final snapshot = await fakeFirestore.collection('assignments').get();
      expect(snapshot.docs.length, 2);
      expect(snapshot.docs.first.data()['taskTitle'], 'Escalas');
    },
  );

  test('watchStudentAssignments filtra por estado y rango de fechas', () async {
    final collection = fakeFirestore.collection('assignments');
    await collection.doc('a1').set({
      'id': 'a1',
      'taskId': 'task-1',
      'studentId': 'student-1',
      'classId': 'class-1',
      'teacherId': 'teacher-1',
      'taskTitle': 'Escalas',
      'durationSuggested': 900,
      'status': 'pending',
      'assignedAt': Timestamp.fromDate(DateTime(2025, 1, 5)),
      'sessionsCount': 0,
      'totalDurationLogged': 0,
    });
    await collection.doc('a2').set({
      'id': 'a2',
      'taskId': 'task-2',
      'studentId': 'student-1',
      'classId': 'class-1',
      'teacherId': 'teacher-1',
      'taskTitle': 'Arpegios',
      'durationSuggested': 600,
      'status': 'completed',
      'assignedAt': Timestamp.fromDate(DateTime(2024, 12, 20)),
      'sessionsCount': 0,
      'totalDurationLogged': 0,
    });

    final TaskFilters filters = (
      isActive: null,
      createdFrom: null,
      createdTo: null,
      dueFrom: null,
      dueTo: null,
      status: TaskStatus.pending,
      assignedFrom: DateTime(2025, 1, 1),
      assignedTo: DateTime(2025, 1, 31),
    );

    final stream = service.watchStudentAssignments(
      studentId: 'student-1',
      filters: filters,
    );

    await expectLater(
      stream,
      emits(
        predicate<List<AssignmentModel>>(
          (assignments) =>
              assignments.length == 1 && assignments.first.id == 'a1',
        ),
      ),
    );
  });

  test('getAssignmentById devuelve AssignmentModel cuando existe', () async {
    final docRef = fakeFirestore.collection('assignments').doc('a3');
    final now = Timestamp.now();
    await docRef.set({
      'id': 'a3',
      'taskId': 'task-3',
      'studentId': 'student-9',
      'classId': 'class-9',
      'teacherId': 'teacher-3',
      'taskTitle': 'Lectura',
      'durationSuggested': 1200,
      'status': 'pending',
      'assignedAt': now,
      'sessionsCount': 0,
      'totalDurationLogged': 0,
    });

    final assignment = await service.getAssignmentById('a3');

    expect(assignment, isNotNull);
    expect(assignment!.taskId, 'task-3');
  });
}

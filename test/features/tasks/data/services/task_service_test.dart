import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/tasks/data/services/task_service.dart';
import 'package:playing_tracker/features/tasks/domain/enums/attachment_type.dart';
import 'package:playing_tracker/features/tasks/domain/models/attachment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TaskService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = TaskService(firestore: fakeFirestore);
  });

  test('createTask persiste una tarea y retorna el modelo', () async {
    final input = (
      title: 'Escalas mayores',
      description: 'Practicar escalas en dos octavas',
      createdBy: 'teacher-1',
      durationSuggested: 1800,
      attachments: <AttachmentModel>[
        AttachmentModel(
          name: 'Partitura',
          url: 'https://storage.test/score.pdf',
          type: AttachmentType.pdf,
        ),
      ],
      dueDate: DateTime(2025, 1, 10),
    );

    final task = await service.createTask(input);

    final stored = await fakeFirestore.collection('tasks').doc(task.id).get();
    expect(stored.exists, isTrue);
    expect(stored.data()?['title'], 'Escalas mayores');
    expect(task.createdBy, 'teacher-1');
  });

  test('updateTask actualiza únicamente los campos provistos', () async {
    final docRef = fakeFirestore.collection('tasks').doc('task-1');
    final now = Timestamp.now();
    await docRef.set({
      'id': 'task-1',
      'title': 'Viejo título',
      'createdBy': 'teacher-1',
      'durationSuggested': 1200,
      'attachments': [],
      'createdAt': now,
      'updatedAt': now,
      'isActive': true,
    });

    final input = (
      taskId: 'task-1',
      title: 'Nuevo título',
      description: null,
      durationSuggested: 2400,
      attachments: null,
      dueDate: null,
      isActive: null,
    );

    await service.updateTask(input);

    final updated = await docRef.get();
    expect(updated.data()?['title'], 'Nuevo título');
    expect(updated.data()?['durationSuggested'], 2400);
  });

  test('watchTeacherTasks respeta filtros por createdAt', () async {
    final collection = fakeFirestore.collection('tasks');
    await collection.doc('task-1').set({
      'id': 'task-1',
      'title': 'Tarea reciente',
      'createdBy': 'teacher-1',
      'durationSuggested': 600,
      'attachments': [],
      'createdAt': Timestamp.fromDate(DateTime(2025, 1, 5)),
      'updatedAt': Timestamp.fromDate(DateTime(2025, 1, 5)),
      'isActive': true,
    });
    await collection.doc('task-2').set({
      'id': 'task-2',
      'title': 'Tarea antigua',
      'createdBy': 'teacher-1',
      'durationSuggested': 900,
      'attachments': [],
      'createdAt': Timestamp.fromDate(DateTime(2024, 12, 20)),
      'updatedAt': Timestamp.fromDate(DateTime(2024, 12, 20)),
      'isActive': true,
    });

    final filters = (
      isActive: true,
      createdFrom: DateTime(2025, 1, 1),
      createdTo: DateTime(2025, 1, 31),
      dueFrom: null,
      dueTo: null,
      status: null,
      assignedFrom: null,
      assignedTo: null,
    );

    final stream = service.watchTeacherTasks(
      teacherId: 'teacher-1',
      filters: filters,
    );

    await expectLater(
      stream,
      emits(
        predicate<List<TaskModel>>(
          (tasks) => tasks.length == 1 && tasks.first.id == 'task-1',
        ),
      ),
    );
  });
}

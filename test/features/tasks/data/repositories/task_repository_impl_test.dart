import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/classes/data/helpers/fan_out_helper.dart';
import 'package:playing_tracker/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:playing_tracker/features/tasks/data/services/assignment_service.dart';
import 'package:playing_tracker/features/tasks/data/services/task_service.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/attachment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';

class _MockTaskService extends Mock implements TaskServiceContract {}

class _MockAssignmentService extends Mock
    implements AssignmentServiceContract {}

class _MockFanOutHelper extends Mock implements FanOutHelperContract {}

void main() {
  late TaskRepositoryImpl repository;
  late _MockTaskService taskService;
  late _MockAssignmentService assignmentService;
  late _MockFanOutHelper fanOutHelper;

  setUpAll(() {
    registerFallbackValue(_createTaskInput());
    registerFallbackValue(_filters());
    registerFallbackValue(_assignInput());
  });

  setUp(() {
    taskService = _MockTaskService();
    assignmentService = _MockAssignmentService();
    fanOutHelper = _MockFanOutHelper();
    repository = TaskRepositoryImpl(
      taskService: taskService,
      assignmentService: assignmentService,
      fanOutHelper: fanOutHelper,
    );
  });

  test('createTask delega en TaskService y retorna el modelo', () async {
    final expected = _taskModel();
    when(() => taskService.createTask(any())).thenAnswer((_) async => expected);

    final result = await repository.createTask(_createTaskInput());

    expect(result, equals(expected));
    verify(() => taskService.createTask(any())).called(1);
  });

  test(
    'watchTeacherTasks emite los valores del servicio sin transformaciones',
    () async {
      final controller = StreamController<List<TaskModel>>();
      when(
        () => taskService.watchTeacherTasks(
          teacherId: any(named: 'teacherId'),
          filters: any(named: 'filters'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => controller.stream);

      final resultStream = repository.watchTeacherTasks(
        'teacher-1',
        filters: _filters(),
      );

      final expectation = expectLater(
        resultStream,
        emits(isA<List<TaskModel>>()),
      );
      controller.add([_taskModel()]);
      await controller.close();
      await expectation;
      verify(
        () => taskService.watchTeacherTasks(
          teacherId: 'teacher-1',
          filters: any(named: 'filters'),
          limit: any(named: 'limit'),
        ),
      ).called(1);
    },
  );

  test(
    'watchTeacherTasks mapea errores a UnknownTaskRepositoryException',
    () async {
      final controller = StreamController<List<TaskModel>>();
      when(
        () => taskService.watchTeacherTasks(
          teacherId: any(named: 'teacherId'),
          filters: any(named: 'filters'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => controller.stream);

      final resultStream = repository.watchTeacherTasks('teacher-1');
      final expectation = expectLater(
        resultStream,
        emitsError(isA<UnknownTaskRepositoryException>()),
      );
      controller.addError(FirebaseErrorMapperException('boom'));
      await controller.close();
      await expectation;
    },
  );

  test('assignTaskToClass delega en FanOutHelper', () async {
    when(
      () => fanOutHelper.prepareFanOut(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => fanOutHelper.propagateToAssignments(any(), any()),
    ).thenAnswer((_) async {});

    await repository.assignTaskToClass(_assignInput());

    verify(() => fanOutHelper.prepareFanOut('task-1', 'class-1')).called(1);
    verify(
      () => fanOutHelper.propagateToAssignments('task-1', 'class-1'),
    ).called(1);
  });

  test(
    'watchStudentAssignments emite los valores del servicio sin transformaciones',
    () async {
      final controller = StreamController<List<AssignmentModel>>();
      when(
        () => assignmentService.watchStudentAssignments(
          studentId: any(named: 'studentId'),
          filters: any(named: 'filters'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => controller.stream);

      final resultStream = repository.watchStudentAssignments(
        'student-1',
        filters: _filters(),
      );

      final expectation = expectLater(
        resultStream,
        emits(isA<List<AssignmentModel>>()),
      );
      controller.add([_assignmentModel()]);
      await controller.close();
      await expectation;
      verify(
        () => assignmentService.watchStudentAssignments(
          studentId: 'student-1',
          filters: any(named: 'filters'),
          limit: any(named: 'limit'),
        ),
      ).called(1);
    },
  );
}

CreateTaskInput _createTaskInput() => (
  title: 'Escalas',
  description: 'Practicar escalas',
  createdBy: 'teacher-1',
  durationSuggested: 1800,
  attachments: <AttachmentModel>[],
  dueDate: DateTime(2025, 1, 1),
);

TaskFilters _filters() => (
  isActive: true,
  createdFrom: DateTime(2025, 1, 1),
  createdTo: DateTime(2025, 1, 31),
  dueFrom: null,
  dueTo: null,
  status: null,
  assignedFrom: null,
  assignedTo: null,
);

AssignTaskInput _assignInput() => (
  taskId: 'task-1',
  classId: 'class-1',
  teacherId: 'teacher-1',
  studentIds: null,
);

TaskModel _taskModel() {
  final now = Timestamp.now();
  return TaskModel(
    id: 'task-1',
    title: 'Escalas',
    description: 'Practicar escalas',
    createdBy: 'teacher-1',
    durationSuggested: 1800,
    attachments: const [],
    createdAt: now,
    updatedAt: now,
    dueDate: null,
    isActive: true,
  );
}

AssignmentModel _assignmentModel() {
  final now = Timestamp.now();
  return AssignmentModel(
    id: 'a1',
    taskId: 'task-1',
    studentId: 'student-1',
    classId: 'class-1',
    teacherId: 'teacher-1',
    taskTitle: 'Escalas',
    durationSuggested: 900,
    status: TaskStatus.pending,
    assignedAt: now,
    completedAt: null,
    sessionsCount: 0,
    totalDurationLogged: 0,
    lastSessionDate: null,
    isActive: true,
  );
}

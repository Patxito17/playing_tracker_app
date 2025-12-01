import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/attachment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/assign_task_input.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/create_task_input.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/task_filters.dart';
import 'package:playing_tracker/features/tasks/domain/value_objects/update_task_input.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockTaskRepository repository;

  setUpAll(() {
    registerFallbackValue(
      (
        title: 'Título demo',
        description: 'Descripción demo',
        createdBy: 'teacher-1',
        durationSuggested: 1800,
        attachments: <AttachmentModel>[],
        dueDate: DateTime(2025, 1, 1),
      ),
    );

    registerFallbackValue(
      (
        taskId: 'task-1',
        title: 'Nuevo título',
        description: 'Nueva descripción',
        durationSuggested: 1200,
        attachments: <AttachmentModel>[],
        dueDate: DateTime(2025, 2, 1),
        isActive: true,
      ),
    );

    registerFallbackValue(
      (
        taskId: 'task-1',
        classId: 'class-1',
        teacherId: 'teacher-1',
      ),
    );

    registerFallbackValue(
      (
        isActive: true,
        createdFrom: DateTime(2025, 1, 1),
        createdTo: DateTime(2025, 1, 31),
        dueFrom: null,
        dueTo: null,
        status: TaskStatus.pending,
        assignedFrom: null,
        assignedTo: null,
      ),
    );
  });

  setUp(() {
    repository = _MockTaskRepository();
  });

  group('CreateTaskInput validation', () {
    test('lanza error si el título es demasiado corto', () {
      final input = (
        title: 'Hi',
        description: 'Desc',
        createdBy: 'teacher-1',
        durationSuggested: 1800,
        attachments: <AttachmentModel>[],
        dueDate: null,
      );

      expect(
        () => validateCreateTaskInput(input),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('lanza error si la duración sugerida es inválida', () {
      final input = (
        title: 'Título válido',
        description: 'Desc',
        createdBy: 'teacher-1',
        durationSuggested: 0,
        attachments: <AttachmentModel>[],
        dueDate: null,
      );

      expect(
        () => validateCreateTaskInput(input),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('UpdateTaskInput validation', () {
    test('lanza error si no se especifica ningún campo actualizable', () {
      final input = (
        taskId: 'task-1',
        title: null,
        description: null,
        durationSuggested: null,
        attachments: null,
        dueDate: null,
        isActive: null,
      );

      expect(
        () => validateUpdateTaskInput(input),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('no lanza error con un campo válido', () {
      final input = (
        taskId: 'task-1',
        title: 'Nuevo título',
        description: null,
        durationSuggested: null,
        attachments: null,
        dueDate: null,
        isActive: null,
      );

      expect(() => validateUpdateTaskInput(input), returnsNormally);
    });
  });

  group('AssignTaskInput validation', () {
    test('lanza error si falta taskId', () {
      final input = (taskId: ' ', classId: 'class-1', teacherId: 'teacher-1');

      expect(
        () => validateAssignTaskInput(input),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('no lanza error con datos mínimos válidos', () {
      final input = (
        taskId: 'task-1',
        classId: 'class-1',
        teacherId: 'teacher-1',
      );

      expect(() => validateAssignTaskInput(input), returnsNormally);
    });
  });

  group('TaskFilters validation', () {
    test('lanza error si se combinan rangos de createdAt y dueDate', () {
      final filters = (
        isActive: true,
        createdFrom: DateTime(2025, 1, 1),
        createdTo: null,
        dueFrom: DateTime(2025, 2, 1),
        dueTo: null,
        status: null,
        assignedFrom: null,
        assignedTo: null,
      );

      expect(
        () => validateTaskFilters(filters),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('no lanza error con rango de creación válido', () {
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

      expect(() => validateTaskFilters(filters), returnsNormally);
    });
  });

  group('TaskRepository contract (esqueleto TDD)', () {
    test(
      'createTask devuelve TaskModel cuando la creación es exitosa',
      () async {
        final input = (
          title: 'Escalas',
          description: 'Practicar escalas',
          createdBy: 'teacher-1',
          durationSuggested: 1800,
          attachments: <AttachmentModel>[],
          dueDate: DateTime(2025, 1, 1),
        );
        final now = Timestamp.now();
        final task = TaskModel(
          id: 'task-1',
          title: input.title,
          description: input.description,
          createdBy: input.createdBy,
          durationSuggested: input.durationSuggested,
          attachments: input.attachments,
          createdAt: now,
          updatedAt: now,
          dueDate: now,
          isActive: true,
        );

        when(() => repository.createTask(input)).thenAnswer(
          (_) async => task,
        );

        final result = await repository.createTask(input);

        expect(result, task);
      },
      skip: 'Se implementará en Fase 3 (infraestructura)',
    );

    test(
      'watchTeacherTasks devuelve stream de TaskModel',
      () async {
        final filters = (
          isActive: true,
          createdFrom: null,
          createdTo: null,
          dueFrom: null,
          dueTo: null,
          status: null,
          assignedFrom: null,
          assignedTo: null,
        );
        final now = Timestamp.now();
        final task = TaskModel(
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

        when(
          () => repository.watchTeacherTasks(
            'teacher-1',
            filters: filters,
          ),
        ).thenAnswer((_) => Stream.value(<TaskModel>[task]));

        final stream = repository.watchTeacherTasks(
          'teacher-1',
          filters: filters,
        );

        expect(stream, emits(<TaskModel>[task]));
      },
      skip: 'Se implementará en Fase 3 (infraestructura)',
    );

    test(
      'watchStudentAssignments devuelve stream de AssignmentModel',
      () async {
        final filters = (
          isActive: null,
          createdFrom: null,
          createdTo: null,
          dueFrom: null,
          dueTo: null,
          status: TaskStatus.pending,
          assignedFrom: null,
          assignedTo: null,
        );
        final now = Timestamp.now();
        final assignment = AssignmentModel(
          id: AssignmentModel.generateId('task-1', 'student-1'),
          taskId: 'task-1',
          studentId: 'student-1',
          teacherId: 'teacher-1',
          status: TaskStatus.pending,
          assignedAt: now,
          completedAt: null,
          sessionsCount: 0,
          totalDurationLogged: 0,
          lastSessionDate: null,
        );

        when(
          () => repository.watchStudentAssignments(
            'student-1',
            filters: filters,
          ),
        ).thenAnswer((_) => Stream.value(<AssignmentModel>[assignment]));

        final stream = repository.watchStudentAssignments(
          'student-1',
          filters: filters,
        );

        expect(stream, emits(<AssignmentModel>[assignment]));
      },
      skip: 'Se implementará en Fase 3 (infraestructura)',
    );
  });
}



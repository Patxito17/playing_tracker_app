import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/tasks/domain/models/attachment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_state.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockTaskRepository repository;

  setUpAll(() {
    registerFallbackValue(_createTaskInput());
    registerFallbackValue(_updateTaskInput());
    registerFallbackValue(_assignInput());
    registerFallbackValue(_filters());
  });

  setUp(() {
    repository = _MockTaskRepository();
  });

  blocTest<TaskCubit, TaskState>(
    'emite [TaskLoading, TaskEmpty] cuando el stream retorna lista vacía',
    build: () => TaskCubit(repository),
    act: (cubit) {
      when(
        () =>
            repository.watchTeacherTasks(any(), filters: any(named: 'filters')),
      ).thenAnswer((_) => Stream.value(<TaskModel>[]));
      return cubit.watchTasks(teacherId: 'teacher-1');
    },
    expect: () => const [TaskLoading(), TaskEmpty()],
  );

  blocTest<TaskCubit, TaskState>(
    'emite [TaskLoading, TaskSuccess] cuando el stream retorna tareas',
    build: () => TaskCubit(repository),
    act: (cubit) {
      when(
        () =>
            repository.watchTeacherTasks(any(), filters: any(named: 'filters')),
      ).thenAnswer((_) => Stream.value([_taskModel()]));
      return cubit.watchTasks(teacherId: 'teacher-1', filters: _filters());
    },
    expect: () => [
      const TaskLoading(),
      isA<TaskSuccess>()
          .having((state) => state.tasks.length, 'tareas emitidas', 1)
          .having((state) => state.filters, 'filtros activos', _filters()),
    ],
  );

  blocTest<TaskCubit, TaskState>(
    'emite TaskActionSuccess al crear tarea correctamente',
    build: () => TaskCubit(repository),
    act: (cubit) {
      when(
        () => repository.createTask(any()),
      ).thenAnswer((_) async => _taskModel());
      return cubit.createTask(_createTaskInput());
    },
    expect: () => const [
      TaskLoading(),
      TaskActionSuccess(action: TaskAction.created, taskId: 'task-1'),
    ],
  );

  blocTest<TaskCubit, TaskState>(
    'emite TaskError cuando createTask lanza TaskRepositoryException',
    build: () => TaskCubit(repository),
    act: (cubit) {
      when(
        () => repository.createTask(any()),
      ).thenThrow(const UnknownTaskRepositoryException('Error al crear tarea'));
      return cubit.createTask(_createTaskInput());
    },
    expect: () => [
      const TaskLoading(),
      isA<TaskError>()
          .having((state) => state.message, 'mensaje', 'Error al crear tarea')
          .having(
            (state) => state.cause,
            'cause',
            isA<TaskRepositoryException>(),
          ),
    ],
  );

  blocTest<TaskCubit, TaskState>(
    'emite TaskActionSuccess al actualizar tarea correctamente',
    build: () => TaskCubit(repository),
    act: (cubit) {
      when(() => repository.updateTask(any())).thenAnswer((_) async {});
      return cubit.updateTask(_updateTaskInput());
    },
    expect: () => const [
      TaskLoading(),
      TaskActionSuccess(action: TaskAction.updated, message: null),
    ],
  );

  blocTest<TaskCubit, TaskState>(
    'emite TaskActionSuccess al eliminar tarea correctamente',
    build: () => TaskCubit(repository),
    act: (cubit) {
      when(() => repository.deleteTask(any())).thenAnswer((_) async {});
      return cubit.deleteTask('task-1');
    },
    expect: () => const [
      TaskLoading(),
      TaskActionSuccess(action: TaskAction.deleted, message: null),
    ],
  );

  blocTest<TaskCubit, TaskState>(
    'emite TaskActionSuccess al asignar tarea a clase correctamente',
    build: () => TaskCubit(repository),
    act: (cubit) {
      when(() => repository.assignTaskToClass(any())).thenAnswer((_) async {});
      return cubit.assignTaskToClass(_assignInput());
    },
    expect: () => const [
      TaskLoading(),
      TaskActionSuccess(action: TaskAction.assigned, message: null),
    ],
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

UpdateTaskInput _updateTaskInput() => (
  taskId: 'task-1',
  title: 'Nuevo título',
  description: null,
  durationSuggested: 2400,
  attachments: null,
  dueDate: null,
  isActive: null,
);

AssignTaskInput _assignInput() => (
  taskId: 'task-1',
  classId: 'class-1',
  teacherId: 'teacher-1',
  studentIds: null,
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

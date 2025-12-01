import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_state.dart';
import 'package:playing_tracker/features/tasks/presentation/screens/task_list_screen.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockTaskRepository mockTaskRepository;
  late TaskCubit taskCubit;

  setUp(() {
    mockTaskRepository = _MockTaskRepository();
    taskCubit = TaskCubit(mockTaskRepository);
  });

  Widget buildTestScreen() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<TaskCubit>.value(
            value: taskCubit,
            child: const TaskListScreen(),
          ),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('muestra loading cuando el estado es TaskLoading', (
    tester,
  ) async {
    taskCubit.emit(const TaskLoading());

    await tester.pumpWidget(buildTestScreen());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra estado vacío cuando el estado es TaskEmpty', (
    tester,
  ) async {
    taskCubit.emit(const TaskEmpty());

    await tester.pumpWidget(buildTestScreen());

    expect(find.text(TaskStrings.noTasksCreated), findsOneWidget);
  });

  testWidgets('muestra tareas cuando el estado es TaskSuccess', (tester) async {
    final now = DateTime.now();
    final task = TaskModel(
      id: 'task-1',
      title: 'Escalas mayores',
      description: 'Practicar escalas',
      createdBy: 'teacher-1',
      durationSuggested: 900,
      attachments: const [],
      createdAt: Timestamp.fromDate(now),
      updatedAt: Timestamp.fromDate(now),
      dueDate: null,
      isActive: true,
    );

    taskCubit.emit(TaskSuccess(tasks: [task]));

    await tester.pumpWidget(buildTestScreen());

    expect(find.text('Escalas mayores'), findsOneWidget);
  });

  testWidgets('abre bottom sheet de filtros al pulsar el icono de filtros', (
    tester,
  ) async {
    taskCubit.emit(const TaskEmpty());

    await tester.pumpWidget(buildTestScreen());

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    expect(find.text(TaskStrings.filters), findsOneWidget);
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_state.dart';
import 'package:playing_tracker/features/tasks/presentation/screens/task_list_screen.dart';

import '../../../../helpers/user_test_helpers.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

class _MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late _MockTaskRepository mockTaskRepository;
  late TaskCubit taskCubit;
  late _MockAuthCubit mockAuthCubit;

  setUp(() {
    mockTaskRepository = _MockTaskRepository();
    taskCubit = TaskCubit(mockTaskRepository);
    mockAuthCubit = _MockAuthCubit();

    // Configure AuthCubit mock to return authenticated state
    // Configure AuthCubit mock to return authenticated state
    final mockTeacher = createMockTeacher(id: 'teacher-1');
    when(
      () => mockAuthCubit.state,
    ).thenReturn(AuthAuthenticated(user: mockTeacher));
    when(
      () => mockAuthCubit.stream,
    ).thenAnswer((_) => Stream.value(AuthAuthenticated(user: mockTeacher)));

    // Configure TaskRepository mock defaults
    when(
      () => mockTaskRepository.watchTeacherTasks(
        any(),
        filters: any(named: 'filters'),
      ),
    ).thenAnswer((_) => Stream.value(<TaskModel>[]));
  });

  Widget buildTestScreen() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: mockAuthCubit),
              BlocProvider<TaskCubit>.value(value: taskCubit),
            ],
            child: const TaskListScreen(),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
    );
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
    const emptyMessage = 'No se encontraron tareas';
    taskCubit.emit(const TaskEmpty(message: emptyMessage));

    await tester.pumpWidget(buildTestScreen());

    expect(find.text(emptyMessage), findsOneWidget);
  });

  testWidgets('muestra tareas cuando el estado es TaskSuccess', (tester) async {
    final now = DateTime.now();
    final task = TaskModel(
      id: 'task-1',
      title: 'Escalas mayores',
      description: 'Practicar escalas',
      createdBy: 'teacher-1',
      durationSuggested: 900,
      attachmentUrl: null,
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
    taskCubit.emit(const TaskEmpty(message: 'Empty'));

    await tester.pumpWidget(buildTestScreen());

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    expect(find.text('Filtros'), findsOneWidget);
  });
}

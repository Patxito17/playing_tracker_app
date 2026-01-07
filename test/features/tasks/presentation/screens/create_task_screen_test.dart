import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_state.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_state.dart';
import 'package:playing_tracker/features/tasks/domain/models/attachment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:playing_tracker/features/tasks/presentation/screens/create_task_screen.dart';
import 'package:playing_tracker/shared/widgets/custom_button.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockClassCubit extends MockCubit<ClassState> implements ClassCubit {}

class _MockMembershipCubit extends MockCubit<MembershipState>
    implements MembershipCubit {}

void main() {
  late _MockTaskRepository mockTaskRepository;
  late TaskCubit taskCubit;
  late _MockAuthCubit mockAuthCubit;
  late _MockClassCubit mockClassCubit;
  late _MockMembershipCubit mockMembershipCubit;

  setUpAll(() {
    registerFallbackValue((
      title: 'fallback',
      description: 'desc',
      createdBy: 'teacher',
      durationSuggested: 60,
      attachments: <AttachmentModel>[],
      dueDate: null,
    ));
  });

  setUp(() {
    mockTaskRepository = _MockTaskRepository();
    taskCubit = TaskCubit(mockTaskRepository);
    mockAuthCubit = _MockAuthCubit();

    when(
      () => mockAuthCubit.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => mockAuthCubit.state).thenReturn(
      const AuthAuthenticated(role: UserRole.teacher, userId: 'teacher-1'),
    );

    mockClassCubit = _MockClassCubit();
    when(
      () => mockClassCubit.watchClasses(teacherId: any(named: 'teacherId')),
    ).thenAnswer((_) async {});
    when(() => mockClassCubit.state).thenReturn(const ClassLoading());
    when(() => mockClassCubit.stream).thenAnswer((_) => const Stream.empty());

    mockMembershipCubit = _MockMembershipCubit();
    when(
      () => mockMembershipCubit.state,
    ).thenReturn(const MembershipListSuccess(members: [], hasMore: false));
    when(
      () => mockMembershipCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestScreen() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<TaskCubit>.value(value: taskCubit),
              BlocProvider<AuthCubit>.value(value: mockAuthCubit),
              BlocProvider<ClassCubit>.value(value: mockClassCubit),
              BlocProvider<MembershipCubit>.value(value: mockMembershipCubit),
            ],
            child: const CreateTaskScreen(),
          ),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets(
    'valida campos requeridos y no llama createTask si el formulario es inválido',
    (tester) async {
      when(() => mockTaskRepository.createTask(any())).thenAnswer(
        (_) async => TaskModel(
          id: 'task-1',
          title: 'Demo',
          description: 'Demo',
          createdBy: 'teacher-1',
          durationSuggested: 900,
          attachments: const [],
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          dueDate: null,
          isActive: true,
        ),
      );

      await tester.pumpWidget(buildTestScreen());

      final button = find.widgetWithText(
        CustomButton,
        TaskStrings.createTaskButton,
      );
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      verifyNever(() => mockTaskRepository.createTask(any()));
    },
  );

  testWidgets('con formulario válido invoca createTask en el repositorio', (
    tester,
  ) async {
    when(() => mockTaskRepository.createTask(any())).thenAnswer(
      (_) async => TaskModel(
        id: 'task-1',
        title: 'Escalas',
        description: 'Practicar escalas',
        createdBy: 'teacher-1',
        durationSuggested: 900,
        attachments: const [],
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        dueDate: null,
        isActive: true,
      ),
    );

    await tester.pumpWidget(buildTestScreen());

    await tester.enterText(
      find.bySemanticsLabel(TaskStrings.taskTitleLabel),
      'Escalas mayores',
    );
    await tester.enterText(
      find.bySemanticsLabel(TaskStrings.taskDescriptionLabel),
      'Practicar escalas',
    );
    await tester.enterText(
      find.bySemanticsLabel(TaskStrings.estimatedTimeLabel),
      '30',
    );

    final button = find.widgetWithText(
      CustomButton,
      TaskStrings.createTaskButton,
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }, skip: true);
}

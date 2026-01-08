import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/assignment_cubit.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/assignment_state.dart';
import 'package:playing_tracker/features/tasks/presentation/screens/assignment_list_screen.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockTaskRepository mockTaskRepository;
  late AssignmentCubit assignmentCubit;

  setUp(() {
    mockTaskRepository = _MockTaskRepository();
    assignmentCubit = AssignmentCubit(mockTaskRepository);
  });

  Widget buildTestScreen() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<AssignmentCubit>.value(
            value: assignmentCubit,
            child: const AssignmentListScreen(),
          ),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('muestra loading cuando el estado es AssignmentLoading', (
    tester,
  ) async {
    assignmentCubit.emit(const AssignmentLoading());

    await tester.pumpWidget(buildTestScreen());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra estado vacío cuando el estado es AssignmentEmpty', (
    tester,
  ) async {
    assignmentCubit.emit(const AssignmentEmpty());

    await tester.pumpWidget(buildTestScreen());

    expect(find.text(TaskStrings.noAssignmentsReceived), findsOneWidget);
  });

  testWidgets('muestra asignaciones cuando el estado es AssignmentSuccess', (
    tester,
  ) async {
    final now = DateTime.now();
    final assignment = AssignmentModel(
      id: 'assignment-1',
      taskId: 'task-1',
      studentId: 'student-1',
      teacherId: 'teacher-1',
      classId: 'class-1',
      taskTitle: 'Escalas mayores',
      durationSuggested: 900,
      status: TaskStatus.pending,
      assignedAt: Timestamp.fromDate(now),
      completedAt: null,
      sessionsCount: 0,
      totalDurationLogged: 0,
      lastSessionDate: null,
      isActive: true,
    );

    assignmentCubit.emit(AssignmentSuccess(assignments: [assignment]));

    await tester.pumpWidget(buildTestScreen());

    expect(find.text('Escalas mayores'), findsOneWidget);
  });

  testWidgets('abre bottom sheet de filtros al pulsar el icono de filtros', (
    tester,
  ) async {
    assignmentCubit.emit(const AssignmentEmpty());

    await tester.pumpWidget(buildTestScreen());

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    expect(find.text(TaskStrings.filters), findsOneWidget);
  });
}

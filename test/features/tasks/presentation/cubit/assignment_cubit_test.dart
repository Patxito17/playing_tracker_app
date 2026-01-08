import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/assignment_cubit.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/assignment_state.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockTaskRepository repository;

  setUpAll(() {
    registerFallbackValue(_filters());
  });

  setUp(() {
    repository = _MockTaskRepository();
  });

  blocTest<AssignmentCubit, AssignmentState>(
    'emite [AssignmentLoading, AssignmentEmpty] cuando el stream retorna lista vacía',
    build: () => AssignmentCubit(repository),
    act: (cubit) {
      when(
        () => repository.watchStudentAssignments(
          any(),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) => Stream.value(<AssignmentModel>[]));
      return cubit.watchAssignments(studentId: 'student-1');
    },
    expect: () => const [
      AssignmentLoading(),
      AssignmentEmpty(message: TaskStrings.noAssignmentsReceived),
    ],
  );

  blocTest<AssignmentCubit, AssignmentState>(
    'emite [AssignmentLoading, AssignmentSuccess] cuando el stream retorna asignaciones',
    build: () => AssignmentCubit(repository),
    act: (cubit) {
      when(
        () => repository.watchStudentAssignments(
          any(),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) => Stream.value([_assignmentModel()]));
      return cubit.watchAssignments(
        studentId: 'student-1',
        filters: _filters(),
      );
    },
    expect: () => [
      const AssignmentLoading(),
      isA<AssignmentSuccess>()
          .having(
            (state) => state.assignments.length,
            'assignments emitidas',
            1,
          )
          .having((state) => state.filters, 'filtros activos', _filters()),
    ],
  );
}

TaskFilters _filters() => (
  isActive: null,
  createdFrom: null,
  createdTo: null,
  dueFrom: null,
  dueTo: null,
  status: TaskStatus.pending,
  assignedFrom: DateTime(2025, 1, 1),
  assignedTo: DateTime(2025, 1, 31),
);

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

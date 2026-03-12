import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/home/presentation/cubit/progress_cubit.dart';
import 'package:playing_tracker/features/home/presentation/cubit/progress_state.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}
class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockSessionRepository sessionRepository;
  late _MockTaskRepository taskRepository;
  late ProgressCubit progressCubit;

  setUp(() {
    sessionRepository = _MockSessionRepository();
    taskRepository = _MockTaskRepository();
    progressCubit = ProgressCubit(
      sessionRepository: sessionRepository,
      taskRepository: taskRepository,
    );
  });

  tearDown(() {
    progressCubit.close();
  });

  group('ProgressCubit', () {
    const studentId = 'student-123';
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    test('initial state is ProgressInitial', () {
      expect(progressCubit.state, const ProgressInitial());
    });

    blocTest<ProgressCubit, ProgressState>(
      'emits [ProgressLoading, ProgressLoaded] only when both streams emit',
      build: () {
        when(() => sessionRepository.watchWeeklySessions(
              studentId: any(named: 'studentId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) => Stream.value([
              SessionModel(
                id: 'session-1',
                studentId: studentId,
                taskId: 'task-1',
                teacherId: 'teacher-1',
                startTime: Timestamp.fromDate(startOfDay),
                endTime: Timestamp.fromDate(startOfDay.add(const Duration(minutes: 10))),
                totalDuration: 600, // 10 min
                dateLogged: Timestamp.fromDate(startOfDay),
                monthBucket: '2026-03',
                createdAt: Timestamp.now(),
              ),
            ]));

        when(() => taskRepository.watchStudentAssignments(any()))
            .thenAnswer((_) => Stream.value([
              AssignmentModel(
                id: 'task-1_student-123',
                taskId: 'task-1',
                studentId: studentId,
                classId: 'class-1',
                teacherId: 'teacher-1',
                status: TaskStatus.inProgress,
                assignedAt: Timestamp.fromDate(startOfDay),
                durationSuggested: 1200, // 20 min goal
                isActive: true,
                sessionsCount: 1,
                totalDurationLogged: 600,
              ),
            ]));

        return progressCubit;
      },
      act: (cubit) => cubit.watchProgress(studentId),
      expect: () => [
        const ProgressLoading(),
        isA<ProgressLoaded>()
            .having((s) => s.weeklyPercentage, 'weeklyPercentage', 50.0)
            .having((s) => s.totalDurationSeconds, 'totalDurationSeconds', 600),
      ],
    );

    blocTest<ProgressCubit, ProgressState>(
      'respects small goals (e.g. 4 min) and does not apply 30 min fallback if tasks exist',
      build: () {
        when(() => sessionRepository.watchWeeklySessions(
              studentId: any(named: 'studentId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) => Stream.value([
              SessionModel(
                id: 'session-1',
                studentId: studentId,
                taskId: 'task-1',
                teacherId: 'teacher-1',
                startTime: Timestamp.fromDate(startOfDay),
                endTime: Timestamp.fromDate(startOfDay.add(const Duration(minutes: 6))),
                totalDuration: 360, // 6 min
                dateLogged: Timestamp.fromDate(startOfDay),
                monthBucket: '2026-03',
                createdAt: Timestamp.now(),
              ),
            ]));

        when(() => taskRepository.watchStudentAssignments(any()))
            .thenAnswer((_) => Stream.value([
              AssignmentModel(
                id: 'task-1_student-123',
                taskId: 'task-1',
                studentId: studentId,
                classId: 'class-1',
                teacherId: 'teacher-1',
                status: TaskStatus.inProgress,
                assignedAt: Timestamp.fromDate(startOfDay),
                durationSuggested: 240, // 4 min goal
                isActive: true,
                sessionsCount: 1,
                totalDurationLogged: 360,
              ),
            ]));

        return progressCubit;
      },
      act: (cubit) => cubit.watchProgress(studentId),
      expect: () => [
        const ProgressLoading(),
        isA<ProgressLoaded>()
            .having((s) => s.weeklyPercentage, 'weeklyPercentage', 100.0) // 360/240 = 150%, clamped to 100
            .having((s) => s.totalDurationSeconds, 'totalDurationSeconds', 360),
      ],
    );

    blocTest<ProgressCubit, ProgressState>(
      'emits ProgressError and stops when a stream fails',
      build: () {
        when(() => sessionRepository.watchWeeklySessions(
              studentId: any(named: 'studentId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) => Stream.error('Session error'));

        when(() => taskRepository.watchStudentAssignments(any()))
            .thenAnswer((_) => Stream.value([]));

        return progressCubit;
      },
      act: (cubit) => cubit.watchProgress(studentId),
      expect: () => [
        const ProgressLoading(),
        const ProgressError('Session error'),
      ],
    );
  });
}

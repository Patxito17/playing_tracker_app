import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_cubit.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_state.dart';

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

void main() {
  late StatisticsRepository repository;
  late StudentStatsCubit cubit;

  const studentId = 'student_123';
  const classId = 'class_456';

  final tProgress = StudentProgressModel(
    studentId: studentId,
    studentName: 'Test Student',
    totalDuration: 3600,
    totalSessions: 5,
    totalTasks: 3,
    completedTasks: 1,
  );

  final tWeeklyStats = WeeklyStatsModel(
    weekStart: Timestamp.now(),
    weekEnd: Timestamp.now(),
    totalDuration: 1800,
    totalSessions: 3,
    uniqueTasks: 2,
    dailyBreakdown: const [],
    taskBreakdown: const [],
  );

  setUp(() {
    repository = MockStatisticsRepository();
    cubit = StudentStatsCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('StudentStatsCubit', () {
    test('initial state is StudentStatsInitial', () {
      expect(cubit.state, const StudentStatsInitial());
    });

    blocTest<StudentStatsCubit, StudentStatsState>(
      'emits [Loading, Loaded] when loadStats is successful',
      build: () {
        when(
          () =>
              repository.getStudentProgress(studentId: any(named: 'studentId')),
        ).thenAnswer((_) async => tProgress);
        when(
          () => repository.getWeeklyStats(
            studentId: any(named: 'studentId'),
            weekStart: any(named: 'weekStart'),
            classId: any(named: 'classId'),
          ),
        ).thenAnswer((_) async => tWeeklyStats);
        return cubit;
      },
      act: (cubit) => cubit.loadStats(studentId: studentId),
      expect: () => [
        const StudentStatsLoading(timeFilter: TimeFilter.thisWeek),
        StudentStatsLoaded(
          timeFilter: TimeFilter.thisWeek,
          progress: tProgress,
          weeklyStats: tWeeklyStats,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getStudentProgress(studentId: studentId),
        ).called(1);
        verify(
          () => repository.getWeeklyStats(
            studentId: studentId,
            weekStart: any(named: 'weekStart'),
            classId: null,
          ),
        ).called(1);
      },
    );

    blocTest<StudentStatsCubit, StudentStatsState>(
      'emits [Loading, Loaded] with classId when loadStats is successful',
      build: () {
        when(
          () =>
              repository.getStudentProgress(studentId: any(named: 'studentId')),
        ).thenAnswer((_) async => tProgress);
        when(
          () => repository.getWeeklyStats(
            studentId: any(named: 'studentId'),
            weekStart: any(named: 'weekStart'),
            classId: any(named: 'classId'),
          ),
        ).thenAnswer((_) async => tWeeklyStats);
        return cubit;
      },
      act: (cubit) => cubit.loadStats(studentId: studentId, classId: classId),
      expect: () => [
        const StudentStatsLoading(timeFilter: TimeFilter.thisWeek),
        StudentStatsLoaded(
          timeFilter: TimeFilter.thisWeek,
          progress: tProgress,
          weeklyStats: tWeeklyStats,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getWeeklyStats(
            studentId: studentId,
            weekStart: any(named: 'weekStart'),
            classId: classId,
          ),
        ).called(1);
      },
    );

    blocTest<StudentStatsCubit, StudentStatsState>(
      'emits [Loading, Error] when loadStats fails',
      build: () {
        when(
          () =>
              repository.getStudentProgress(studentId: any(named: 'studentId')),
        ).thenThrow(Exception('Failed to load progress'));
        return cubit;
      },
      expect: () => [
        const StudentStatsLoading(timeFilter: TimeFilter.thisWeek),
        isA<StudentStatsError>(),
      ],
    );
  });
}

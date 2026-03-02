import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_cubit.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_state.dart';

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

void main() {
  late StatisticsRepository repository;
  late TeacherStatsCubit cubit;

  const classId = 'class_123';
  const teacherId = 'teacher_456';

  final tClassStats = ClassStatsModel(
    classId: classId,
    className: 'Test Class',
    totalStudents: 10,
    activeStudents: 7,
    totalDuration: 18000,
    totalSessions: 25,
  );

  setUp(() {
    repository = MockStatisticsRepository();
    cubit = TeacherStatsCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('TeacherStatsCubit', () {
    test('initial state is TeacherStatsInitial', () {
      expect(cubit.state, const TeacherStatsInitial());
    });

    blocTest<TeacherStatsCubit, TeacherStatsState>(
      'emits [Loading, Loaded] when loadClassStats is successful',
      build: () {
        when(
          () => repository.getClassStats(
            classId: any(named: 'classId'),
            teacherId: any(named: 'teacherId'),
            timeFilter: any(named: 'timeFilter'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => tClassStats);
        return cubit;
      },
      act: (cubit) =>
          cubit.loadClassStats(classId: classId, teacherId: teacherId),
      expect: () => [
        const TeacherStatsLoading(timeFilter: TimeFilter.thisWeek),
        TeacherStatsLoaded(
          classStats: tClassStats,
          timeFilter: TimeFilter.thisWeek,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getClassStats(
            classId: classId,
            teacherId: teacherId,
            timeFilter: TimeFilter.thisWeek,
            forceRefresh: false,
          ),
        ).called(1);
      },
    );

    blocTest<TeacherStatsCubit, TeacherStatsState>(
      'emits [Loading, Error] when loadClassStats fails',
      build: () {
        when(
          () => repository.getClassStats(
            classId: any(named: 'classId'),
            teacherId: any(named: 'teacherId'),
            timeFilter: any(named: 'timeFilter'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenThrow(Exception('Failed to load class stats'));
        return cubit;
      },
      act: (cubit) =>
          cubit.loadClassStats(classId: classId, teacherId: teacherId),
      expect: () => [
        const TeacherStatsLoading(timeFilter: TimeFilter.thisWeek),
        isA<TeacherStatsError>(),
      ],
    );

    blocTest<TeacherStatsCubit, TeacherStatsState>(
      'refreshClassStats calls loadClassStats and emits [Loading, Loaded]',
      build: () {
        when(
          () => repository.getClassStats(
            classId: any(named: 'classId'),
            teacherId: any(named: 'teacherId'),
            timeFilter: any(named: 'timeFilter'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => tClassStats);
        return cubit;
      },
      act: (cubit) =>
          cubit.refreshClassStats(classId: classId, teacherId: teacherId),
      expect: () => [
        const TeacherStatsLoading(timeFilter: TimeFilter.thisWeek),
        TeacherStatsLoaded(
          classStats: tClassStats,
          timeFilter: TimeFilter.thisWeek,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getClassStats(
            classId: classId,
            teacherId: teacherId,
            timeFilter: TimeFilter.thisWeek,
            forceRefresh: true,
          ),
        ).called(1);
      },
    );
  });
}

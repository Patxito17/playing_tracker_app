import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_cubit.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_state.dart';
import 'package:playing_tracker/features/statistics/presentation/screens/teacher_statistics_screen.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';

import '../../../../helpers/user_test_helpers.dart';

class MockTeacherStatsCubit extends Mock implements TeacherStatsCubit {}

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockTeacherStatsCubit mockTeacherStatsCubit;
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockTeacherStatsCubit = MockTeacherStatsCubit();
    mockAuthCubit = MockAuthCubit();

    when(
      () => mockAuthCubit.state,
    ).thenReturn(AuthAuthenticated(user: createMockTeacher(id: 'teacher_456')));
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget makeTestableWidget(Widget child) {
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (context, state) => child)],
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
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider<TeacherStatsCubit>.value(value: mockTeacherStatsCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: child!,
      ),
    );
  }

  group('TeacherStatisticsScreen', () {
    testWidgets('renders app bar title', (WidgetTester tester) async {
      when(
        () => mockTeacherStatsCubit.state,
      ).thenReturn(const TeacherStatsLoading());
      when(
        () => mockTeacherStatsCubit.stream,
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        makeTestableWidget(
          const TeacherStatisticsScreen(classId: 'c1', teacherId: 't1'),
        ),
      );

      // "Estadísticas de la clase" (lowercase c in clase)
      expect(find.text('Estadísticas de la clase'), findsOneWidget);
    });

    testWidgets('shows class name when loaded', (WidgetTester tester) async {
      final classStats = ClassStatsModel(
        classId: 'c1',
        className: 'Test Class',
        totalStudents: 10,
        activeStudents: 5,
        totalDuration: 100,
        totalSessions: 10,
      );

      final state = TeacherStatsLoaded(classStats: classStats);
      when(() => mockTeacherStatsCubit.state).thenReturn(state);
      when(
        () => mockTeacherStatsCubit.stream,
      ).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(
        makeTestableWidget(
          const TeacherStatisticsScreen(classId: 'c1', teacherId: 't1'),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Class'), findsOneWidget);
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_cubit.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_state.dart';
import 'package:playing_tracker/features/statistics/presentation/screens/student_statistics_screen.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_bar_chart.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_pie_chart.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_progress_chart.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';

class MockStudentStatsCubit extends MockCubit<StudentStatsState>
    implements StudentStatsCubit {}

void main() {
  late StudentStatsCubit cubit;

  const studentId = 'student_123';

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
    cubit = MockStudentStatsCubit();
    // Default mock behavior
    when(() => cubit.state).thenReturn(const StudentStatsInitial());
  });

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<StudentStatsCubit>.value(
            value: cubit,
            child: const StudentStatisticsScreen(studentId: studentId),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return MediaQuery(
          data: const MediaQueryData(size: Size(1080, 2400)),
          child: child!,
        );
      },
    );
  }

  group('StudentStatisticsScreen', () {
    setUp(() {
      // Evitar RenderFlex overflow al renderizar pantallas con mucho contenido
      // en el entorno de test (viewport artificialmente pequeño por defecto).
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUpAll(() {
      // Tamaño grande para simular un dispositivo real (1080x1920 @1x)
      WidgetsBinding
          .instance
          .platformDispatcher
          .implicitView
          // ignore: invalid_use_of_protected_member
          ?.physicalSize;
    });

    testWidgets('renders loading indicator when state is Loading', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(
        () => cubit.state,
      ).thenReturn(const StudentStatsLoading(timeFilter: TimeFilter.thisWeek));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message and retry button when state is Error', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const errorMessage = 'Ocurrió un error';
      when(() => cubit.state).thenReturn(
        const StudentStatsError(
          timeFilter: TimeFilter.thisWeek,
          message: errorMessage,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Error al cargar estadísticas'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('renders statistics charts and cards when state is Loaded', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => cubit.state).thenReturn(
        StudentStatsLoaded(
          timeFilter: TimeFilter.thisWeek,
          progress: tProgress,
          weeklyStats: tWeeklyStats,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Necesario para que el BlocBuilder reaccione

      expect(find.text('Resumen General'), findsOneWidget);
      expect(find.text('Actividad Semanal'), findsOneWidget);

      expect(find.byType(AppProgressChart), findsOneWidget);
      expect(find.byType(AppBarChart), findsOneWidget);
    });

    testWidgets('renders PieChart when there are task breakdown data', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final tWeeklyStatsWithTasks = WeeklyStatsModel(
        weekStart: Timestamp.now(),
        weekEnd: Timestamp.now(),
        totalDuration: 1800,
        totalSessions: 3,
        uniqueTasks: 2,
        dailyBreakdown: const [],
        taskBreakdown: [
          const TaskStatsModel(
            taskId: '1',
            taskTitle: 'Tarea 1',
            totalDuration: 1000,
            totalSessions: 1,
          ),
          const TaskStatsModel(
            taskId: '2',
            taskTitle: 'Tarea 2',
            totalDuration: 800,
            totalSessions: 2,
          ),
        ],
      );

      when(() => cubit.state).thenReturn(
        StudentStatsLoaded(
          timeFilter: TimeFilter.thisWeek,
          progress: tProgress,
          weeklyStats: tWeeklyStatsWithTasks,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Distribución por Tarea'), findsOneWidget);
      expect(find.byType(AppPieChart), findsOneWidget);
    });
  });
}

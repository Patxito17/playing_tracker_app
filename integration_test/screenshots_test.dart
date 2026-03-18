// integration_test/screenshots_test.dart
//
// Capturas de pantalla para App Store y Play Store
//
// Mecanismo:
//   Se construye una app de prueba completa (_ScreenshotApp) que replica la
//   estructura de PlayingTrackerApp pero inyecta mocks (mocktail) en lugar de
//   implementaciones Firebase reales. Los stubs usan ScreenshotMockData para
//   mostrar datos realistas en cada pantalla.
//
//   No se inicializa Firebase en ningún momento de este test.
//
// Screenshots capturados (por locale):
//   01_login_<locale>        — LoginScreen (AuthUnauthenticated)
//   02_student_home_<locale> — StudentHomeScreen (AuthAuthenticated, student)
//   03_student_stats_<locale>— StudentStatisticsScreen (tab Estadísticas/Statistics)
//   04_student_settings_<locale> — SettingsScreen (tab Perfil/Profile)
//
// Ejecutar (requiere dispositivo o emulador conectado):
//   flutter test integration_test/screenshots_test.dart -d <device_id>
//
// ignore_for_file: avoid_print

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/config/routes/app_routes.dart';
import 'package:playing_tracker/config/theme/app_theme.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';
import 'package:playing_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:playing_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';
import 'package:playing_tracker/l10n/l10n.dart';

import '../test/helpers/mock_hydrated_storage.dart';
import 'helpers/screenshot_helper.dart';
import 'helpers/screenshot_mock_data.dart';

// ---------------------------------------------------------------------------
// Mocks (mocktail) — mismas declaraciones que app_test.dart
// ---------------------------------------------------------------------------

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockClassRepository extends Mock implements ClassRepository {}

class _MockTaskRepository extends Mock implements TaskRepository {}

class _MockSessionRepository extends Mock implements SessionRepository {}

class _MockStatisticsRepository extends Mock implements StatisticsRepository {}

// ---------------------------------------------------------------------------
// App de prueba para screenshots — sin Firebase, con parámetro locale
// ---------------------------------------------------------------------------

/// Replica la estructura de PlayingTrackerApp usando cubits y repositorios
/// inyectados como mocks. El parámetro [locale] permite capturar screenshots
/// en inglés y español sin instanciar dos apps distintas.
class _ScreenshotApp extends StatefulWidget {
  const _ScreenshotApp({
    required this.authCubit,
    required this.settingsCubit,
    required this.authRepository,
    required this.classRepository,
    required this.taskRepository,
    required this.sessionRepository,
    required this.statisticsRepository,
    required this.locale,
  });

  final AuthCubit authCubit;
  final SettingsCubit settingsCubit;
  final AuthRepository authRepository;
  final ClassRepository classRepository;
  final TaskRepository taskRepository;
  final SessionRepository sessionRepository;
  final StatisticsRepository statisticsRepository;
  final Locale locale;

  @override
  State<_ScreenshotApp> createState() => _ScreenshotAppState();
}

class _ScreenshotAppState extends State<_ScreenshotApp> {
  late final AppRoutes _appRoutes;

  @override
  void initState() {
    super.initState();
    _appRoutes = AppRoutes(widget.authCubit);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
        RepositoryProvider<ClassRepository>.value(
          value: widget.classRepository,
        ),
        RepositoryProvider<TaskRepository>.value(value: widget.taskRepository),
        RepositoryProvider<SessionRepository>.value(
          value: widget.sessionRepository,
        ),
        RepositoryProvider<StatisticsRepository>.value(
          value: widget.statisticsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: widget.authCubit),
          BlocProvider<SettingsCubit>.value(value: widget.settingsCubit),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp.router(
              title: 'Playing Tracker (Screenshots)',
              theme: AppTheme.lightTheme(null),
              darkTheme: AppTheme.darkTheme(null),
              themeMode: ThemeMode.light,
              locale: widget.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: L10n.all,
              routerConfig: _appRoutes.router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper: construye _ScreenshotApp con todos los mocks inyectados
// ---------------------------------------------------------------------------

Widget _buildApp({
  required _MockAuthCubit authCubit,
  required _MockSettingsCubit settingsCubit,
  required _MockAuthRepository authRepository,
  required _MockClassRepository classRepository,
  required _MockTaskRepository taskRepository,
  required _MockSessionRepository sessionRepository,
  required _MockStatisticsRepository statisticsRepository,
  required Locale locale,
}) {
  return _ScreenshotApp(
    authCubit: authCubit,
    settingsCubit: settingsCubit,
    authRepository: authRepository,
    classRepository: classRepository,
    taskRepository: taskRepository,
    sessionRepository: sessionRepository,
    statisticsRepository: statisticsRepository,
    locale: locale,
  );
}

// ---------------------------------------------------------------------------
// Helpers de configuración de stubs
// ---------------------------------------------------------------------------

/// Configura los stubs de SettingsCubit: tutorial completado para evitar que
/// TutorialCoachMark interfiera con la navegación del test.
void _stubSettingsCubit(_MockSettingsCubit mock) {
  const settingsState = SettingsState(
    themeMode: ThemeMode.light,
    studentTutorialDone: true,
    teacherTutorialDone: true,
  );
  when(() => mock.state).thenReturn(settingsState);
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
}

/// Configura los stubs de repositorios con datos realistas de ScreenshotMockData.
void _stubRepositories({
  required _MockSessionRepository sessionRepository,
  required _MockTaskRepository taskRepository,
  required _MockStatisticsRepository statisticsRepository,
}) {
  // SessionRepository: sesiones recientes para ProgressCubit
  when(
    () => sessionRepository.watchWeeklySessions(
      studentId: any(named: 'studentId'),
      startDate: any(named: 'startDate'),
      endDate: any(named: 'endDate'),
    ),
  ).thenAnswer((_) => Stream.value(ScreenshotMockData.recentSessions));

  when(
    () => sessionRepository.watchStudentSessions(
      studentId: any(named: 'studentId'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) => Stream.value(ScreenshotMockData.recentSessions));

  // TaskRepository: asignaciones activas de la alumna
  when(
    () => taskRepository.watchStudentAssignments(any()),
  ).thenAnswer((_) => Stream.value(ScreenshotMockData.studentAssignments));

  // StatisticsRepository: progreso y estadísticas semanales realistas
  when(
    () => statisticsRepository.getStudentProgress(
      studentId: any(named: 'studentId'),
      forceRefresh: any(named: 'forceRefresh'),
    ),
  ).thenAnswer((_) async => ScreenshotMockData.studentProgress);

  when(
    () => statisticsRepository.getStudentStats(
      studentId: any(named: 'studentId'),
      timeFilter: any(named: 'timeFilter'),
      classId: any(named: 'classId'),
      forceRefresh: any(named: 'forceRefresh'),
    ),
  ).thenAnswer((_) async => ScreenshotMockData.currentWeekStats);
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late _MockAuthCubit mockAuthCubit;
  late _MockSettingsCubit mockSettingsCubit;
  late _MockAuthRepository mockAuthRepository;
  late _MockClassRepository mockClassRepository;
  late _MockTaskRepository mockTaskRepository;
  late _MockSessionRepository mockSessionRepository;
  late _MockStatisticsRepository mockStatisticsRepository;

  setUpAll(() {
    // Registrar fallback values para tipos personalizados usados con any().
    // Mocktail los necesita antes de que cualquier stub use esos tipos.
    registerFallbackValue(TimeFilter.thisWeek);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    // HydratedBloc requiere un storage incluso cuando el Cubit es mock.
    initHydratedStorage();

    mockAuthCubit = _MockAuthCubit();
    mockSettingsCubit = _MockSettingsCubit();
    mockAuthRepository = _MockAuthRepository();
    mockClassRepository = _MockClassRepository();
    mockTaskRepository = _MockTaskRepository();
    mockSessionRepository = _MockSessionRepository();
    mockStatisticsRepository = _MockStatisticsRepository();

    _stubSettingsCubit(mockSettingsCubit);
    _stubRepositories(
      sessionRepository: mockSessionRepository,
      taskRepository: mockTaskRepository,
      statisticsRepository: mockStatisticsRepository,
    );
  });

  // =========================================================================
  // Screenshots en INGLÉS
  // =========================================================================

  group('Screenshots — English (en)', () {
    const locale = Locale('en');

    // ── 01: Login ────────────────────────────────────────────────────────────
    testWidgets('01_login_en — LoginScreen (unauthenticated)', (tester) async {
      print('[SS] Capturando 01_login_en...');

      when(() => mockAuthCubit.state).thenReturn(const AuthUnauthenticated());
      when(() => mockAuthCubit.stream).thenAnswer(
        (_) => Stream.value(const AuthUnauthenticated()),
      );

      await tester.pumpWidget(
        _buildApp(
          authCubit: mockAuthCubit,
          settingsCubit: mockSettingsCubit,
          authRepository: mockAuthRepository,
          classRepository: mockClassRepository,
          taskRepository: mockTaskRepository,
          sessionRepository: mockSessionRepository,
          statisticsRepository: mockStatisticsRepository,
          locale: locale,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verificar que estamos en LoginScreen (EN: "Welcome back")
      expect(find.text('Welcome back'), findsOneWidget);

      await captureScreenshot(binding, tester, '01_login_en');
      print('[SS] ✅ 01_login_en guardado');
    });

    // ── 02: Student Home ─────────────────────────────────────────────────────
    testWidgets(
      '02_student_home_en — StudentHomeScreen (authenticated)',
      (tester) async {
        print('[SS] Capturando 02_student_home_en...');

        final student = ScreenshotMockData.student;
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
            locale: locale,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verificar que estamos en StudentHomeScreen (EN: "Quick Actions")
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Quick Actions'), findsOneWidget);

        await captureScreenshot(binding, tester, '02_student_home_en');
        print('[SS] ✅ 02_student_home_en guardado');
      },
    );

    // ── 03: Student Statistics ───────────────────────────────────────────────
    testWidgets(
      '03_student_stats_en — StudentStatisticsScreen (Statistics tab)',
      (tester) async {
        print('[SS] Capturando 03_student_stats_en...');

        final student = ScreenshotMockData.student;
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
            locale: locale,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Navegar al tab Statistics (EN: "Statistics")
        final statsTab = find.text('Statistics');
        expect(statsTab, findsOneWidget);
        await tester.tap(statsTab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(NavigationBar), findsOneWidget);

        await captureScreenshot(binding, tester, '03_student_stats_en');
        print('[SS] ✅ 03_student_stats_en guardado');
      },
    );

    // ── 04: Student Settings ─────────────────────────────────────────────────
    testWidgets(
      '04_student_settings_en — SettingsScreen (Profile tab)',
      (tester) async {
        print('[SS] Capturando 04_student_settings_en...');

        final student = ScreenshotMockData.student;
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
            locale: locale,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Navegar al tab Profile (EN: "Profile")
        final profileTab = find.text('Profile');
        expect(profileTab, findsOneWidget);
        await tester.tap(profileTab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Settings'), findsAtLeastNWidgets(1));

        await captureScreenshot(binding, tester, '04_student_settings_en');
        print('[SS] ✅ 04_student_settings_en guardado');
      },
    );
  });

  // =========================================================================
  // Screenshots en ESPAÑOL
  // =========================================================================

  group('Screenshots — Spanish (es)', () {
    const locale = Locale('es');

    // ── 01: Login ────────────────────────────────────────────────────────────
    testWidgets('01_login_es — LoginScreen (no autenticado)', (tester) async {
      print('[SS] Capturando 01_login_es...');

      when(() => mockAuthCubit.state).thenReturn(const AuthUnauthenticated());
      when(() => mockAuthCubit.stream).thenAnswer(
        (_) => Stream.value(const AuthUnauthenticated()),
      );

      await tester.pumpWidget(
        _buildApp(
          authCubit: mockAuthCubit,
          settingsCubit: mockSettingsCubit,
          authRepository: mockAuthRepository,
          classRepository: mockClassRepository,
          taskRepository: mockTaskRepository,
          sessionRepository: mockSessionRepository,
          statisticsRepository: mockStatisticsRepository,
          locale: locale,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verificar que estamos en LoginScreen (ES: "Bienvenido")
      expect(find.text('Bienvenido'), findsOneWidget);

      await captureScreenshot(binding, tester, '01_login_es');
      print('[SS] ✅ 01_login_es guardado');
    });

    // ── 02: Student Home ─────────────────────────────────────────────────────
    testWidgets(
      '02_student_home_es — StudentHomeScreen (autenticado)',
      (tester) async {
        print('[SS] Capturando 02_student_home_es...');

        final student = ScreenshotMockData.student;
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
            locale: locale,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verificar que estamos en StudentHomeScreen (ES: "Acciones rápidas")
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Acciones rápidas'), findsOneWidget);

        await captureScreenshot(binding, tester, '02_student_home_es');
        print('[SS] ✅ 02_student_home_es guardado');
      },
    );

    // ── 03: Student Statistics ───────────────────────────────────────────────
    testWidgets(
      '03_student_stats_es — StudentStatisticsScreen (tab Estadísticas)',
      (tester) async {
        print('[SS] Capturando 03_student_stats_es...');

        final student = ScreenshotMockData.student;
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
            locale: locale,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Navegar al tab Estadísticas (ES: "Estadísticas")
        final statsTab = find.text('Estadísticas');
        expect(statsTab, findsOneWidget);
        await tester.tap(statsTab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(NavigationBar), findsOneWidget);

        await captureScreenshot(binding, tester, '03_student_stats_es');
        print('[SS] ✅ 03_student_stats_es guardado');
      },
    );

    // ── 04: Student Settings ─────────────────────────────────────────────────
    testWidgets(
      '04_student_settings_es — SettingsScreen (tab Perfil)',
      (tester) async {
        print('[SS] Capturando 04_student_settings_es...');

        final student = ScreenshotMockData.student;
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
            locale: locale,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Navegar al tab Perfil (ES: "Perfil")
        final profileTab = find.text('Perfil');
        expect(profileTab, findsOneWidget);
        await tester.tap(profileTab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Ajustes'), findsAtLeastNWidgets(1));

        await captureScreenshot(binding, tester, '04_student_settings_es');
        print('[SS] ✅ 04_student_settings_es guardado');
      },
    );
  });
}

// integration_test/app_test.dart
//
// Prueba de integración determinista — Flujo de navegación del estudiante
//
// Mecanismo:
//   Se construye una app de prueba completa (_TestApp) que replica la estructura
//   de PlayingTrackerApp pero inyecta mocks (mocktail) en lugar de implementaciones
//   Firebase reales. AuthCubit se sustituye por un MockCubit pre-programado para
//   emitir AuthAuthenticated(student) directamente, lo que hace que el router
//   reactivo de GoRouter navegue al Dashboard del estudiante sin ninguna llamada
//   real a Firebase.
//
//   No se inicializa Firebase en ningún momento de este test.
//
// Flujo cubierto:
//   Paso 1 — Arranque con estado sin autenticar → LoginScreen visible
//   Paso 2 — Mock emite AuthAuthenticated(student) → StudentHomeScreen visible
//   Paso 3 — Tap tab "Estadísticas" → pantalla de estadísticas accesible
//   Paso 4 — Tap tab "Perfil/Ajustes" → SettingsScreen accesible
//   Flujo completo — todos los pasos en un único test integrado
//
// Ejecutar (requiere dispositivo o emulador conectado):
//   flutter test integration_test/app_test.dart -d <device_id>
//
// ignore_for_file: avoid_print

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';
import 'package:playing_tracker/l10n/l10n.dart';

import '../test/helpers/mock_hydrated_storage.dart';
import '../test/helpers/user_test_helpers.dart';

// ---------------------------------------------------------------------------
// Mocks (mocktail)
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
// App de prueba — sin Firebase
// ---------------------------------------------------------------------------

/// Replica la estructura de PlayingTrackerApp usando cubits y repositorios
/// inyectados como mocks. Permite ejecutar tests de integración sin Firebase.
///
/// Diferencia clave respecto a PlayingTrackerApp: no instancia nunca
/// StatisticsRepositoryImpl (que requiere Firebase), ya que recibe la
/// implementación como parámetro.
class _TestApp extends StatefulWidget {
  const _TestApp({
    required this.authCubit,
    required this.settingsCubit,
    required this.authRepository,
    required this.classRepository,
    required this.taskRepository,
    required this.sessionRepository,
    required this.statisticsRepository,
  });

  final AuthCubit authCubit;
  final SettingsCubit settingsCubit;
  final AuthRepository authRepository;
  final ClassRepository classRepository;
  final TaskRepository taskRepository;
  final SessionRepository sessionRepository;
  final StatisticsRepository statisticsRepository;

  @override
  State<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<_TestApp> {
  late final AppRoutes _appRoutes;

  @override
  void initState() {
    super.initState();
    // GoRouter escucha el stream del AuthCubit para redirigir reactivamente.
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
              title: 'Playing Tracker (Test)',
              theme: AppTheme.lightTheme(null),
              darkTheme: AppTheme.darkTheme(null),
              themeMode: ThemeMode.light,
              // Idioma fijo en español para poder buscar textos ARB exactos.
              locale: const Locale('es'),
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
// Helper: instancia _TestApp con estado autenticado (student)
// ---------------------------------------------------------------------------

Widget _buildStudentApp({
  required _MockAuthCubit authCubit,
  required _MockSettingsCubit settingsCubit,
  required _MockAuthRepository authRepository,
  required _MockClassRepository classRepository,
  required _MockTaskRepository taskRepository,
  required _MockSessionRepository sessionRepository,
  required _MockStatisticsRepository statisticsRepository,
}) {
  return _TestApp(
    authCubit: authCubit,
    settingsCubit: settingsCubit,
    authRepository: authRepository,
    classRepository: classRepository,
    taskRepository: taskRepository,
    sessionRepository: sessionRepository,
    statisticsRepository: statisticsRepository,
  );
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late _MockAuthCubit mockAuthCubit;
  late _MockSettingsCubit mockSettingsCubit;
  late _MockAuthRepository mockAuthRepository;
  late _MockClassRepository mockClassRepository;
  late _MockTaskRepository mockTaskRepository;
  late _MockSessionRepository mockSessionRepository;
  late _MockStatisticsRepository mockStatisticsRepository;

  setUp(() {
    // HydratedBloc requiere un storage incluso cuando el Cubit es mock, ya
    // que AppRoutes construye AuthCubit y GoRouterRefreshStream internamente.
    initHydratedStorage();

    mockAuthCubit = _MockAuthCubit();
    mockSettingsCubit = _MockSettingsCubit();
    mockAuthRepository = _MockAuthRepository();
    mockClassRepository = _MockClassRepository();
    mockTaskRepository = _MockTaskRepository();
    mockSessionRepository = _MockSessionRepository();
    mockStatisticsRepository = _MockStatisticsRepository();

    // ── SettingsCubit: tutorial marcado como completado para evitar que
    //    TutorialCoachMark interfiera con la navegación del test.
    const settingsState = SettingsState(
      themeMode: ThemeMode.light,
      studentTutorialDone: true,
      teacherTutorialDone: true,
    );
    when(() => mockSettingsCubit.state).thenReturn(settingsState);
    when(() => mockSettingsCubit.stream).thenAnswer(
      (_) => const Stream.empty(),
    );

    // ── SessionRepository: streams vacíos para ProgressCubit
    //    (watchWeeklySessions + watchStudentSessions) en StudentHomeScreen.
    when(
      () => mockSessionRepository.watchWeeklySessions(
        studentId: any(named: 'studentId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) => Stream.value([]));

    when(
      () => mockSessionRepository.watchStudentSessions(
        studentId: any(named: 'studentId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => Stream.value([]));

    // ── TaskRepository: stream vacío de assignments para ProgressCubit.
    when(
      () => mockTaskRepository.watchStudentAssignments(
        any(),
      ),
    ).thenAnswer((_) => Stream.value([]));

    // ── StatisticsRepository: datos vacíos para StudentStatsCubit
    //    (getStudentProgress + getStudentStats, llamados en paralelo).
    when(
      () => mockStatisticsRepository.getStudentProgress(
        studentId: any(named: 'studentId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => const StudentProgressModel(
        studentId: 'student-1',
        studentName: 'Ana Lopez',
        totalDuration: 0,
        totalSessions: 0,
        totalTasks: 0,
        completedTasks: 0,
      ),
    );

    when(
      () => mockStatisticsRepository.getStudentStats(
        studentId: any(named: 'studentId'),
        timeFilter: any(named: 'timeFilter'),
        classId: any(named: 'classId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => WeeklyStatsModel(
        weekStart: Timestamp.fromDate(DateTime(2026, 1, 20)),
        weekEnd: Timestamp.fromDate(DateTime(2026, 1, 26)),
        totalDuration: 0,
        totalSessions: 0,
        uniqueTasks: 0,
      ),
    );
  });

  group('Prueba de integración: Navegación del estudiante (sin Firebase)', () {
    // ── Paso 1: Arranque de la app ──────────────────────────────────────────
    //
    // Mecanismo:   Arranca _TestApp con AuthCubit en AuthUnauthenticated.
    // Entrada:     Estado del AuthCubit = AuthUnauthenticated.
    // Salida:      Router redirige a /login → LoginScreen muestra "Bienvenido".
    testWidgets(
      'Paso 1: la app arranca y muestra LoginScreen con título de bienvenida',
      (tester) async {
        print('[IT] Arrancando app con estado no autenticado...');

        // Pre-programar AuthCubit en estado no autenticado.
        when(() => mockAuthCubit.state).thenReturn(const AuthUnauthenticated());
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(const AuthUnauthenticated()),
        );

        await tester.pumpWidget(
          _buildStudentApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
          ),
        );

        // Permitir que el router reactive procese el redirect splash → /login.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        // Salida esperada: "Bienvenido" (l10n.welcomeTitle en LoginScreen).
        expect(
          find.text('Bienvenido'),
          findsOneWidget,
          reason: 'LoginScreen debe mostrar el título de bienvenida',
        );

        print('[IT] ✅ Paso 1 completado — LoginScreen visible');
      },
    );

    // ── Paso 2: Login simulado → Dashboard del estudiante ───────────────────
    //
    // Mecanismo:   AuthCubit pre-programado para emitir AuthAuthenticated(student)
    //              desde el inicio. GoRouter redirige de / a /home/student.
    // Entrada:     Estado del AuthCubit = AuthAuthenticated(StudentModel).
    // Salida:      StudentHomeScreen visible con NavigationBar y "Acciones rápidas".
    testWidgets(
      'Paso 2: tras autenticarse como estudiante, el router muestra StudentHomeScreen',
      (tester) async {
        print('[IT] Simulando login exitoso como estudiante...');

        final student = createMockStudent();
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildStudentApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
          ),
        );

        // El router reactivo redirige / → /home/student al recibir
        // AuthAuthenticated. Se necesita pump adicional para que el
        // StatefulShellRoute monte sus branches.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Salida esperada 1: NavigationBar del shell del estudiante.
        expect(
          find.byType(NavigationBar),
          findsOneWidget,
          reason: 'El shell del estudiante debe mostrar NavigationBar',
        );

        // Salida esperada 2: sección "Acciones rápidas" de StudentHomeScreen.
        expect(
          find.text('Acciones rápidas'),
          findsOneWidget,
          reason: 'StudentHomeScreen debe mostrar la sección de acciones rápidas',
        );

        // Salida esperada 3: saludo con el nombre del estudiante mock ("Ana").
        expect(
          find.textContaining('Ana'),
          findsAtLeastNWidgets(1),
          reason: 'StudentHomeScreen debe mostrar el nombre del estudiante',
        );

        print('[IT] ✅ Paso 2 completado — StudentHomeScreen visible');
      },
    );

    // ── Paso 3: Navegación al tab Estadísticas ───────────────────────────────
    //
    // Mecanismo:   Con el shell del estudiante activo, se hace tap en el
    //              NavigationDestination con label "Estadísticas" (índice 3).
    //              GoRouter navega a /home/student/statistics y monta
    //              StudentStatisticsScreen.
    // Entrada:     NavigationBar con índice 0 (Inicio) activo.
    // Salida:      NavigationBar aún visible; LoginScreen NO visible.
    testWidgets(
      'Paso 3: tap en tab Estadísticas lleva a la pantalla de estadísticas del estudiante',
      (tester) async {
        print('[IT] Probando navegación al tab Estadísticas...');

        final student = createMockStudent();
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildStudentApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // El NavigationBar del estudiante incluye un destino "Estadísticas"
        // (l10n.statisticsTab = "Estadísticas").
        final statsTab = find.text('Estadísticas');
        expect(
          statsTab,
          findsOneWidget,
          reason: 'El tab de Estadísticas debe estar visible en NavigationBar',
        );

        // Acción: tap en el tab de Estadísticas.
        await tester.tap(statsTab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Salida esperada 1: NavigationBar aún visible (seguimos en el shell).
        expect(
          find.byType(NavigationBar),
          findsOneWidget,
          reason: 'NavigationBar debe seguir visible tras navegar a Estadísticas',
        );

        // Salida esperada 2: NO se regresó a LoginScreen.
        expect(
          find.text('Bienvenido'),
          findsNothing,
          reason: 'No debe verse LoginScreen tras navegar a Estadísticas',
        );

        print('[IT] ✅ Paso 3 completado — pantalla de Estadísticas accesible');
      },
    );

    // ── Paso 4: Navegación al tab Ajustes/Perfil ─────────────────────────────
    //
    // Mecanismo:   Desde el shell del estudiante, tap en el tab con label
    //              "Perfil" (l10n.profileTab). GoRouter navega a
    //              /home/student/settings y monta SettingsScreen.
    // Entrada:     NavigationBar del estudiante visible.
    // Salida:      SettingsScreen visible con AppBar "Ajustes" (l10n.settingsTitle).
    testWidgets(
      'Paso 4: tap en tab Perfil muestra SettingsScreen con título "Ajustes"',
      (tester) async {
        print('[IT] Probando navegación al tab Ajustes...');

        final student = createMockStudent();
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildStudentApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // El último tab es "Perfil" (l10n.profileTab = "Perfil").
        // CustomBottomNavigationBar asigna este label al tab de SettingsScreen.
        final profileTab = find.text('Perfil');
        expect(
          profileTab,
          findsOneWidget,
          reason: 'El tab de Perfil/Ajustes debe estar visible en NavigationBar',
        );

        // Acción: tap en el tab de Perfil.
        await tester.tap(profileTab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Salida esperada 1: título "Ajustes" en el AppBar de SettingsScreen
        //                    (l10n.settingsTitle = "Ajustes").
        expect(
          find.text('Ajustes'),
          findsAtLeastNWidgets(1),
          reason:
              'SettingsScreen debe mostrar el título "Ajustes" en su AppBar',
        );

        // Salida esperada 2: NavigationBar aún visible.
        expect(
          find.byType(NavigationBar),
          findsOneWidget,
          reason:
              'NavigationBar debe seguir visible en la pantalla de Ajustes',
        );

        print('[IT] ✅ Paso 4 completado — SettingsScreen visible');
      },
    );

    // ── Flujo completo integrado ─────────────────────────────────────────────
    //
    // Mecanismo:   Ejecuta los cuatro pasos del flujo en un único test
    //              continuo: arranque autenticado → home → estadísticas →
    //              ajustes → volver a inicio.
    // Entradas:    AuthCubit emite AuthAuthenticated(StudentModel) desde inicio.
    //              Todos los repositorios devuelven streams/futures vacíos.
    // Salida:      NavigationBar visible en todas las pantallas del shell;
    //              textos clave de cada pantalla encontrados sin excepciones
    //              ni navegaciones incorrectas.
    testWidgets(
      'Flujo completo: home del estudiante → estadísticas → ajustes → home',
      (tester) async {
        print('[IT] Ejecutando flujo completo de navegación del estudiante...');

        final student = createMockStudent();
        final authenticatedState = AuthAuthenticated(user: student);

        when(() => mockAuthCubit.state).thenReturn(authenticatedState);
        when(() => mockAuthCubit.stream).thenAnswer(
          (_) => Stream.value(authenticatedState),
        );

        await tester.pumpWidget(
          _buildStudentApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // ── Verificar StudentHomeScreen ────────────────────────────────────
        print('[IT]   [1/4] Verificando StudentHomeScreen...');
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Acciones rápidas'), findsOneWidget);

        // ── Navegar a Estadísticas ─────────────────────────────────────────
        print('[IT]   [2/4] Navegando a Estadísticas...');
        await tester.tap(find.text('Estadísticas'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.byType(NavigationBar),
          findsOneWidget,
          reason: 'NavigationBar visible en tab Estadísticas',
        );
        expect(
          find.text('Bienvenido'),
          findsNothing,
          reason: 'No debe mostrarse LoginScreen',
        );

        // ── Navegar a Ajustes ──────────────────────────────────────────────
        print('[IT]   [3/4] Navegando a Ajustes (tab Perfil)...');
        await tester.tap(find.text('Perfil'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(
          find.text('Ajustes'),
          findsAtLeastNWidgets(1),
          reason: 'SettingsScreen debe mostrar título "Ajustes"',
        );

        // ── Volver a Inicio ────────────────────────────────────────────────
        print('[IT]   [4/4] Regresando a Inicio...');
        await tester.tap(find.text('Inicio'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.text('Acciones rápidas'),
          findsOneWidget,
          reason: 'StudentHomeScreen debe volver a mostrar "Acciones rápidas"',
        );

        print('[IT] ✅ Flujo completo completado con éxito');
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/config/routes/app_routes.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';
import 'package:playing_tracker/features/settings/data/services/settings_service.dart';
import 'package:playing_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';

import '../../../helpers/mock_hydrated_storage.dart';
import '../../../helpers/user_test_helpers.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockSessionRepository extends Mock implements SessionRepository {}
class _MockTaskRepository extends Mock implements TaskRepository {}
class _MockSettingsService extends Mock implements SettingsService {}

class _TestAuthCubit extends AuthCubit {
  _TestAuthCubit(super.repository) : super(shouldCheckAuthState: false);

  void setTestState(AuthState state) => emit(state);
}

void main() {
  late _MockAuthRepository mockAuthRepository;
  late _MockSessionRepository mockSessionRepository;
  late _MockTaskRepository mockTaskRepository;
  late _MockSettingsService mockSettingsService;
  late _TestAuthCubit testAuthCubit;
  late AppRoutes appRoutes;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    initHydratedStorage();
    mockAuthRepository = _MockAuthRepository();
    mockSessionRepository = _MockSessionRepository();
    mockTaskRepository = _MockTaskRepository();
    mockSettingsService = _MockSettingsService();
    when(() => mockSettingsService.getThemeMode()).thenReturn(ThemeMode.system);
    when(() => mockSettingsService.getLocale()).thenReturn(null);
    when(() => mockSettingsService.getSeedColor()).thenReturn(null);
    when(() => mockSettingsService.isStudentTutorialDone()).thenReturn(true);
    when(() => mockSettingsService.isTeacherTutorialDone()).thenReturn(true);
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    when(() => mockSessionRepository.watchWeeklySessions(
          studentId: any(named: 'studentId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) => Stream.value(<SessionModel>[]));
    when(() => mockSessionRepository.watchStudentSessions(
          studentId: any(named: 'studentId'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) => const Stream.empty());
    when(() => mockTaskRepository.watchStudentAssignments(any()))
        .thenAnswer((_) => Stream.value(<AssignmentModel>[]));
    testAuthCubit = _TestAuthCubit(mockAuthRepository);
    appRoutes = AppRoutes(testAuthCubit);
  });

  Widget buildRouter() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: mockAuthRepository),
        RepositoryProvider<SessionRepository>.value(value: mockSessionRepository),
        RepositoryProvider<TaskRepository>.value(value: mockTaskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: testAuthCubit),
          BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(mockSettingsService),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: appRoutes.router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es')],
        ),
      ),
    );
  }

  testWidgets('redirecciona a login cuando no hay sesión', (tester) async {
    testAuthCubit.setTestState(const AuthUnauthenticated());

    await tester.pumpWidget(buildRouter());
    await tester.pumpAndSettle();

    expect(find.text('¿Listo para seguir tu progreso?'), findsOneWidget);
  });

  testWidgets('docente autenticado llega a su home', (tester) async {
    testAuthCubit.setTestState(
      AuthAuthenticated(user: createMockTeacher(id: 't-1')),
    );

    await tester.pumpWidget(buildRouter());
    await tester.pumpAndSettle();

    expect(find.text('¡Hola, Juan!'), findsOneWidget);
  });

  testWidgets(
    'estudiante no puede acceder a rutas de docente y vuelve a su home',
    (tester) async {
      testAuthCubit.setTestState(
        AuthAuthenticated(user: createMockStudent(id: 's-1')),
      );

      await tester.pumpWidget(buildRouter());
      await tester.pumpAndSettle();

      expect(find.text('¡Hola, Ana!'), findsOneWidget);

      appRoutes.router.go(AppRoutes.teacherClassesList);
      await tester.pumpAndSettle();

      expect(find.text('¡Hola, Ana!'), findsOneWidget);
      expect(find.text('¡Hola, Juan!'), findsNothing);
    },
  );
}

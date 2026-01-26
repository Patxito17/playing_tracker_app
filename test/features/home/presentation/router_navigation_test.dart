import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/config/routes/app_routes.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';

import '../../../helpers/mock_hydrated_storage.dart';
import '../../../helpers/user_test_helpers.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _TestAuthCubit extends AuthCubit {
  _TestAuthCubit(super.repository) : super(shouldCheckAuthState: false);

  void setTestState(AuthState state) => emit(state);
}

void main() {
  late _MockAuthRepository mockAuthRepository;
  late _TestAuthCubit testAuthCubit;
  late AppRoutes appRoutes;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    initHydratedStorage();
    mockAuthRepository = _MockAuthRepository();
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    testAuthCubit = _TestAuthCubit(mockAuthRepository);
    appRoutes = AppRoutes(testAuthCubit);
  });

  Widget buildRouter() {
    return RepositoryProvider<AuthRepository>.value(
      value: mockAuthRepository,
      child: BlocProvider<AuthCubit>.value(
        value: testAuthCubit,
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

    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
  });

  testWidgets('docente autenticado llega a su home', (tester) async {
    testAuthCubit.setTestState(
      AuthAuthenticated(user: createMockTeacher(id: 't-1')),
    );

    await tester.pumpWidget(buildRouter());
    await tester.pumpAndSettle();

    expect(find.text('Tus clases están listas'), findsOneWidget);
  });

  testWidgets(
    'estudiante no puede acceder a rutas de docente y vuelve a su home',
    (tester) async {
      testAuthCubit.setTestState(
        AuthAuthenticated(user: createMockStudent(id: 's-1')),
      );

      await tester.pumpWidget(buildRouter());
      await tester.pumpAndSettle();

      expect(find.text('Tu práctica continúa'), findsOneWidget);

      appRoutes.router.go(AppRoutes.teacherClassesList);
      await tester.pumpAndSettle();

      expect(find.text('Tu práctica continúa'), findsOneWidget);
      expect(find.text('Tus clases están listas'), findsNothing);
    },
  );
}

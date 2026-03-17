// Smoke test de la aplicación Playing Tracker.
//
// Mecanismo: renderiza la LoginScreen directamente con un AuthCubit
// mockeado, sin inicializar Firebase, para verificar que la pantalla de
// bienvenida se muestra correctamente.
//
// Se utiliza LoginScreen en lugar de PlayingTrackerApp porque
// PlayingTrackerApp instancia StatisticsRepositoryImpl de forma interna,
// lo que requiere Firebase inicializado (no disponible en tests unitarios).

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';
import 'package:playing_tracker/l10n/l10n.dart';

import 'helpers/mock_hydrated_storage.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockAuthCubit mockAuthCubit;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    initHydratedStorage();
    mockAuthCubit = _MockAuthCubit();

    when(() => mockAuthCubit.state).thenReturn(const AuthInitial());
  });

  // Mecanismo: renderiza LoginScreen con localización española configurada.
  // Entradas: AuthCubit en estado inicial (no autenticado).
  // Salida esperada: se muestra el texto de bienvenida "Bienvenido".
  testWidgets('Playing Tracker app smoke test — muestra pantalla de bienvenida', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: L10n.all,
        locale: const Locale('es'),
        home: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Bienvenido'), findsOneWidget);
  });
}

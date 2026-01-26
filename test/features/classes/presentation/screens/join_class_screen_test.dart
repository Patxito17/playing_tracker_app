import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/screens/join_class_screen.dart';
import 'package:playing_tracker/shared/widgets/custom_button.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockClassRepository extends Mock implements ClassRepository {}

void main() {
  late MembershipCubit membershipCubit;
  late _MockAuthCubit authCubit;
  late GoRouter router;
  late _MockClassRepository classRepository;

  setUpAll(() {
    registerFallbackValue((studentId: 'student', accessCode: 'ABC234'));
  });

  setUp(() {
    classRepository = _MockClassRepository();
    membershipCubit = MembershipCubit(classRepository);
    authCubit = _MockAuthCubit();
    when(() => authCubit.state).thenReturn(
      const AuthAuthenticated(role: UserRole.student, userId: 'student-1'),
    );
    when(
      () => authCubit.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
  });

  tearDown(() async {
    await membershipCubit.close();
    router.dispose();
  });

  Widget buildApp() {
    router = GoRouter(
      initialLocation: '/join',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/join',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<MembershipCubit>.value(value: membershipCubit),
              BlocProvider<AuthCubit>.value(value: authCubit),
            ],
            child: const JoinClassScreen(),
          ),
        ),
      ],
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
    );
  }

  testWidgets('muestra error cuando el código está vacío', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.widgetWithText(CustomButton, 'Unirse'));
    await tester.pump();

    expect(find.text('Código de acceso es requerido'), findsWidgets);
    verifyNever(() => classRepository.joinClassWithCode(any()));
  });

  testWidgets('normaliza el código y llama joinClass', (tester) async {
    when(
      () => classRepository.joinClassWithCode(any()),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());

    await tester.enterText(find.bySemanticsLabel('Código de acceso'), 'abc234');
    await tester.tap(find.widgetWithText(CustomButton, 'Unirse'));
    await tester.pump();

    final captured =
        verify(
              () => classRepository.joinClassWithCode(captureAny()),
            ).captured.single
            as JoinClassInput;
    expect(captured.accessCode, equals('ABC234'));
    expect(captured.studentId, equals('student-1'));
  });

  testWidgets('muestra banner de éxito tras completar la unión', (
    tester,
  ) async {
    when(
      () => classRepository.joinClassWithCode(any()),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());

    await tester.enterText(find.bySemanticsLabel('Código de acceso'), 'ABC234');
    await tester.tap(find.widgetWithText(CustomButton, 'Unirse'));
    await tester.pump(); // loading
    await tester.pump(); // success

    expect(find.text('Te uniste a la clase correctamente.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_state.dart';
import 'package:playing_tracker/features/classes/presentation/screens/create_class_screen.dart';
import 'package:playing_tracker/shared/widgets/custom_button.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';

import '../../../../helpers/user_test_helpers.dart';

class _MockClassRepository extends Mock implements ClassRepository {}

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockClassRepository mockClassRepository;
  late ClassCubit classCubit;
  late _MockAuthCubit mockAuthCubit;

  setUpAll(() {
    registerFallbackValue((
      name: 'fallback',
      description: 'fallback',
      ownerId: 'owner',
    ));
  });

  setUp(() {
    mockClassRepository = _MockClassRepository();
    classCubit = ClassCubit(mockClassRepository);
    mockAuthCubit = _MockAuthCubit();
    when(
      () => mockAuthCubit.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    when(
      () => mockAuthCubit.state,
    ).thenReturn(AuthAuthenticated(user: createMockTeacher(id: 'teacher-1')));
  });

  tearDown(() => classCubit.close());

  Widget buildTestScreen() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<ClassCubit>.value(value: classCubit),
              BlocProvider<AuthCubit>.value(value: mockAuthCubit),
            ],
            child: const CreateClassScreen(),
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

  testWidgets('invoca createClass cuando el formulario es válido', (
    tester,
  ) async {
    when(() => mockClassRepository.createClass(any())).thenAnswer(
      (_) async => ClassModel(
        id: 'class-1',
        name: 'Piano nivel 1',
        ownerTeacherId: 'teacher-1',
        description: 'Demo',
        accessCode: 'ABC234',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        isActive: true,
      ),
    );

    await tester.pumpWidget(buildTestScreen());

    await tester.enterText(
      find.bySemanticsLabel('Nombre de la clase'),
      'Piano nivel 1',
    );
    await tester.enterText(
      find.bySemanticsLabel('Descripción'),
      'Descripción demo',
    );
    await tester.tap(find.widgetWithText(CustomButton, 'Crear clase'));
    await tester.pump();
  });

  testWidgets('muestra mensaje de error cuando el estado es ClassError', (
    tester,
  ) async {
    classCubit.emit(
      const ClassError(message: 'No fue posible crear la clase.'),
    );

    await tester.pumpWidget(buildTestScreen());

    expect(find.text('No fue posible crear la clase.'), findsOneWidget);
  });
}

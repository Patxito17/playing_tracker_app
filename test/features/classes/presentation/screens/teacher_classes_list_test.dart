import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_state.dart';
import 'package:playing_tracker/features/classes/presentation/screens/teacher_classes_list_screen.dart';
import 'package:playing_tracker/features/classes/presentation/constants/classes_strings.dart';

class MockClassCubit extends Mock implements ClassCubit {}

void main() {
  late MockClassCubit mockClassCubit;

  setUp(() {
    mockClassCubit = MockClassCubit();
  });

  Widget makeTestableWidget(Widget child) {
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (context, state) => child)],
    );

    return MaterialApp.router(
      routerConfig: router,
      builder: (context, child) =>
          BlocProvider<ClassCubit>.value(value: mockClassCubit, child: child!),
    );
  }

  group('TeacherClassesListScreen', () {
    testWidgets('shows loading indicator', (WidgetTester tester) async {
      when(() => mockClassCubit.state).thenReturn(const ClassLoading());
      when(() => mockClassCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        makeTestableWidget(const TeacherClassesListScreen()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state message', (WidgetTester tester) async {
      const message = 'No hay clases';
      when(
        () => mockClassCubit.state,
      ).thenReturn(const ClassEmpty(message: message));
      when(() => mockClassCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        makeTestableWidget(const TeacherClassesListScreen()),
      );

      expect(find.text(message), findsOneWidget);
      expect(
        find.text(ClassesStrings.createClass),
        findsWidgets,
      ); // One in FAB, one in empty state button
    });

    testWidgets('shows list of classes', (WidgetTester tester) async {
      final classes = [
        ClassModel(
          id: '1',
          name: 'Clase de Prueba 1',
          ownerTeacherId: 't1',
          accessCode: '123456',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        ),
        ClassModel(
          id: '2',
          name: 'Clase de Prueba 2',
          ownerTeacherId: 't1',
          accessCode: '654321',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        ),
      ];

      when(
        () => mockClassCubit.state,
      ).thenReturn(ClassSuccess(classes: classes));
      when(
        () => mockClassCubit.stream,
      ).thenAnswer((_) => Stream.value(ClassSuccess(classes: classes)));

      await tester.pumpWidget(
        makeTestableWidget(const TeacherClassesListScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Clase de Prueba 1'), findsOneWidget);
      expect(find.text('Clase de Prueba 2'), findsOneWidget);
    });
  });
}

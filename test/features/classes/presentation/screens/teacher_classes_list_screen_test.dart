import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_state.dart';
import 'package:playing_tracker/features/classes/presentation/screens/teacher_classes_list_screen.dart';

class _MockClassRepository extends Mock implements ClassRepository {}

void main() {
  late _MockClassRepository mockClassRepository;
  late ClassCubit classCubit;

  setUp(() {
    mockClassRepository = _MockClassRepository();
    classCubit = ClassCubit(mockClassRepository);
  });

  tearDown(() => classCubit.close());

  Widget buildTestRouter() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<ClassCubit>.value(
            value: classCubit,
            child: const TeacherClassesListScreen(),
          ),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('muestra indicador de carga cuando el estado es ClassLoading', (
    tester,
  ) async {
    classCubit.emit(const ClassLoading());

    await tester.pumpWidget(buildTestRouter());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra estado vacío cuando no hay clases', (tester) async {
    classCubit.emit(const ClassEmpty(message: ClassesStrings.noClassesCreated));

    await tester.pumpWidget(buildTestRouter());

    expect(find.text(ClassesStrings.noClassesCreated), findsOneWidget);
  });

  testWidgets('renderiza tarjetas cuando hay clases disponibles', (
    tester,
  ) async {
    final classModel = ClassModel(
      id: 'class-1',
      name: 'Piano nivel 1',
      description: 'Sesiones introductorias',
      ownerTeacherId: 'teacher-1',
      accessCode: 'ABC234',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isActive: true,
    );

    classCubit.emit(ClassSuccess(classes: [classModel]));

    await tester.pumpWidget(buildTestRouter());

    expect(find.text('Piano nivel 1'), findsOneWidget);
    expect(find.textContaining('ABC234'), findsOneWidget);
  });
}

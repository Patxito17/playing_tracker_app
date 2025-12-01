import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/screens/manage_students_screen.dart';

class _MockClassRepository extends Mock implements ClassRepository {}

void main() {
  late _MockClassRepository classRepository;
  late ClassModel classModel;
  late MembershipCubit membershipCubit;

  setUp(() {
    classRepository = _MockClassRepository();
    classModel = ClassModel(
      id: 'class-1',
      name: 'Piano nivel 1',
      accessCode: 'ABC234',
      ownerTeacherId: 'teacher-1',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isActive: true,
    );

    when(
      () => classRepository.getClassById(any()),
    ).thenAnswer((_) async => classModel);

    membershipCubit = MembershipCubit(classRepository);
  });

  tearDown(() => membershipCubit.close());

  Future<void> pumpSubject(
    WidgetTester tester, {
    required Future<MembershipPage> Function(Invocation) listMembersAnswer,
  }) async {
    when(
      () => classRepository.listClassMembers(
        classId: any(named: 'classId'),
        limit: any(named: 'limit'),
        startAfterId: any(named: 'startAfterId'),
        includeInactive: any(named: 'includeInactive'),
      ),
    ).thenAnswer(listMembersAnswer);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              RepositoryProvider<ClassRepository>.value(
                value: classRepository,
                child: BlocProvider<MembershipCubit>.value(
                  value: membershipCubit,
                  child: const ManageStudentsScreen(classId: 'class-1'),
                ),
              ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  testWidgets(
    'muestra indicador de carga mientras se resuelve la lista de alumnos',
    (tester) async {
      final completer = Completer<MembershipPage>();
      await pumpSubject(tester, listMembersAnswer: (_) => completer.future);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      completer.complete((members: <MembershipModel>[], lastDocumentId: null));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('muestra estado vacío cuando no hay estudiantes', (tester) async {
    await pumpSubject(
      tester,
      listMembersAnswer: (_) async =>
          (members: <MembershipModel>[], lastDocumentId: null),
    );
    await tester.pumpAndSettle();

    expect(find.text(StudentStrings.noStudentsInClass), findsOneWidget);
  });

  testWidgets('renderiza lista cuando el repositorio retorna miembros', (
    tester,
  ) async {
    final member = MembershipModel(
      id: 'class-1_student-1',
      classId: 'class-1',
      studentId: 'student-1',
      teacherId: 'teacher-1',
      className: 'Piano nivel 1',
      joinedAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isActive: true,
    );

    await pumpSubject(
      tester,
      listMembersAnswer: (_) async =>
          (members: <MembershipModel>[member], lastDocumentId: null),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(member.studentId), findsWidgets);
  });
}

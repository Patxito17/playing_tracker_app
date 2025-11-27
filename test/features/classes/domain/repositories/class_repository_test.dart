import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/classes/data/helpers/fan_out_helper.dart';
import 'package:playing_tracker/features/classes/data/repositories/class_repository_impl.dart';
import 'package:playing_tracker/features/classes/data/services/class_service.dart';
import 'package:playing_tracker/features/classes/data/services/membership_service.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/create_class_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';

class _MockClassService extends Mock implements ClassServiceContract {}

class _MockMembershipService extends Mock
    implements MembershipServiceContract {}

class _MockFanOutHelper extends Mock implements FanOutHelperContract {}

void main() {
  late _MockClassService classService;
  late _MockMembershipService membershipService;
  late _MockFanOutHelper fanOutHelper;
  late ClassRepository repository;

  setUp(() {
    classService = _MockClassService();
    membershipService = _MockMembershipService();
    fanOutHelper = _MockFanOutHelper();
    repository = ClassRepositoryImpl(
      classService: classService,
      membershipService: membershipService,
      fanOutHelper: fanOutHelper,
    );
  });

  group('createClass', () {
    test('debe validar input y delegar en ClassService', () async {
      final input = (
        name: 'Nueva clase',
        description: 'Descripción opcional',
        ownerId: 'teacher-123',
      );
      final model = ClassModel(
        id: 'class-1',
        name: input.name,
        description: input.description,
        ownerTeacherId: input.ownerId,
        accessCode: 'ABC234',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        isActive: true,
      );

      when(
        () => classService.createClass(input),
      ).thenAnswer((_) async => model);

      expect(() => validateCreateClassInput(input), returnsNormally);
      final result = await repository.createClass(input);

      expect(result, model);
      verify(() => classService.createClass(input)).called(1);
    });
  });

  group('watchTeacherClasses', () {
    test('debe emitir lotes paginados provenientes del servicio', () async {
      final teacherId = 'teacher-456';
      final classes = [
        ClassModel(
          id: 'class-1',
          name: 'Clase demo',
          ownerTeacherId: teacherId,
          accessCode: 'ABC234',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          isActive: true,
        ),
      ];
      final controller = StreamController<List<ClassModel>>();
      addTearDown(controller.close);

      when(
        () => classService.watchTeacherClasses(
          teacherId: teacherId,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => controller.stream);

      final stream = repository.watchTeacherClasses(teacherId: teacherId);
      controller.add(classes);

      await expectLater(stream, emits(classes));
      verify(
        () => classService.watchTeacherClasses(teacherId: teacherId, limit: 20),
      ).called(1);
    });
  });

  group('getClassById', () {
    test('debe retornar null cuando la clase no existe', () async {
      const classId = 'inexistent';
      when(
        () => classService.getClassById(classId),
      ).thenAnswer((_) async => null);

      final result = await repository.getClassById(classId);

      expect(result, isNull);
      verify(() => classService.getClassById(classId)).called(1);
    });
  });

  group('inviteStudent', () {
    test('debe delegar en MembershipService', () async {
      final input = (
        classId: 'class-id',
        studentId: 'student-id',
        teacherId: 'teacher-id',
        className: 'Clase Demo',
      );

      when(
        () => membershipService.inviteStudent(input),
      ).thenAnswer((_) async {});

      expect(() => validateInviteStudentInput(input), returnsNormally);
      await repository.inviteStudent(input);

      verify(() => membershipService.inviteStudent(input)).called(1);
    });
  });

  group('joinClassWithCode', () {
    test('debe consultar MembershipService', () async {
      final input = (studentId: 'student-1', accessCode: 'ABC234');

      when(
        () => membershipService.joinClassWithCode(input),
      ).thenAnswer((_) async {});

      expect(() => validateJoinClassInput(input), returnsNormally);
      await repository.joinClassWithCode(input);

      verify(() => membershipService.joinClassWithCode(input)).called(1);
    });
  });

  group('updateClassStatus', () {
    test('debe actualizar clase y memberships asociados', () async {
      when(
        () => classService.updateClassStatus(
          classId: any(named: 'classId'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => membershipService.updateMembershipsClassStatus(
          classId: any(named: 'classId'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer((_) async {});

      await repository.updateClassStatus(classId: 'class-1', isActive: false);

      verify(
        () =>
            classService.updateClassStatus(classId: 'class-1', isActive: false),
      ).called(1);
      verify(
        () => membershipService.updateMembershipsClassStatus(
          classId: 'class-1',
          isActive: false,
        ),
      ).called(1);
    });
  });

  group('removeStudentFromClass', () {
    test('debe remover alumno usando MembershipService', () async {
      when(
        () => membershipService.removeStudent(any()),
      ).thenAnswer((_) async {});

      await repository.removeStudentFromClass(
        classId: 'class-1',
        studentId: 'student-9',
      );

      verify(
        () => membershipService.removeStudent('class-1_student-9'),
      ).called(1);
    });
  });

  group('regenerateAccessCode', () {
    test('debe delegar en ClassService', () async {
      when(
        () => classService.regenerateAccessCode('class-1'),
      ).thenAnswer((_) async {});

      await repository.regenerateAccessCode('class-1');

      verify(() => classService.regenerateAccessCode('class-1')).called(1);
    });
  });

  group('fanOutTask', () {
    test(
      'debe delegar en FanOutHelper y registrar TODO para Sprint 4',
      () {
        // TODO(sprint4): Integrar con helper fan-out y assignments.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación',
    );
  });
}

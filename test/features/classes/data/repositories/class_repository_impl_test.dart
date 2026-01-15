import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/classes/data/helpers/fan_out_helper.dart';
import 'package:playing_tracker/features/classes/data/repositories/class_repository_impl.dart';
import 'package:playing_tracker/features/classes/data/services/class_service.dart';
import 'package:playing_tracker/features/classes/data/services/membership_service.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/create_class_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';
import 'package:playing_tracker/features/tasks/data/services/assignment_service.dart';

class _MockClassService extends Mock implements ClassServiceContract {}

class _MockMembershipService extends Mock
    implements MembershipServiceContract {}

class _MockFanOutHelper extends Mock implements FanOutHelperContract {}

class _MockAssignmentService extends Mock
    implements AssignmentServiceContract {}

void main() {
  late ClassRepositoryImpl repository;
  late _MockClassService classService;
  late _MockMembershipService membershipService;
  late _MockFanOutHelper fanOutHelper;
  late _MockAssignmentService assignmentService;

  setUpAll(() {
    registerFallbackValue(_createClassInput());
    registerFallbackValue(_inviteInput());
    registerFallbackValue(_joinInput());
  });

  setUp(() {
    classService = _MockClassService();
    membershipService = _MockMembershipService();
    fanOutHelper = _MockFanOutHelper();
    assignmentService = _MockAssignmentService();
    repository = ClassRepositoryImpl(
      classService: classService,
      membershipService: membershipService,
      assignmentService: assignmentService,
      fanOutHelper: fanOutHelper,
    );
  });

  test('createClass delega en ClassService y retorna el modelo', () async {
    final expected = _classModel();
    when(
      () => classService.createClass(any()),
    ).thenAnswer((_) async => expected);

    final result = await repository.createClass(_createClassInput());

    expect(result, equals(expected));
    verify(() => classService.createClass(any())).called(1);
  });

  test(
    'watchTeacherClasses emite los valores del servicio sin transformaciones',
    () async {
      final controller = StreamController<List<ClassModel>>();
      when(
        () => classService.watchTeacherClasses(
          teacherId: any(named: 'teacherId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => controller.stream);

      final resultStream = repository.watchTeacherClasses(
        teacherId: 'teacher-1',
      );

      final expectation = expectLater(
        resultStream,
        emits(isA<List<ClassModel>>()),
      );
      controller.add([_classModel()]);
      await controller.close();
      await expectation;
      verify(
        () => classService.watchTeacherClasses(
          teacherId: 'teacher-1',
          limit: any(named: 'limit'),
        ),
      ).called(1);
    },
  );

  test(
    'watchTeacherClasses mapea errores a UnknownClassRepositoryException',
    () async {
      final controller = StreamController<List<ClassModel>>();
      when(
        () => classService.watchTeacherClasses(
          teacherId: any(named: 'teacherId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => controller.stream);

      final resultStream = repository.watchTeacherClasses(
        teacherId: 'teacher-1',
      );
      final expectation = expectLater(
        resultStream,
        emitsError(isA<UnknownClassRepositoryException>()),
      );
      controller.addError(FirebaseErrorMapperException('boom'));
      await controller.close();
      await expectation;
    },
  );

  test(
    'joinClassWithCode convierte errores en InvalidAccessCodeException',
    () async {
      when(
        () => membershipService.joinClassWithCode(any()),
      ).thenThrow(FirebaseErrorMapperException('Código inválido'));

      expect(
        () => repository.joinClassWithCode(_joinInput()),
        throwsA(isA<InvalidAccessCodeException>()),
      );
    },
  );

  test('fanOutTask delega en FanOutHelper', () async {
    when(
      () => fanOutHelper.prepareFanOut(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => fanOutHelper.propagateToAssignments(any(), any()),
    ).thenAnswer((_) async {});

    await repository.fanOutTask(taskId: 'task-123', classId: 'class-456');

    verify(() => fanOutHelper.prepareFanOut('task-123', 'class-456')).called(1);
    verify(
      () => fanOutHelper.propagateToAssignments('task-123', 'class-456'),
    ).called(1);
  });

  test(
    'deleteClassPermanent elimina memberships, assignments y la clase',
    () async {
      when(
        () => membershipService.deleteMembershipsByClass(any()),
      ).thenAnswer((_) async {});
      when(
        () => assignmentService.deleteAssignmentsByClass(any()),
      ).thenAnswer((_) async {});
      when(() => classService.deleteClass(any())).thenAnswer((_) async {});

      await repository.deleteClassPermanent('class-1');

      verify(
        () => membershipService.deleteMembershipsByClass('class-1'),
      ).called(1);
      verify(
        () => assignmentService.deleteAssignmentsByClass('class-1'),
      ).called(1);
      verify(() => classService.deleteClass('class-1')).called(1);
    },
  );
}

CreateClassInput _createClassInput() => (
  name: 'Nueva clase',
  description: 'Descripción demo',
  ownerId: 'teacher-1',
);

InviteStudentInput _inviteInput() => (
  classId: 'class-1',
  studentId: 'student-1',
  teacherId: 'teacher-1',
  className: 'Clase demo',
);

JoinClassInput _joinInput() => (studentId: 'student-1', accessCode: 'ABC234');

ClassModel _classModel() => ClassModel(
  id: 'class-1',
  name: 'Clase demo',
  description: 'Descripción',
  ownerTeacherId: 'teacher-1',
  accessCode: 'ABC234',
  createdAt: Timestamp.now(),
  updatedAt: Timestamp.now(),
  isActive: true,
);

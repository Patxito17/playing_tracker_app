import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/classes/data/helpers/fan_out_helper.dart';
import 'package:playing_tracker/features/classes/data/services/class_service.dart';
import 'package:playing_tracker/features/classes/data/services/membership_service.dart';
import 'package:playing_tracker/features/tasks/data/services/assignment_service.dart';
import 'package:playing_tracker/features/tasks/data/services/task_service.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';

class _MockMembershipService extends Mock
    implements MembershipServiceContract {}

class _MockAssignmentService extends Mock
    implements AssignmentServiceContract {}

class _MockTaskService extends Mock implements TaskServiceContract {}

class _MockClassService extends Mock implements ClassServiceContract {}

void main() {
  late _MockMembershipService membershipService;
  late _MockAssignmentService assignmentService;
  late _MockTaskService taskService;
  late _MockClassService classService;
  late FanOutHelper helper;

  setUpAll(() {
    registerFallbackValue(<AssignmentFanOutData>[]);
  });

  setUp(() {
    membershipService = _MockMembershipService();
    assignmentService = _MockAssignmentService();
    taskService = _MockTaskService();
    classService = _MockClassService();
    helper = FanOutHelper(
      membershipService: membershipService,
      assignmentService: assignmentService,
      taskService: taskService,
      classService: classService,
    );
  });

  TaskModel buildTaskModel() {
    final timestamp = Timestamp.now();
    return TaskModel(
      id: 'task-1',
      title: 'Escalas mayores',
      description: 'Practicar escalas',
      createdBy: 'teacher-1',
      durationSuggested: 900,
      attachmentUrl: null,
      createdAt: timestamp,
      updatedAt: timestamp,
      dueDate: null,
      isActive: true,
    );
  }

  test('propaga fan-out creando assignments para todos los alumnos', () async {
    when(
      () => taskService.getTaskById('task-1'),
    ).thenAnswer((_) async => buildTaskModel());
    when(
      () => membershipService.getStudentsForClass('class-1'),
    ).thenAnswer((_) async => ['student-1', 'student-2']);
    when(() => classService.getClassById('class-1')).thenAnswer(
      (_) async => ClassModel(
        id: 'class-1',
        name: 'Clase Test',
        description: null,
        ownerTeacherId: 'teacher-1',
        accessCode: 'A1B2C3',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        isActive: true,
      ),
    );
    when(
      () => assignmentService.createAssignmentsBatch(any()),
    ).thenAnswer((_) async {});
    when(
      () => assignmentService.getAssignmentsByTaskAndClass(
        taskId: any(named: 'taskId'),
        classId: any(named: 'classId'),
        teacherId: any(named: 'teacherId'),
      ),
    ).thenAnswer((_) async => []);

    await helper.prepareFanOut('task-1', 'class-1');
    await helper.propagateToAssignments('task-1', 'class-1');

    final captured =
        verify(
              () => assignmentService.createAssignmentsBatch(captureAny()),
            ).captured.single
            as List<AssignmentFanOutData>;
    expect(captured.length, 2);
    expect(captured.first.taskDescription, 'Practicar escalas');
  });

  test('propagateToAssignments sin prepare no ejecuta batch', () async {
    await helper.propagateToAssignments('task-x', 'class-x');

    verifyNever(() => assignmentService.createAssignmentsBatch(any()));
  });
}

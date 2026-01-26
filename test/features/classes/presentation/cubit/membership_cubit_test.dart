import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart'
    show ClassRepository, ClassRepositoryException, InvalidAccessCodeException;
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_state.dart';

class _MockClassRepository extends Mock implements ClassRepository {}

void main() {
  late _MockClassRepository repository;

  setUpAll(() {
    registerFallbackValue(_inviteInput());
    registerFallbackValue(_joinInput());
  });

  setUp(() {
    repository = _MockClassRepository();
  });

  blocTest<MembershipCubit, MembershipState>(
    'inviteStudent emite success cuando el repositorio no falla',
    build: () => MembershipCubit(repository),
    act: (cubit) {
      when(() => repository.inviteStudent(any())).thenAnswer((_) async {});
      return cubit.inviteStudent(_inviteInput());
    },
    expect: () => const [
      MembershipLoading(),
      MembershipSuccess(action: MembershipAction.invitedStudent),
    ],
  );

  blocTest<MembershipCubit, MembershipState>(
    'joinClass emite error cuando el repositorio lanza excepción',
    build: () => MembershipCubit(repository),
    act: (cubit) {
      when(
        () => repository.joinClassWithCode(any()),
      ).thenThrow(const InvalidAccessCodeException('Código inválido'));
      return cubit.joinClass(_joinInput());
    },
    expect: () => [
      const MembershipLoading(),
      isA<MembershipError>()
          .having((state) => state.message, 'mensaje', 'Código inválido')
          .having(
            (state) => state.cause,
            'cause',
            isA<ClassRepositoryException>(),
          ),
    ],
  );

  blocTest<MembershipCubit, MembershipState>(
    'joinClass emite success cuando el repositorio completa la unión',
    build: () => MembershipCubit(repository),
    act: (cubit) {
      when(() => repository.joinClassWithCode(any())).thenAnswer((_) async {});
      return cubit.joinClass(_joinInput());
    },
    expect: () => const [
      MembershipLoading(),
      MembershipSuccess(action: MembershipAction.joinedClass),
    ],
    verify: (_) => verify(() => repository.joinClassWithCode(any())).called(1),
  );
}

InviteStudentInput _inviteInput() => (
  classId: 'class-1',
  studentId: 'student-1',
  teacherId: 'teacher-1',
  className: 'Clase demo',
);

JoinClassInput _joinInput() => (studentId: 'student-1', accessCode: 'ABC234');

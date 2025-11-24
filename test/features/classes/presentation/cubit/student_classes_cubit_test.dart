import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/student_classes_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/student_classes_state.dart';

class _MockClassRepository extends Mock implements ClassRepository {}

void main() {
  late _MockClassRepository repository;
  late StudentClassesCubit cubit;

  final membership = MembershipModel(
    id: 'class-1_student-1',
    classId: 'class-1',
    studentId: 'student-1',
    teacherId: 'teacher-1',
    className: 'Piano nivel 1',
    joinedAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
    isActive: true,
  );

  setUp(() {
    repository = _MockClassRepository();
    cubit = StudentClassesCubit(repository);
  });

  tearDown(() => cubit.close());

  blocTest<StudentClassesCubit, StudentClassesState>(
    'emite [Loading, Success] cuando se reciben membresías',
    build: () {
      when(
        () => repository.watchStudentMemberships(studentId: 'student-1'),
      ).thenAnswer((_) => Stream.value([membership]));
      return cubit;
    },
    act: (cubit) => cubit.watchStudentClasses(studentId: 'student-1'),
    expect: () => [
      const StudentClassesLoading(),
      StudentClassesSuccess(memberships: [membership]),
    ],
  );

  blocTest<StudentClassesCubit, StudentClassesState>(
    'emite [Loading, Empty] cuando no hay membresías',
    build: () {
      when(
        () => repository.watchStudentMemberships(studentId: 'student-1'),
      ).thenAnswer((_) => Stream.value(const []));
      return cubit;
    },
    act: (cubit) => cubit.watchStudentClasses(studentId: 'student-1'),
    expect: () => [const StudentClassesLoading(), const StudentClassesEmpty()],
  );

  const repositoryError =
      UnknownClassRepositoryException('No se pudieron cargar.');

  blocTest<StudentClassesCubit, StudentClassesState>(
    'emite [Loading, Error] cuando el stream falla',
    build: () {
      when(
        () => repository.watchStudentMemberships(studentId: 'student-1'),
      ).thenAnswer((_) => Stream.error(repositoryError));
      return cubit;
    },
    act: (cubit) => cubit.watchStudentClasses(studentId: 'student-1'),
    expect: () => [
      const StudentClassesLoading(),
      const StudentClassesError(
        message: 'No se pudieron cargar.',
        cause: repositoryError,
      ),
    ],
  );
}

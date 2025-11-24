import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/create_class_input.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_state.dart';

class _MockClassRepository extends Mock implements ClassRepository {}

void main() {
  late _MockClassRepository repository;

  setUpAll(() {
    registerFallbackValue(_createClassInput());
  });

  setUp(() {
    repository = _MockClassRepository();
  });

  blocTest<ClassCubit, ClassState>(
    'emite [ClassLoading, ClassEmpty] cuando el stream retorna lista vacía',
    build: () => ClassCubit(repository),
    act: (cubit) {
      when(
        () => repository.watchTeacherClasses(
          teacherId: any(named: 'teacherId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream.value(<ClassModel>[]));
      return cubit.watchClasses(teacherId: 'teacher-1');
    },
    expect: () => const [
      ClassLoading(),
      ClassEmpty(message: ClassesStrings.noClassesCreated),
    ],
  );

  blocTest<ClassCubit, ClassState>(
    'emite [ClassLoading, ClassSuccess] cuando el stream retorna clases',
    build: () => ClassCubit(repository),
    act: (cubit) {
      when(
        () => repository.watchTeacherClasses(
          teacherId: any(named: 'teacherId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream.value([_classModel()]));
      return cubit.watchClasses(teacherId: 'teacher-1');
    },
    expect: () => [
      const ClassLoading(),
      isA<ClassSuccess>().having(
        (state) => state.classes.length,
        'clases emitidas',
        1,
      ),
    ],
  );

  blocTest<ClassCubit, ClassState>(
    'emite ClassError cuando createClass lanza ClassRepositoryException',
    build: () => ClassCubit(repository),
    act: (cubit) {
      when(() => repository.createClass(any())).thenThrow(
        const UnknownClassRepositoryException('Error al crear clase'),
      );
      return cubit.createClass(_createClassInput());
    },
    expect: () => [
      const ClassLoading(),
      isA<ClassError>()
          .having((state) => state.message, 'mensaje', 'Error al crear clase')
          .having(
            (state) => state.cause,
            'cause',
            isA<ClassRepositoryException>(),
          ),
    ],
  );
}

CreateClassInput _createClassInput() =>
    (name: 'Clase demo', description: 'Descripción', ownerId: 'teacher-1');

ClassModel _classModel() => ClassModel(
  id: 'class-1',
  name: 'Demo',
  description: 'Descripción',
  ownerTeacherId: 'teacher-1',
  accessCode: 'ABC123',
  createdAt: Timestamp(0, 0),
  updatedAt: Timestamp(0, 0),
  isActive: true,
);

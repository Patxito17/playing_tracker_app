import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/utils/access_code_generator.dart';
import 'package:playing_tracker/features/classes/data/services/class_service.dart';

class _MockAccessCodeGenerator extends Mock implements AccessCodeGenerator {}

void main() {
  group('ClassService', () {
    late FakeFirebaseFirestore firestore;
    late _MockAccessCodeGenerator accessCodeGenerator;
    late ClassService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      accessCodeGenerator = _MockAccessCodeGenerator();
      service = ClassService(
        firestore: firestore,
        accessCodeGenerator: accessCodeGenerator,
      );
    });

    test('createClass persiste datos y retorna modelo completo', () async {
      when(() => accessCodeGenerator.generate()).thenReturn('ABC234');

      final result = await service.createClass((
        name: 'Clase Piano',
        description: '  Nivel 1 ',
        ownerId: 'teacher-1',
      ));

      expect(result.name, 'Clase Piano');
      expect(result.accessCode, 'ABC234');
      expect(result.ownerTeacherId, 'teacher-1');
      expect(result.description, 'Nivel 1');

      final storedDoc = await firestore
          .collection('classes')
          .doc(result.id)
          .get();
      expect(storedDoc.data()?['accessCode'], 'ABC234');
      expect(storedDoc.data()?['description'], 'Nivel 1');
      expect(storedDoc.data()?['isActive'], true);
    });

    test(
      'listTeacherClasses retorna clases ordenadas por createdAt desc',
      () async {
        await firestore.collection('classes').doc('class-1').set({
          'id': 'class-1',
          'name': 'Clase Antigua',
          'ownerTeacherId': 'teacher-1',
          'accessCode': 'OLD001',
          'createdAt': Timestamp.fromMillisecondsSinceEpoch(10),
          'updatedAt': Timestamp.fromMillisecondsSinceEpoch(10),
          'isActive': true,
        });
        await firestore.collection('classes').doc('class-2').set({
          'id': 'class-2',
          'name': 'Clase Reciente',
          'ownerTeacherId': 'teacher-1',
          'accessCode': 'NEW001',
          'createdAt': Timestamp.fromMillisecondsSinceEpoch(20),
          'updatedAt': Timestamp.fromMillisecondsSinceEpoch(20),
          'isActive': true,
        });

        final classes = await service.listTeacherClasses(
          teacherId: 'teacher-1',
          limit: 20,
        );

        expect(classes.first.id, 'class-2');
        expect(classes.last.id, 'class-1');
      },
    );

    test(
      'regenerateAccessCode actualiza el código evitando duplicados',
      () async {
        when(() => accessCodeGenerator.generate()).thenReturn('ABC234');
        final classModel = await service.createClass((
          name: 'Clase Piano',
          description: 'Intro',
          ownerId: 'teacher-2',
        ));

        when(() => accessCodeGenerator.generate()).thenReturn('XYZ789');
        await service.regenerateAccessCode(classModel.id);

        final updatedDoc = await firestore
            .collection('classes')
            .doc(classModel.id)
            .get();
        expect(updatedDoc.data()?['accessCode'], 'XYZ789');
      },
    );
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/classes/data/services/membership_service.dart';

void main() {
  group('MembershipService', () {
    late FakeFirebaseFirestore firestore;
    late MembershipService service;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      service = MembershipService(firestore: firestore);

      await firestore.collection('classes').doc('class-1').set({
        'id': 'class-1',
        'name': 'Clase Piano',
        'ownerTeacherId': 'teacher-1',
        'accessCode': 'ABC234',
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(1),
        'updatedAt': Timestamp.fromMillisecondsSinceEpoch(1),
        'isActive': true,
      });
    });

    test('inviteStudent crea membresía activa con ID determinístico', () async {
      await service.inviteStudent((
        classId: 'class-1',
        studentId: 'student-1',
        teacherId: 'teacher-1',
        className: 'Clase Piano',
      ));

      final membershipId = 'class-1_student-1';
      final snapshot = await firestore
          .collection('memberships')
          .doc(membershipId)
          .get();

      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['id'], membershipId);
      expect(snapshot.data()?['isActive'], true);
      expect(snapshot.data()?['updatedAt'], isA<Timestamp>());
    });

    test('joinClassWithCode crea membresía usando código válido', () async {
      await service.joinClassWithCode((
        studentId: 'student-2',
        accessCode: 'abc234',
      ));

      final membershipId = 'class-1_student-2';
      final snapshot = await firestore
          .collection('memberships')
          .doc(membershipId)
          .get();

      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['teacherId'], 'teacher-1');
      expect(snapshot.data()?['className'], 'Clase Piano');
      expect(snapshot.data()?['updatedAt'], isA<Timestamp>());
    });

    test('removeStudent marca la membresía como inactiva', () async {
      await service.inviteStudent((
        classId: 'class-1',
        studentId: 'student-3',
        teacherId: 'teacher-1',
        className: 'Clase Piano',
      ));

      await service.removeStudent('class-1_student-3');

      final snapshot = await firestore
          .collection('memberships')
          .doc('class-1_student-3')
          .get();
      expect(snapshot.data()?['isActive'], false);
      expect(snapshot.data()?['updatedAt'], isA<Timestamp>());
    });

    test('listClassMembers retorna solo alumnos activos', () async {
      await service.inviteStudent((
        classId: 'class-1',
        studentId: 'student-4',
        teacherId: 'teacher-1',
        className: 'Clase Piano',
      ));
      await service.inviteStudent((
        classId: 'class-1',
        studentId: 'student-5',
        teacherId: 'teacher-1',
        className: 'Clase Piano',
      ));
      await service.removeStudent('class-1_student-4');

      final members = await service.listClassMembers('class-1');

      expect(members.length, 1);
      expect(members.first.studentId, 'student-5');
      expect(members.first.updatedAt, isA<Timestamp>());
    });
  });
}

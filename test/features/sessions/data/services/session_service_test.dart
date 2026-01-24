import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/sessions/data/services/session_service.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SessionService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = SessionService(firestore: fakeFirestore);
  });

  group('SessionService', () {
    group('createSession', () {
      test(
        'crea sesión y actualiza contadores en assignment y student',
        () async {
          // Preparar datos de prueba
          final now = Timestamp.now();
          final startTime = Timestamp.fromDate(
            DateTime.now().subtract(const Duration(minutes: 30)),
          );

          // Crear assignment previo
          await fakeFirestore
              .collection('assignments')
              .doc('task-1_student-1')
              .set({
                'id': 'task-1_student-1',
                'taskId': 'task-1',
                'studentId': 'student-1',
                'classId': 'class-1',
                'teacherId': 'teacher-1',
                'taskTitle': 'Escalas',
                'status': 'pending',
                'assignedAt': now,
                'sessionsCount': 0,
                'totalDurationLogged': 0,
                'isActive': true,
              });

          // Crear student previo
          await fakeFirestore.collection('students').doc('student-1').set({
            'id': 'student-1',
            'firstName': 'Juan',
            'lastName': 'Pérez',
            'email': 'juan@example.com',
            'createdAt': now,
            'updatedAt': now,
            'isActive': true,
            'totalSessionsCount': 0,
            'totalDurationLogged': 0,
          });

          // Crear sesión
          final session = SessionModel(
            id: 'session-1',
            studentId: 'student-1',
            taskId: 'task-1',
            teacherId: 'teacher-1',
            startTime: startTime,
            endTime: now,
            totalDuration: 1800, // 30 minutos
            pausedDuration: 0,
            dateLogged: now,
            monthBucket: '2026-01',
            notes: 'Sesión de práctica',
            status: SessionStatus.completed,
            createdAt: now,
          );

          // Ejecutar
          await service.createSession(session);

          // Verificar que la sesión se creó
          final sessionDoc = await fakeFirestore
              .collection('sessions')
              .doc('session-1')
              .get();
          expect(sessionDoc.exists, isTrue);
          expect(sessionDoc.data()?['totalDuration'], 1800);

          // Verificar que el assignment se actualizó
          final assignmentDoc = await fakeFirestore
              .collection('assignments')
              .doc('task-1_student-1')
              .get();
          expect(assignmentDoc.data()?['sessionsCount'], 1);
          expect(assignmentDoc.data()?['totalDurationLogged'], 1800);
          expect(assignmentDoc.data()?['lastSessionDate'], now);

          // Verificar que el student se actualizó
          final studentDoc = await fakeFirestore
              .collection('students')
              .doc('student-1')
              .get();
          expect(studentDoc.data()?['totalSessionsCount'], 1);
          expect(studentDoc.data()?['totalDurationLogged'], 1800);
          expect(studentDoc.data()?['lastSessionDate'], now);
        },
      );

      test(
        'incrementa correctamente los contadores en múltiples sesiones',
        () async {
          final now = Timestamp.now();
          final startTime = Timestamp.fromDate(
            DateTime.now().subtract(const Duration(minutes: 30)),
          );

          // Preparar assignment y student con valores iniciales
          await fakeFirestore
              .collection('assignments')
              .doc('task-1_student-1')
              .set({
                'id': 'task-1_student-1',
                'taskId': 'task-1',
                'studentId': 'student-1',
                'classId': 'class-1',
                'teacherId': 'teacher-1',
                'status': 'in_progress',
                'assignedAt': now,
                'sessionsCount': 2,
                'totalDurationLogged': 3600,
                'isActive': true,
              });

          await fakeFirestore.collection('students').doc('student-1').set({
            'id': 'student-1',
            'firstName': 'Juan',
            'lastName': 'Pérez',
            'email': 'juan@example.com',
            'createdAt': now,
            'updatedAt': now,
            'isActive': true,
            'totalSessionsCount': 5,
            'totalDurationLogged': 9000,
          });

          // Crear nueva sesión
          final session = SessionModel(
            id: 'session-2',
            studentId: 'student-1',
            taskId: 'task-1',
            teacherId: 'teacher-1',
            startTime: startTime,
            endTime: now,
            totalDuration: 900, // 15 minutos
            dateLogged: now,
            monthBucket: '2026-01',
            status: SessionStatus.completed,
            createdAt: now,
          );

          await service.createSession(session);

          // Verificar incrementos en assignment
          final assignmentDoc = await fakeFirestore
              .collection('assignments')
              .doc('task-1_student-1')
              .get();
          expect(assignmentDoc.data()?['sessionsCount'], 3); // 2 + 1
          expect(
            assignmentDoc.data()?['totalDurationLogged'],
            4500,
          ); // 3600 + 900

          // Verificar incrementos en student
          final studentDoc = await fakeFirestore
              .collection('students')
              .doc('student-1')
              .get();
          expect(studentDoc.data()?['totalSessionsCount'], 6); // 5 + 1
          expect(studentDoc.data()?['totalDurationLogged'], 9900); // 9000 + 900
        },
      );

      test('lanza error si el assignment no existe', () async {
        final now = Timestamp.now();

        // Crear solo el student, pero NO el assignment
        await fakeFirestore.collection('students').doc('student-1').set({
          'id': 'student-1',
          'firstName': 'Juan',
          'lastName': 'Pérez',
          'email': 'juan@example.com',
          'createdAt': now,
          'updatedAt': now,
          'isActive': true,
          'totalSessionsCount': 0,
          'totalDurationLogged': 0,
        });

        final session = SessionModel(
          id: 'session-1',
          studentId: 'student-1',
          taskId: 'task-nonexistent',
          teacherId: 'teacher-1',
          startTime: now,
          endTime: now,
          totalDuration: 1800,
          dateLogged: now,
          monthBucket: '2026-01',
          status: SessionStatus.completed,
          createdAt: now,
        );

        expect(
          () => service.createSession(session),
          throwsA(isA<FirebaseErrorMapperException>()),
        );
      });

      test('lanza error si el student no existe', () async {
        final now = Timestamp.now();

        // Crear solo el assignment, pero NO el student
        await fakeFirestore
            .collection('assignments')
            .doc('task-1_student-1')
            .set({
              'id': 'task-1_student-1',
              'taskId': 'task-1',
              'studentId': 'student-1',
              'classId': 'class-1',
              'teacherId': 'teacher-1',
              'status': 'pending',
              'assignedAt': now,
              'sessionsCount': 0,
              'totalDurationLogged': 0,
              'isActive': true,
            });

        final session = SessionModel(
          id: 'session-1',
          studentId: 'student-1',
          taskId: 'task-1',
          teacherId: 'teacher-1',
          startTime: now,
          endTime: now,
          totalDuration: 1800,
          dateLogged: now,
          monthBucket: '2026-01',
          status: SessionStatus.completed,
          createdAt: now,
        );

        expect(
          () => service.createSession(session),
          throwsA(isA<FirebaseErrorMapperException>()),
        );
      });

      test('lanza ArgumentError si el ID de la sesión está vacío', () {
        final now = Timestamp.now();
        final session = SessionModel(
          id: '', // ID vacío
          studentId: 'student-1',
          taskId: 'task-1',
          teacherId: 'teacher-1',
          startTime: now,
          endTime: now,
          totalDuration: 1800,
          dateLogged: now,
          monthBucket: '2026-01',
          status: SessionStatus.completed,
          createdAt: now,
        );

        expect(
          () => service.createSession(session),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('lanza ArgumentError si el studentId está vacío', () {
        final now = Timestamp.now();
        final session = SessionModel(
          id: 'session-1',
          studentId: '', // StudentId vacío
          taskId: 'task-1',
          teacherId: 'teacher-1',
          startTime: now,
          endTime: now,
          totalDuration: 1800,
          dateLogged: now,
          monthBucket: '2026-01',
          status: SessionStatus.completed,
          createdAt: now,
        );

        expect(
          () => service.createSession(session),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('lanza ArgumentError si la duración es negativa', () {
        final now = Timestamp.now();
        final session = SessionModel(
          id: 'session-1',
          studentId: 'student-1',
          taskId: 'task-1',
          teacherId: 'teacher-1',
          startTime: now,
          endTime: now,
          totalDuration: -100, // Duración negativa
          dateLogged: now,
          monthBucket: '2026-01',
          status: SessionStatus.completed,
          createdAt: now,
        );

        expect(
          () => service.createSession(session),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('getSessionById', () {
      test('devuelve SessionModel cuando la sesión existe', () async {
        final now = Timestamp.now();
        await fakeFirestore.collection('sessions').doc('session-1').set({
          'id': 'session-1',
          'studentId': 'student-1',
          'taskId': 'task-1',
          'teacherId': 'teacher-1',
          'startTime': now,
          'endTime': now,
          'totalDuration': 1800,
          'pausedDuration': 0,
          'dateLogged': now,
          'monthBucket': '2026-01',
          'status': 'completed',
          'createdAt': now,
        });

        final session = await service.getSessionById('session-1');

        expect(session, isNotNull);
        expect(session!.id, 'session-1');
        expect(session.totalDuration, 1800);
      });

      test('devuelve null cuando la sesión no existe', () async {
        final session = await service.getSessionById('nonexistent');
        expect(session, isNull);
      });

      test('lanza ArgumentError si el ID está vacío', () {
        expect(() => service.getSessionById(''), throwsA(isA<ArgumentError>()));
      });
    });

    group('watchStudentSessions', () {
      test(
        'devuelve todas las sesiones del estudiante ordenadas por fecha',
        () async {
          final now = Timestamp.now();
          final earlier = Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1)),
          );

          await fakeFirestore.collection('sessions').doc('session-1').set({
            'id': 'session-1',
            'studentId': 'student-1',
            'taskId': 'task-1',
            'teacherId': 'teacher-1',
            'startTime': now,
            'endTime': now,
            'totalDuration': 1800,
            'dateLogged': now,
            'monthBucket': '2026-01',
            'status': 'completed',
            'createdAt': now,
          });

          await fakeFirestore.collection('sessions').doc('session-2').set({
            'id': 'session-2',
            'studentId': 'student-1',
            'taskId': 'task-2',
            'teacherId': 'teacher-1',
            'startTime': earlier,
            'endTime': earlier,
            'totalDuration': 900,
            'dateLogged': earlier,
            'monthBucket': '2026-01',
            'status': 'completed',
            'createdAt': earlier,
          });

          // Sesión de otro estudiante (no debería aparecer)
          await fakeFirestore.collection('sessions').doc('session-3').set({
            'id': 'session-3',
            'studentId': 'student-2',
            'taskId': 'task-1',
            'teacherId': 'teacher-1',
            'startTime': now,
            'endTime': now,
            'totalDuration': 600,
            'dateLogged': now,
            'monthBucket': '2026-01',
            'status': 'completed',
            'createdAt': now,
          });

          final stream = service.watchStudentSessions(studentId: 'student-1');

          await expectLater(
            stream,
            emits(
              predicate<List<SessionModel>>(
                (sessions) =>
                    sessions.length == 2 &&
                    sessions[0].id == 'session-1' && // Más reciente primero
                    sessions[1].id == 'session-2',
              ),
            ),
          );
        },
      );

      test('respeta el límite de resultados', () async {
        final now = Timestamp.now();

        for (int i = 1; i <= 5; i++) {
          await fakeFirestore.collection('sessions').doc('session-$i').set({
            'id': 'session-$i',
            'studentId': 'student-1',
            'taskId': 'task-1',
            'teacherId': 'teacher-1',
            'startTime': now,
            'endTime': now,
            'totalDuration': 1800,
            'dateLogged': now,
            'monthBucket': '2026-01',
            'status': 'completed',
            'createdAt': now,
          });
        }

        final stream = service.watchStudentSessions(
          studentId: 'student-1',
          limit: 3,
        );

        await expectLater(
          stream,
          emits(
            predicate<List<SessionModel>>((sessions) => sessions.length == 3),
          ),
        );
      });
    });

    group('watchTaskSessions', () {
      test('devuelve sesiones filtradas por tarea y estudiante', () async {
        final now = Timestamp.now();

        await fakeFirestore.collection('sessions').doc('session-1').set({
          'id': 'session-1',
          'studentId': 'student-1',
          'taskId': 'task-1',
          'teacherId': 'teacher-1',
          'startTime': now,
          'endTime': now,
          'totalDuration': 1800,
          'dateLogged': now,
          'monthBucket': '2026-01',
          'status': 'completed',
          'createdAt': now,
        });

        await fakeFirestore.collection('sessions').doc('session-2').set({
          'id': 'session-2',
          'studentId': 'student-1',
          'taskId': 'task-2', // Tarea diferente
          'teacherId': 'teacher-1',
          'startTime': now,
          'endTime': now,
          'totalDuration': 900,
          'dateLogged': now,
          'monthBucket': '2026-01',
          'status': 'completed',
          'createdAt': now,
        });

        final stream = service.watchTaskSessions(
          taskId: 'task-1',
          studentId: 'student-1',
        );

        await expectLater(
          stream,
          emits(
            predicate<List<SessionModel>>(
              (sessions) =>
                  sessions.length == 1 && sessions[0].id == 'session-1',
            ),
          ),
        );
      });
    });
  });
}

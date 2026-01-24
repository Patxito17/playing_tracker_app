import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:playing_tracker/features/sessions/data/services/session_service.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';

class _MockSessionService extends Mock implements SessionServiceContract {}

void main() {
  late _MockSessionService mockService;
  late SessionRepositoryImpl repository;

  setUpAll(() {
    final now = Timestamp.now();
    registerFallbackValue(
      SessionModel(
        id: 'test',
        studentId: 'test',
        taskId: 'test',
        teacherId: 'test',
        startTime: now,
        endTime: now,
        totalDuration: 0,
        dateLogged: now,
        monthBucket: '2026-01',
        createdAt: now,
      ),
    );
  });

  setUp(() {
    mockService = _MockSessionService();
    repository = SessionRepositoryImpl(sessionService: mockService);
  });

  group('SessionRepository', () {
    final now = Timestamp.now();
    final testSession = SessionModel(
      id: 'session-1',
      studentId: 'student-1',
      taskId: 'task-1',
      teacherId: 'teacher-1',
      startTime: now,
      endTime: now,
      totalDuration: 1800,
      pausedDuration: 0,
      dateLogged: now,
      monthBucket: '2026-01',
      notes: 'Sesión de prueba',
      status: SessionStatus.completed,
      createdAt: now,
    );

    group('createSession', () {
      test('crea sesión exitosamente cuando el servicio responde OK', () async {
        when(
          () => mockService.createSession(any()),
        ).thenAnswer((_) async => Future.value());

        await repository.createSession(testSession);

        verify(() => mockService.createSession(testSession)).called(1);
      });

      test('lanza InvalidSessionArgumentException cuando el ID está vacío', () {
        final invalidSession = testSession.copyWith(id: '');

        expect(
          () => repository.createSession(invalidSession),
          throwsA(isA<InvalidSessionArgumentException>()),
        );
      });

      test('lanza SessionCreationException cuando el assignment no existe', () {
        when(() => mockService.createSession(any())).thenThrow(
          FirebaseErrorMapperException(
            'La asignación task-1_student-1 no existe.',
          ),
        );

        expect(
          () => repository.createSession(testSession),
          throwsA(isA<SessionCreationException>()),
        );
      });

      test(
        'lanza UnknownSessionRepositoryException cuando ocurre error Firebase',
        () {
          when(() => mockService.createSession(any())).thenThrow(
            FirebaseException(
              plugin: 'cloud_firestore',
              code: 'permission-denied',
            ),
          );

          expect(
            () => repository.createSession(testSession),
            throwsA(isA<UnknownSessionRepositoryException>()),
          );
        },
      );
    });

    group('getSessionById', () {
      test('devuelve SessionModel cuando la sesión existe', () async {
        when(
          () => mockService.getSessionById('session-1'),
        ).thenAnswer((_) async => testSession);

        final result = await repository.getSessionById('session-1');

        expect(result, testSession);
      });

      test('devuelve null cuando la sesión no existe', () async {
        when(
          () => mockService.getSessionById('nonexistent'),
        ).thenAnswer((_) async => null);

        final result = await repository.getSessionById('nonexistent');

        expect(result, isNull);
      });

      test('lanza InvalidSessionArgumentException cuando el ID está vacío', () {
        expect(
          () => repository.getSessionById(''),
          throwsA(isA<InvalidSessionArgumentException>()),
        );
      });
    });

    group('watchStudentSessions', () {
      test('devuelve stream de sesiones del estudiante', () async {
        final sessions = [testSession];
        when(
          () => mockService.watchStudentSessions(
            studentId: any(named: 'studentId'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) => Stream.value(sessions));

        final stream = repository.watchStudentSessions(studentId: 'student-1');

        await expectLater(stream, emits(sessions));
      });

      test(
        'devuelve stream con error cuando el studentId está vacío',
        () async {
          final stream = repository.watchStudentSessions(studentId: '');

          await expectLater(
            stream,
            emitsError(isA<InvalidSessionArgumentException>()),
          );
        },
      );
    });

    group('watchTaskSessions', () {
      test(
        'devuelve stream de sesiones filtradas por tarea y estudiante',
        () async {
          final sessions = [testSession];
          when(
            () => mockService.watchTaskSessions(
              taskId: any(named: 'taskId'),
              studentId: any(named: 'studentId'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) => Stream.value(sessions));

          final stream = repository.watchTaskSessions(
            taskId: 'task-1',
            studentId: 'student-1',
          );

          await expectLater(stream, emits(sessions));
        },
      );

      test('devuelve stream con error cuando el taskId está vacío', () async {
        final stream = repository.watchTaskSessions(
          taskId: '',
          studentId: 'student-1',
        );

        await expectLater(
          stream,
          emitsError(isA<InvalidSessionArgumentException>()),
        );
      });
    });

    group('Exception hierarchy', () {
      test('SessionNotFoundException es una SessionRepositoryException', () {
        const exception = SessionNotFoundException('Not found');
        expect(exception, isA<SessionRepositoryException>());
      });

      test('SessionCreationException es una SessionRepositoryException', () {
        const exception = SessionCreationException('Creation failed');
        expect(exception, isA<SessionRepositoryException>());
      });

      test(
        'UnknownSessionRepositoryException es una SessionRepositoryException',
        () {
          const exception = UnknownSessionRepositoryException('Unknown error');
          expect(exception, isA<SessionRepositoryException>());
        },
      );

      test(
        'InvalidSessionArgumentException es una SessionRepositoryException',
        () {
          const exception = InvalidSessionArgumentException('Invalid argument');
          expect(exception, isA<SessionRepositoryException>());
        },
      );

      test('SessionRepositoryException tiene mensaje y causa', () {
        final cause = Exception('Root cause');
        final exception = UnknownSessionRepositoryException(
          'Error message',
          cause: cause,
        );

        expect(exception.message, 'Error message');
        expect(exception.cause, cause);
        expect(exception.toString(), contains('Error message'));
      });
    });
  });
}

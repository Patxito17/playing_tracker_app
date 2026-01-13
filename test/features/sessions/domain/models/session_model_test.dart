import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';

void main() {
  group('SessionModel', () {
    // Datos de prueba base
    final testTimestamp = Timestamp.fromDate(DateTime(2026, 1, 15, 10, 30));
    final testStartTime = Timestamp.fromDate(DateTime(2026, 1, 15, 10, 0));
    final testEndTime = Timestamp.fromDate(DateTime(2026, 1, 15, 10, 45));
    final testDateLogged = Timestamp.fromDate(DateTime(2026, 1, 15));

    final baseSession = SessionModel(
      id: 'session_123',
      studentId: 'student_456',
      taskId: 'task_789',
      teacherId: 'teacher_012',
      startTime: testStartTime,
      endTime: testEndTime,
      totalDuration: 2700, // 45 minutos
      pausedDuration: 300, // 5 minutos
      dateLogged: testDateLogged,
      monthBucket: '2026-01',
      notes: 'Sesión de práctica de escalas',
      status: SessionStatus.completed,
      createdAt: testTimestamp,
    );

    group('Constructor y Campos', () {
      test('crea una sesión con todos los campos requeridos', () {
        expect(baseSession.id, 'session_123');
        expect(baseSession.studentId, 'student_456');
        expect(baseSession.taskId, 'task_789');
        expect(baseSession.teacherId, 'teacher_012');
        expect(baseSession.startTime, testStartTime);
        expect(baseSession.endTime, testEndTime);
        expect(baseSession.totalDuration, 2700);
        expect(baseSession.pausedDuration, 300);
        expect(baseSession.dateLogged, testDateLogged);
        expect(baseSession.monthBucket, '2026-01');
        expect(baseSession.notes, 'Sesión de práctica de escalas');
        expect(baseSession.status, SessionStatus.completed);
        expect(baseSession.createdAt, testTimestamp);
      });

      test('usa valores por defecto correctos', () {
        final sessionWithDefaults = SessionModel(
          id: 'session_123',
          studentId: 'student_456',
          taskId: 'task_789',
          teacherId: 'teacher_012',
          startTime: testStartTime,
          endTime: testEndTime,
          totalDuration: 2700,
          dateLogged: testDateLogged,
          monthBucket: '2026-01',
          createdAt: testTimestamp,
        );

        expect(sessionWithDefaults.pausedDuration, 0);
        expect(sessionWithDefaults.notes, isNull);
        expect(sessionWithDefaults.status, SessionStatus.completed);
      });
    });

    group('Serialización JSON', () {
      test('toJson convierte correctamente el modelo a Map', () {
        final json = baseSession.toJson();

        expect(json['id'], 'session_123');
        expect(json['studentId'], 'student_456');
        expect(json['taskId'], 'task_789');
        expect(json['teacherId'], 'teacher_012');
        expect(json['startTime'], testStartTime);
        expect(json['endTime'], testEndTime);
        expect(json['totalDuration'], 2700);
        expect(json['pausedDuration'], 300);
        expect(json['dateLogged'], testDateLogged);
        expect(json['monthBucket'], '2026-01');
        expect(json['notes'], 'Sesión de práctica de escalas');
        expect(json['status'], 'completed');
        expect(json['createdAt'], testTimestamp);
      });

      test('fromJson crea correctamente el modelo desde Map', () {
        final json = {
          'id': 'session_123',
          'studentId': 'student_456',
          'taskId': 'task_789',
          'teacherId': 'teacher_012',
          'startTime': testStartTime,
          'endTime': testEndTime,
          'totalDuration': 2700,
          'pausedDuration': 300,
          'dateLogged': testDateLogged,
          'monthBucket': '2026-01',
          'notes': 'Sesión de práctica de escalas',
          'status': 'completed',
          'createdAt': testTimestamp,
        };

        final session = SessionModel.fromJson(json);

        expect(session.id, 'session_123');
        expect(session.studentId, 'student_456');
        expect(session.taskId, 'task_789');
        expect(session.teacherId, 'teacher_012');
        expect(session.startTime, testStartTime);
        expect(session.endTime, testEndTime);
        expect(session.totalDuration, 2700);
        expect(session.pausedDuration, 300);
        expect(session.dateLogged, testDateLogged);
        expect(session.monthBucket, '2026-01');
        expect(session.notes, 'Sesión de práctica de escalas');
        expect(session.status, SessionStatus.completed);
        expect(session.createdAt, testTimestamp);
      });

      test('serialización y deserialización mantienen los datos', () {
        final json = baseSession.toJson();
        final sessionFromJson = SessionModel.fromJson(json);

        expect(sessionFromJson, equals(baseSession));
      });

      test('fromJson maneja correctamente valores por defecto', () {
        final json = {
          'id': 'session_123',
          'studentId': 'student_456',
          'taskId': 'task_789',
          'teacherId': 'teacher_012',
          'startTime': testStartTime,
          'endTime': testEndTime,
          'totalDuration': 2700,
          'dateLogged': testDateLogged,
          'monthBucket': '2026-01',
          'createdAt': testTimestamp,
        };

        final session = SessionModel.fromJson(json);

        expect(session.pausedDuration, 0);
        expect(session.notes, isNull);
        expect(session.status, SessionStatus.completed);
      });

      test('fromJson maneja todos los estados de SessionStatus', () {
        final statuses = [
          SessionStatus.idle,
          SessionStatus.running,
          SessionStatus.paused,
          SessionStatus.completed,
        ];

        for (final status in statuses) {
          final json = baseSession.toJson();
          json['status'] = status.name;
          final session = SessionModel.fromJson(json);
          expect(session.status, status);
        }
      });
    });

    group('copyWith', () {
      test('crea una copia con los campos especificados modificados', () {
        final newTimestamp = Timestamp.fromDate(DateTime(2026, 1, 16, 10, 0));
        final updated = baseSession.copyWith(
          id: 'new_id',
          totalDuration: 3600,
          notes: 'Notas actualizadas',
          status: SessionStatus.running,
          createdAt: newTimestamp,
        );

        expect(updated.id, 'new_id');
        expect(updated.totalDuration, 3600);
        expect(updated.notes, 'Notas actualizadas');
        expect(updated.status, SessionStatus.running);
        expect(updated.createdAt, newTimestamp);

        // Verifica que los campos no modificados se mantienen
        expect(updated.studentId, baseSession.studentId);
        expect(updated.taskId, baseSession.taskId);
        expect(updated.teacherId, baseSession.teacherId);
      });

      test('sin parámetros devuelve una copia idéntica', () {
        final copy = baseSession.copyWith();
        expect(copy, equals(baseSession));
      });
    });

    group('durationFormatted', () {
      test('formatea correctamente duraciones con horas', () {
        final session = baseSession.copyWith(totalDuration: 7380); // 2h 3min
        expect(session.durationFormatted, '2 h 3 min');
      });

      test('formatea correctamente duraciones solo con horas exactas', () {
        final session = baseSession.copyWith(totalDuration: 7200); // 2h
        expect(session.durationFormatted, '2 h ');
      });

      test('formatea correctamente duraciones con minutos y segundos', () {
        final session = baseSession.copyWith(totalDuration: 185); // 3min 5s
        expect(session.durationFormatted, '3 min 5 s');
      });

      test('formatea correctamente duraciones solo con minutos', () {
        final session = baseSession.copyWith(totalDuration: 180); // 3min
        expect(session.durationFormatted, '3 min ');
      });

      test('formatea correctamente duraciones solo con segundos', () {
        final session = baseSession.copyWith(totalDuration: 45); // 45s
        expect(session.durationFormatted, '45 s');
      });

      test('formatea correctamente duración de 0 segundos', () {
        final session = baseSession.copyWith(totalDuration: 0);
        expect(session.durationFormatted, '0 s');
      });
    });

    group('pausedDurationFormatted', () {
      test('formatea correctamente pausas con minutos y segundos', () {
        final session = baseSession.copyWith(pausedDuration: 185); // 3min 5s
        expect(session.pausedDurationFormatted, '3 min 5 s');
      });

      test('formatea correctamente pausas solo con minutos', () {
        final session = baseSession.copyWith(pausedDuration: 180); // 3min
        expect(session.pausedDurationFormatted, '3 min ');
      });

      test('formatea correctamente pausas solo con segundos', () {
        final session = baseSession.copyWith(pausedDuration: 45); // 45s
        expect(session.pausedDurationFormatted, '45 s');
      });

      test('formatea correctamente pausa de 0 segundos', () {
        final session = baseSession.copyWith(pausedDuration: 0);
        expect(session.pausedDurationFormatted, '0 s');
      });
    });

    group('generateMonthBucket', () {
      test('genera correctamente monthBucket para enero', () {
        final timestamp = Timestamp.fromDate(DateTime(2026, 1, 15));
        expect(SessionModel.generateMonthBucket(timestamp), '2026-01');
      });

      test('genera correctamente monthBucket para diciembre', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 31));
        expect(SessionModel.generateMonthBucket(timestamp), '2025-12');
      });

      test('genera correctamente monthBucket con padding de cero', () {
        final timestamp = Timestamp.fromDate(DateTime(2026, 3, 5));
        expect(SessionModel.generateMonthBucket(timestamp), '2026-03');
      });
    });

    group('Operadores de igualdad', () {
      test('dos sesiones con los mismos datos son iguales', () {
        final session1 = baseSession;
        final session2 = SessionModel(
          id: 'session_123',
          studentId: 'student_456',
          taskId: 'task_789',
          teacherId: 'teacher_012',
          startTime: testStartTime,
          endTime: testEndTime,
          totalDuration: 2700,
          pausedDuration: 300,
          dateLogged: testDateLogged,
          monthBucket: '2026-01',
          notes: 'Sesión de práctica de escalas',
          status: SessionStatus.completed,
          createdAt: testTimestamp,
        );

        expect(session1, equals(session2));
        expect(session1.hashCode, equals(session2.hashCode));
      });

      test('dos sesiones con diferentes IDs no son iguales', () {
        final session1 = baseSession;
        final session2 = baseSession.copyWith(id: 'different_id');

        expect(session1, isNot(equals(session2)));
      });

      test('dos sesiones con diferentes estados no son iguales', () {
        final session1 = baseSession;
        final session2 = baseSession.copyWith(status: SessionStatus.running);

        expect(session1, isNot(equals(session2)));
      });
    });

    group('toString', () {
      test('devuelve una representación string legible', () {
        final str = baseSession.toString();
        expect(str, contains('session_123'));
        expect(str, contains('task_789'));
        expect(str, contains('2026-01'));
      });
    });

    group('SessionStatus enum', () {
      test('todos los valores del enum están definidos', () {
        expect(SessionStatus.values, hasLength(4));
        expect(SessionStatus.values, contains(SessionStatus.idle));
        expect(SessionStatus.values, contains(SessionStatus.running));
        expect(SessionStatus.values, contains(SessionStatus.paused));
        expect(SessionStatus.values, contains(SessionStatus.completed));
      });

      test('los nombres del enum son correctos', () {
        expect(SessionStatus.idle.name, 'idle');
        expect(SessionStatus.running.name, 'running');
        expect(SessionStatus.paused.name, 'paused');
        expect(SessionStatus.completed.name, 'completed');
      });
    });
  });
}

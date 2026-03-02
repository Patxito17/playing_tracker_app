import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/statistics/data/services/statistics_service.dart';
import 'package:playing_tracker/features/statistics/domain/models/daily_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';

// Helpers internos del test
Timestamp _ts(DateTime d) => Timestamp.fromDate(d);

/// Helper: crea una sesión mínima en Firestore falso.
Future<void> _addSession(
  FakeFirebaseFirestore fakeFirestore, {
  required String id,
  required String studentId,
  required String taskId,
  required String teacherId,
  String classId = 'class-1',
  required DateTime dateLogged,
  required int totalDuration,
  String? taskTitle,
}) async {
  final ts = _ts(dateLogged);
  await fakeFirestore.collection('sessions').doc(id).set({
    'id': id,
    'studentId': studentId,
    'taskId': taskId,
    'teacherId': teacherId,
    'classId': classId,
    'startTime': ts,
    'endTime': ts,
    'totalDuration': totalDuration,
    'pausedDuration': 0,
    'dateLogged': ts,
    'monthBucket':
        '${dateLogged.year}-${dateLogged.month.toString().padLeft(2, '0')}',
    'createdAt': ts,
    'taskTitle': ?taskTitle,
  });
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late StatisticsService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = StatisticsService(firestore: fakeFirestore);
  });

  // ---------------------------------------------------------------------------
  // getDailyStats
  // ---------------------------------------------------------------------------
  group('StatisticsService.getDailyStats', () {
    test('devuelve métricas del día correctas con varias sesiones', () async {
      final day = DateTime(2026, 2, 10);

      await _addSession(
        fakeFirestore,
        id: 's1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: day,
        totalDuration: 1800,
      );
      await _addSession(
        fakeFirestore,
        id: 's2',
        studentId: 'student-1',
        taskId: 'task-2', // tarea diferente
        teacherId: 'teacher-1',
        dateLogged: day,
        totalDuration: 900,
      );

      final result = await service.getDailyStats(
        studentId: 'student-1',
        date: day,
      );

      expect(result, isA<DailyStatsModel>());
      expect(result.totalDuration, 2700); // 1800 + 900
      expect(result.totalSessions, 2);
      expect(result.uniqueTasks, 2);
    });

    test('devuelve métricas vacías si no hay sesiones en el día', () async {
      final result = await service.getDailyStats(
        studentId: 'student-1',
        date: DateTime(2026, 1, 1),
      );

      expect(result.totalDuration, 0);
      expect(result.totalSessions, 0);
      expect(result.uniqueTasks, 0);
    });

    test('no incluye sesiones de otros días', () async {
      final targetDay = DateTime(2026, 2, 10);
      final otherDay = DateTime(2026, 2, 9);

      await _addSession(
        fakeFirestore,
        id: 's1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: targetDay,
        totalDuration: 600,
      );
      await _addSession(
        fakeFirestore,
        id: 's2',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: otherDay,
        totalDuration: 9999,
      );

      final result = await service.getDailyStats(
        studentId: 'student-1',
        date: targetDay,
      );

      expect(result.totalSessions, 1);
      expect(result.totalDuration, 600);
    });

    test('no incluye sesiones de otros estudiantes', () async {
      final day = DateTime(2026, 2, 10);

      await _addSession(
        fakeFirestore,
        id: 's1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: day,
        totalDuration: 600,
      );
      await _addSession(
        fakeFirestore,
        id: 's2',
        studentId: 'student-2', // otro estudiante
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: day,
        totalDuration: 9999,
      );

      final result = await service.getDailyStats(
        studentId: 'student-1',
        date: day,
      );

      expect(result.totalSessions, 1);
      expect(result.totalDuration, 600);
    });

    test('lanza ArgumentError si studentId está vacío', () {
      expect(
        () =>
            service.getDailyStats(studentId: '  ', date: DateTime(2026, 1, 1)),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getMonthlyStats
  // ---------------------------------------------------------------------------
  group('StatisticsService.getMonthlyStats', () {
    test('agrega correctamente sesiones del mes por monthBucket', () async {
      final jan = DateTime(2026, 1, 15);
      final feb = DateTime(2026, 2, 5); // mes diferente

      await _addSession(
        fakeFirestore,
        id: 'ms1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: jan,
        totalDuration: 1800,
      );
      await _addSession(
        fakeFirestore,
        id: 'ms2',
        studentId: 'student-1',
        taskId: 'task-2',
        teacherId: 'teacher-1',
        dateLogged: jan,
        totalDuration: 3600,
      );
      await _addSession(
        fakeFirestore,
        id: 'ms3',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: feb,
        totalDuration: 9999, // no debe contarse
      );

      final result = await service.getMonthlyStats(
        studentId: 'student-1',
        month: 1,
        year: 2026,
      );

      expect(result.totalSessions, 2);
      expect(result.totalDuration, 5400); // 1800 + 3600
      expect(result.uniqueTasks, 2);
    });

    test('lanza ArgumentError si mes está fuera de rango', () {
      expect(
        () => service.getMonthlyStats(studentId: 's', month: 13, year: 2026),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => service.getMonthlyStats(studentId: 's', month: 0, year: 2026),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('lanza ArgumentError si studentId está vacío', () {
      expect(
        () => service.getMonthlyStats(studentId: '', month: 1, year: 2026),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('devuelve métricas vacías si no hay sesiones en el mes', () async {
      final result = await service.getMonthlyStats(
        studentId: 'student-noop',
        month: 6,
        year: 2025,
      );

      expect(result.totalDuration, 0);
      expect(result.totalSessions, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // getWeeklyStats
  // ---------------------------------------------------------------------------
  group('StatisticsService.getWeeklyStats', () {
    test('genera desglose diario de 7 días correctamente', () async {
      final now = DateTime.now();
      final monday = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: now.weekday - 1),
      ); // Lunes de ESTA semana en curso

      // Sesiones el lunes y el miércoles
      await _addSession(
        fakeFirestore,
        id: 'ws1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: monday,
        totalDuration: 1800,
      );
      await _addSession(
        fakeFirestore,
        id: 'ws2',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: monday.add(const Duration(days: 2)), // miercoles
        totalDuration: 900,
      );

      final result = await service.getWeeklyStats(
        studentId: 'student-1',
        weekStart: monday,
      );

      expect(result, isA<WeeklyStatsModel>());
      expect(result.dailyBreakdown.length, 7);
      expect(result.totalSessions, 2);
      expect(result.totalDuration, 2700);

      // Lunes debe tener 1800 seg
      expect(result.dailyBreakdown[0].totalDuration, 1800);
      // Miércoles (día 2 de la semana) debe tener 900 seg
      expect(result.dailyBreakdown[2].totalDuration, 900);
      // Resto de días deben estar a 0
      expect(result.dailyBreakdown[1].totalDuration, 0);
      expect(result.dailyBreakdown[3].totalDuration, 0);
    });

    test('genera desglose por tareas correctamente', () async {
      final now = DateTime.now();
      final monday = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));

      await _addSession(
        fakeFirestore,
        id: 'wt1',
        studentId: 'student-1',
        taskId: 'task-A',
        teacherId: 'teacher-1',
        dateLogged: monday,
        totalDuration: 600,
        taskTitle: 'Escalas',
      );
      await _addSession(
        fakeFirestore,
        id: 'wt2',
        studentId: 'student-1',
        taskId: 'task-A',
        teacherId: 'teacher-1',
        dateLogged: monday,
        totalDuration: 400,
        taskTitle: 'Escalas',
      );
      await _addSession(
        fakeFirestore,
        id: 'wt3',
        studentId: 'student-1',
        taskId: 'task-B',
        teacherId: 'teacher-1',
        dateLogged: monday,
        totalDuration: 300,
        taskTitle: 'Arpegios',
      );

      final result = await service.getWeeklyStats(
        studentId: 'student-1',
        weekStart: monday,
      );

      expect(result.taskBreakdown.length, 2);
      final taskA = result.taskBreakdown.firstWhere(
        (t) => t.taskId == 'task-A',
      );
      expect(taskA.totalDuration, 1000); // 600 + 400
      expect(taskA.totalSessions, 2);
    });

    test('lanza ArgumentError si studentId está vacío', () {
      expect(
        () => service.getWeeklyStats(
          studentId: '',
          weekStart: DateTime(2026, 2, 9),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getTaskStats
  // ---------------------------------------------------------------------------
  group('StatisticsService.getTaskStats', () {
    test('calcula métricas de tarea para un estudiante específico', () async {
      final now = DateTime(2026, 2, 10);

      // Crear tarea en firestore
      await fakeFirestore.collection('tasks').doc('task-1').set({
        'id': 'task-1',
        'title': 'Escalas mayores',
        'durationSuggested': 30, // minutos
      });

      // Crear assignment
      await fakeFirestore
          .collection('assignments')
          .doc('task-1_student-1')
          .set({
            'id': 'task-1_student-1',
            'taskId': 'task-1',
            'studentId': 'student-1',
            'status': 'in_progress',
          });

      // Añadir sesiones de la tarea
      await _addSession(
        fakeFirestore,
        id: 'ts1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: now,
        totalDuration: 1200,
      );
      await _addSession(
        fakeFirestore,
        id: 'ts2',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: now,
        totalDuration: 800,
      );

      final result = await service.getTaskStats(
        taskId: 'task-1',
        studentId: 'student-1',
      );

      expect(result, isA<TaskStatsModel>());
      expect(result.taskTitle, 'Escalas mayores');
      expect(result.totalSessions, 2);
      expect(result.totalDuration, 2000); // 1200 + 800
      expect(result.suggestedDuration, 1800); // 30 min * 60 = 1800 seg
      expect(result.isCompleted, isFalse);
    });

    test(
      'marca la tarea como completada si el assignment está completado',
      () async {
        await fakeFirestore.collection('tasks').doc('task-done').set({
          'id': 'task-done',
          'title': 'Tarea completada',
        });
        await fakeFirestore
            .collection('assignments')
            .doc('task-done_student-1')
            .set({
              'id': 'task-done_student-1',
              'taskId': 'task-done',
              'studentId': 'student-1',
              'status': 'completed',
            });

        final result = await service.getTaskStats(
          taskId: 'task-done',
          studentId: 'student-1',
        );

        expect(result.isCompleted, isTrue);
      },
    );

    test('devuelve título "Tarea desconocida" si la tarea no existe', () async {
      final result = await service.getTaskStats(taskId: 'nonexistent');

      expect(result.taskTitle, 'Tarea desconocida');
      expect(result.totalSessions, 0);
    });

    test('lanza ArgumentError si taskId está vacío', () {
      expect(
        () => service.getTaskStats(taskId: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getClassStats
  // ---------------------------------------------------------------------------
  group('StatisticsService.getClassStats', () {
    test('calcula métricas de clase con alumnos y sesiones', () async {
      // Crear la clase
      await fakeFirestore.collection('classes').doc('class-1').set({
        'id': 'class-1',
        'name': 'Guitarra Avanzada',
        'ownerTeacherId': 'teacher-1',
      });

      // Añadir membresías activas
      await fakeFirestore.collection('memberships').doc('m1').set({
        'classId': 'class-1',
        'studentId': 'student-1',
        'isActive': true,
      });
      await fakeFirestore.collection('memberships').doc('m2').set({
        'classId': 'class-1',
        'studentId': 'student-2',
        'isActive': true,
      });

      // Sesiones de la clase
      await _addSession(
        fakeFirestore,
        id: 'cs1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        classId: 'class-1',
        dateLogged: DateTime.now(),
        totalDuration: 1800,
        taskTitle: 'Escalas',
      );
      await _addSession(
        fakeFirestore,
        id: 'cs2',
        studentId: 'student-2',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        classId: 'class-1',
        dateLogged: DateTime.now(),
        totalDuration: 900,
        taskTitle: 'Escalas',
      );

      final result = await service.getClassStats(
        classId: 'class-1',
        teacherId: 'teacher-1',
      );

      expect(result, isA<ClassStatsModel>());
      expect(result.className, 'Guitarra Avanzada');
      expect(result.totalStudents, 2);
      expect(result.totalSessions, 2);
      expect(result.totalDuration, 2700); // 1800 + 900
      expect(result.taskBreakdown.length, 1);
      expect(result.taskBreakdown.first.taskTitle, 'Escalas');
      expect(result.taskBreakdown.first.totalDuration, 2700);
    });

    test(
      'devuelve ClassStatsModel vacío si no hay membresías activas',
      () async {
        await fakeFirestore.collection('classes').doc('class-empty').set({
          'id': 'class-empty',
          'name': 'Clase vacía',
          'ownerTeacherId': 'teacher-1',
        });

        final result = await service.getClassStats(
          classId: 'class-empty',
          teacherId: 'teacher-1',
        );

        expect(result.totalStudents, 0);
        expect(result.totalSessions, 0);
        expect(result.totalDuration, 0);
      },
    );

    test('lanza excepción apropiada si la clase consultada falla', () async {
      expect(
        () => service.getClassStats(
          classId: 'nonexistent',
          teacherId: 'teacher-1',
        ),
        throwsA(isA<FirebaseErrorMapperException>()),
      );
    });

    test('lanza ArgumentError si classId está vacío', () {
      expect(
        () => service.getClassStats(classId: '', teacherId: 'teacher-1'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('lanza ArgumentError si teacherId está vacío', () {
      expect(
        () => service.getClassStats(classId: 'class-1', teacherId: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

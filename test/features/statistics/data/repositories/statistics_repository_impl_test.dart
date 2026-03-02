// ignore_for_file: avoid_function_literals_in_foreach_calls
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:playing_tracker/features/statistics/data/services/statistics_service.dart';
import 'package:playing_tracker/features/statistics/domain/exceptions/statistics_exception.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/daily_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';

// ---------------------------------------------------------------------------
// Helper: crea una sesión mínima en Firestore falso.
// ---------------------------------------------------------------------------
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
  final ts = Timestamp.fromDate(dateLogged);
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
    'status': 'completed',
    'createdAt': ts,
    if (taskTitle != null) 'taskTitle': taskTitle,
  });
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late StatisticsRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    // Pasamos el Firestore falso tanto al servicio como al repositorio
    // (el repositorio usa _firestore directamente en getStudentProgress)
    final service = StatisticsService(firestore: fakeFirestore);
    repository = StatisticsRepositoryImpl(
      statisticsService: service,
      firestore: fakeFirestore,
    );
  });

  // ---------------------------------------------------------------------------
  // getDailyStats — Validaciones de argumentos en la capa repositorio
  // ---------------------------------------------------------------------------
  group('StatisticsRepositoryImpl.getDailyStats', () {
    test('lanza InvalidDateRangeException si studentId está vacío', () {
      expect(
        () => repository.getDailyStats(studentId: '   ', date: DateTime.now()),
        throwsA(isA<InvalidDateRangeException>()),
      );
    });

    test('devuelve DailyStatsModel para un estudiante con sessiones', () async {
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

      final result = await repository.getDailyStats(
        studentId: 'student-1',
        date: day,
      );

      expect(result, isA<DailyStatsModel>());
      expect(result.totalDuration, 1800);
      expect(result.totalSessions, 1);
    });

    test('devuelve métricas vacías si no hay sesiones', () async {
      final result = await repository.getDailyStats(
        studentId: 'student-noop',
        date: DateTime(2025, 6, 1),
      );

      expect(result.totalDuration, 0);
      expect(result.totalSessions, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // getWeeklyStats — Validaciones de argumentos en la capa repositorio
  // ---------------------------------------------------------------------------
  group('StatisticsRepositoryImpl.getWeeklyStats', () {
    test('lanza InvalidDateRangeException si studentId está vacío', () {
      expect(
        () => repository.getWeeklyStats(
          studentId: '',
          weekStart: DateTime(2026, 2, 9),
        ),
        throwsA(isA<InvalidDateRangeException>()),
      );
    });

    test('devuelve WeeklyStatsModel con desglose de 7 días', () async {
      final monday = DateTime(2026, 2, 9);
      await _addSession(
        fakeFirestore,
        id: 'ws1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: monday,
        totalDuration: 1200,
      );

      final result = await repository.getWeeklyStats(
        studentId: 'student-1',
        weekStart: monday,
      );

      expect(result, isA<WeeklyStatsModel>());
      expect(result.dailyBreakdown.length, 7);
      expect(result.totalDuration, 1200);
    });
  });

  // ---------------------------------------------------------------------------
  // getMonthlyStats — Validaciones de argumentos en la capa repositorio
  // ---------------------------------------------------------------------------
  group('StatisticsRepositoryImpl.getMonthlyStats', () {
    test('lanza InvalidDateRangeException si studentId está vacío', () {
      expect(
        () => repository.getMonthlyStats(studentId: '', month: 1, year: 2026),
        throwsA(isA<InvalidDateRangeException>()),
      );
    });

    test('lanza InvalidDateRangeException si mes es 0 o 13', () {
      for (final month in [0, 13]) {
        expect(
          () => repository.getMonthlyStats(
            studentId: 'student-1',
            month: month,
            year: 2026,
          ),
          throwsA(isA<InvalidDateRangeException>()),
        );
      }
    });

    test(
      'lanza InvalidDateRangeException si año está fuera de [2000, 2100]',
      () {
        for (final year in [1999, 2101]) {
          expect(
            () => repository.getMonthlyStats(
              studentId: 'student-1',
              month: 1,
              year: year,
            ),
            throwsA(isA<InvalidDateRangeException>()),
          );
        }
      },
    );

    test('devuelve métricas correctas del mes', () async {
      final jan = DateTime(2026, 1, 15);
      await _addSession(
        fakeFirestore,
        id: 'mst1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        dateLogged: jan,
        totalDuration: 3600,
      );

      final result = await repository.getMonthlyStats(
        studentId: 'student-1',
        month: 1,
        year: 2026,
      );

      expect(result, isA<DailyStatsModel>());
      expect(result.totalDuration, 3600);
    });
  });

  // ---------------------------------------------------------------------------
  // getTaskStats — Validaciones de argumentos en la capa repositorio
  // ---------------------------------------------------------------------------
  group('StatisticsRepositoryImpl.getTaskStats', () {
    test('lanza ResourceNotFoundException si taskId está vacío', () {
      expect(
        () => repository.getTaskStats(taskId: ''),
        throwsA(isA<ResourceNotFoundException>()),
      );
    });

    test('devuelve TaskStatsModel para tarea existente', () async {
      await fakeFirestore.collection('tasks').doc('task-repo').set({
        'id': 'task-repo',
        'title': 'Acordes',
        'durationSuggested': 20,
      });
      final day = DateTime(2026, 2, 10);
      await _addSession(
        fakeFirestore,
        id: 'ts1',
        studentId: 'student-1',
        taskId: 'task-repo',
        teacherId: 'teacher-1',
        dateLogged: day,
        totalDuration: 1000,
      );

      final result = await repository.getTaskStats(taskId: 'task-repo');

      expect(result, isA<TaskStatsModel>());
      expect(result.taskTitle, 'Acordes');
      expect(result.totalSessions, 1);
      expect(result.totalDuration, 1000);
    });
  });

  // ---------------------------------------------------------------------------
  // getClassStats — Validaciones de argumentos en la capa repositorio
  // ---------------------------------------------------------------------------
  group('StatisticsRepositoryImpl.getClassStats', () {
    test('lanza ResourceNotFoundException si classId está vacío', () {
      expect(
        () => repository.getClassStats(classId: '', teacherId: 'teacher-1'),
        throwsA(isA<ResourceNotFoundException>()),
      );
    });

    test('lanza PermissionDeniedException si teacherId está vacío', () {
      expect(
        () => repository.getClassStats(classId: 'class-1', teacherId: ''),
        throwsA(isA<PermissionDeniedException>()),
      );
    });

    test('devuelve ClassStatsModel para clase existente con alumnos', () async {
      await fakeFirestore.collection('classes').doc('class-r').set({
        'id': 'class-r',
        'name': 'Piano',
        'ownerTeacherId': 'teacher-1',
      });
      await fakeFirestore.collection('memberships').doc('mem-1').set({
        'classId': 'class-r',
        'studentId': 'student-1',
        'isActive': true,
      });
      await _addSession(
        fakeFirestore,
        id: 'cs1',
        studentId: 'student-1',
        taskId: 'task-1',
        teacherId: 'teacher-1',
        classId: 'class-r',
        dateLogged: DateTime(2026, 2, 10),
        totalDuration: 900,
      );

      final result = await repository.getClassStats(
        classId: 'class-r',
        teacherId: 'teacher-1',
      );

      expect(result, isA<ClassStatsModel>());
      expect(result.className, 'Piano');
      expect(result.totalStudents, 1);
      expect(result.totalSessions, 1);
      expect(result.totalDuration, 900);
    });
  });

  // ---------------------------------------------------------------------------
  // Jerarquía de excepciones
  // ---------------------------------------------------------------------------
  group('Jerarquía de excepciones de estadísticas', () {
    test('InvalidDateRangeException es StatisticsException', () {
      expect(
        const InvalidDateRangeException(userMessage: 'Rango inválido'),
        isA<StatisticsException>(),
      );
    });

    test('ResourceNotFoundException es StatisticsException', () {
      expect(
        const ResourceNotFoundException(
          resourceType: 'Task',
          resourceId: '1',
          userMessage: 'Not found',
        ),
        isA<StatisticsException>(),
      );
    });

    test('PermissionDeniedException es StatisticsException', () {
      expect(
        const PermissionDeniedException(userMessage: 'Denegado'),
        isA<StatisticsException>(),
      );
    });

    test('StatisticsServiceException es StatisticsException', () {
      expect(
        const StatisticsServiceException(userMessage: 'Error', message: 'msg'),
        isA<StatisticsException>(),
      );
    });

    test('NoDataFoundException es StatisticsException', () {
      expect(
        const NoDataFoundException(userMessage: 'Sin datos'),
        isA<StatisticsException>(),
      );
    });
  });
}

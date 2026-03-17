import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/daily_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';

/// Servicio para cálculos y consultas de estadísticas desde Firestore.
///
/// Este servicio realiza queries agregadas sobre la colección `sessions`
/// y otras colecciones para generar estadísticas y métricas.
final class StatisticsService {
  StatisticsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sessionsCollection =>
      _firestore.collection(_sessionsCollectionName);

  /// Obtiene estadísticas diarias para un estudiante en una fecha específica.
  Future<DailyStatsModel> getDailyStats({
    required String studentId,
    required DateTime date,
    String? classId,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw ArgumentError('El ID del estudiante es obligatorio');
    }

    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final startOfDay = Timestamp.fromDate(normalizedDate);
      final endOfDay = Timestamp.fromDate(
        normalizedDate.add(const Duration(days: 1)),
      );

      log(
        'StatisticsService: Consultando estadísticas diarias para $sanitizedId en $normalizedDate',
        name: 'StatisticsService',
      );

      Query<Map<String, dynamic>> query = _sessionsCollection
          .where('studentId', isEqualTo: sanitizedId)
          .where('dateLogged', isGreaterThanOrEqualTo: startOfDay)
          .where('dateLogged', isLessThan: endOfDay);

      if (classId != null && classId.isNotEmpty) {
        query = query.where('classId', isEqualTo: classId);
      }

      final querySnapshot = await query.get();

      int totalDuration = 0;
      final uniqueTasks = <String>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        totalDuration += (data['totalDuration'] as int?) ?? 0;
        final taskId = data['taskId'] as String?;
        if (taskId != null) {
          uniqueTasks.add(taskId);
        }
      }

      return DailyStatsModel(
        date: startOfDay,
        totalDuration: totalDuration,
        totalSessions: querySnapshot.docs.length,
        uniqueTasks: uniqueTasks.length,
      );
    } on FirebaseException catch (error, stackTrace) {
      _logError('getDailyStats', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Obtiene estadísticas semanales para un estudiante (mantiene compatibilidad).
  Future<WeeklyStatsModel> getWeeklyStats({
    required String studentId,
    required DateTime weekStart,
    String? classId,
  }) async {
    // Calculamos si weekStart es de esta semana para aplicar un filtro coherente
    // pero por ahora redirigimos a getStudentStats con thisWeek.
    return getStudentStats(
      studentId: studentId,
      timeFilter: TimeFilter.thisWeek,
      classId: classId,
    );
  }

  /// Obtiene estadísticas detalladas de un estudiante con filtro de tiempo.
  Future<WeeklyStatsModel> getStudentStats({
    required String studentId,
    required TimeFilter timeFilter,
    String? classId,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw ArgumentError('El ID del estudiante es obligatorio');
    }

    try {
      log(
        'StatisticsService: Consultando estadísticas para $sanitizedId con filtro $timeFilter',
        name: 'StatisticsService',
      );

      var query = _sessionsCollection.where(
        'studentId',
        isEqualTo: sanitizedId,
      );
      if (classId != null && classId.isNotEmpty) {
        query = query.where('classId', isEqualTo: classId);
      }

      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      switch (timeFilter) {
        case TimeFilter.thisWeek:
          startDate = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: now.weekday - 1));
          endDate = startDate.add(const Duration(days: 7));
          query = query
              .where(
                'dateLogged',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('dateLogged', isLessThan: Timestamp.fromDate(endDate));
          break;
        case TimeFilter.thisMonth:
          final monthBucket =
              '${now.year}-${now.month.toString().padLeft(2, '0')}';
          query = query.where('monthBucket', isEqualTo: monthBucket);
          startDate = DateTime(now.year, now.month, 1);
          break;
        case TimeFilter.last3Months:
          final buckets = List.generate(3, (i) {
            final d = DateTime(now.year, now.month - i, 1);
            return '${d.year}-${d.month.toString().padLeft(2, '0')}';
          });
          query = query.where('monthBucket', whereIn: buckets);
          startDate = DateTime(now.year, now.month - 2, 1);
          break;
        case TimeFilter.last9Months:
          final buckets = List.generate(9, (i) {
            final d = DateTime(now.year, now.month - i, 1);
            return '${d.year}-${d.month.toString().padLeft(2, '0')}';
          });
          query = query.where('monthBucket', whereIn: buckets);
          startDate = DateTime(now.year, now.month - 8, 1);
          break;
        case TimeFilter.allTime:
          startDate = DateTime(2000);
          break;
      }

      final querySnapshot = await query
          .orderBy('dateLogged', descending: true)
          .get();

      int totalDuration = 0;
      final uniqueTasks = <String>{};
      final dailyMap = <String, List<SessionModel>>{};
      final taskMap = <String, ({String title, int duration, int sessions})>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final session = SessionModel.fromJson(data);

        totalDuration += session.totalDuration;
        uniqueTasks.add(session.taskId);

        final dayKey = _getDayKey(session.dateLogged.toDate());
        dailyMap.putIfAbsent(dayKey, () => []).add(session);

        final existing = taskMap[session.taskId];
        if (existing != null) {
          taskMap[session.taskId] = (
            title: existing.title,
            duration: existing.duration + session.totalDuration,
            sessions: existing.sessions + 1,
          );
        } else {
          taskMap[session.taskId] = (
            title: session.taskTitle ?? 'Tarea desconocida',
            duration: session.totalDuration,
            sessions: 1,
          );
        }
      }

      final dailyBreakdown = <DailyStatsModel>[];
      if (timeFilter == TimeFilter.thisWeek) {
        final weekStart = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        for (int i = 0; i < 7; i++) {
          final currentDay = weekStart.add(Duration(days: i));
          final dayKey = _getDayKey(currentDay);
          final daySessions = dailyMap[dayKey] ?? [];
          dailyBreakdown.add(
            DailyStatsModel(
              date: Timestamp.fromDate(currentDay),
              totalDuration: daySessions.fold(
                0,
                (acc, s) => acc + s.totalDuration,
              ),
              totalSessions: daySessions.length,
              uniqueTasks: daySessions.map((s) => s.taskId).toSet().length,
            ),
          );
        }
      } else {
        for (int i = 6; i >= 0; i--) {
          final currentDay = now.subtract(Duration(days: i));
          final dayKey = _getDayKey(currentDay);
          final daySessions = dailyMap[dayKey] ?? [];
          dailyBreakdown.add(
            DailyStatsModel(
              date: Timestamp.fromDate(currentDay),
              totalDuration: daySessions.fold(
                0,
                (acc, s) => acc + s.totalDuration,
              ),
              totalSessions: daySessions.length,
              uniqueTasks: daySessions.map((s) => s.taskId).toSet().length,
            ),
          );
        }
      }

      final taskBreakdown = taskMap.entries
          .map(
            (entry) => TaskStatsModel(
              taskId: entry.key,
              taskTitle: entry.value.title,
              totalDuration: entry.value.duration,
              totalSessions: entry.value.sessions,
            ),
          )
          .toList();

      return WeeklyStatsModel(
        weekStart: Timestamp.fromDate(startDate),
        weekEnd: Timestamp.fromDate(endDate),
        totalDuration: totalDuration,
        totalSessions: querySnapshot.docs.length,
        uniqueTasks: uniqueTasks.length,
        dailyBreakdown: dailyBreakdown,
        taskBreakdown: taskBreakdown,
      );
    } on FirebaseException catch (error, stackTrace) {
      _logError('getStudentStats', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Obtiene estadísticas mensuales para un estudiante.
  Future<DailyStatsModel> getMonthlyStats({
    required String studentId,
    required int month,
    required int year,
    String? classId,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw ArgumentError('El ID del estudiante es obligatorio');
    }
    if (month < 1 || month > 12) {
      throw ArgumentError('El mes debe estar entre 1 y 12');
    }

    try {
      final monthBucket = '$year-${month.toString().padLeft(2, '0')}';
      Query<Map<String, dynamic>> query = _sessionsCollection
          .where('studentId', isEqualTo: sanitizedId)
          .where('monthBucket', isEqualTo: monthBucket);

      if (classId != null && classId.isNotEmpty) {
        query = query.where('classId', isEqualTo: classId);
      }

      final querySnapshot = await query.get();
      int totalDuration = 0;
      final uniqueTasks = <String>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        totalDuration += (data['totalDuration'] as int?) ?? 0;
        final taskId = data['taskId'] as String?;
        if (taskId != null) uniqueTasks.add(taskId);
      }

      return DailyStatsModel(
        date: Timestamp.fromDate(DateTime(year, month, 1)),
        totalDuration: totalDuration,
        totalSessions: querySnapshot.docs.length,
        uniqueTasks: uniqueTasks.length,
      );
    } on FirebaseException catch (error, stackTrace) {
      _logError('getMonthlyStats', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Obtiene estadísticas de una tarea específica.
  Future<TaskStatsModel> getTaskStats({
    required String taskId,
    String? studentId,
  }) async {
    final sanitizedTaskId = taskId.trim();
    if (sanitizedTaskId.isEmpty) {
      throw ArgumentError('El ID de la tarea es obligatorio');
    }
    try {
      Query<Map<String, dynamic>> query = _sessionsCollection.where(
        'taskId',
        isEqualTo: sanitizedTaskId,
      );
      final sanitizedStudentId = studentId?.trim();
      if (sanitizedStudentId != null && sanitizedStudentId.isNotEmpty) {
        query = query.where('studentId', isEqualTo: sanitizedStudentId);
      }

      final querySnapshot = await query.get();
      int totalDuration = 0;
      DateTime? lastSessionDate;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        totalDuration += (data['totalDuration'] as int?) ?? 0;
        final endTime = data['endTime'] as Timestamp?;
        if (endTime != null) {
          final sDate = endTime.toDate();
          if (lastSessionDate == null || sDate.isAfter(lastSessionDate)) {
            lastSessionDate = sDate;
          }
        }
      }

      // Obtener título y otros datos de la tarea
      final taskDoc = await _firestore
          .collection('tasks')
          .doc(sanitizedTaskId)
          .get();
      final taskTitle = taskDoc.exists
          ? (taskDoc.data()?['title'] as String? ?? 'Tarea desconocida')
          : 'Tarea desconocida';
      final suggestedDuration = taskDoc.exists
          ? ((taskDoc.data()?['durationSuggested'] as int? ?? 0) * 60)
          : 0;

      // Consultar el assignment para determinar si la tarea está completada
      bool isCompleted = false;
      if (sanitizedStudentId != null && sanitizedStudentId.isNotEmpty) {
        final assignmentId = '${sanitizedTaskId}_$sanitizedStudentId';
        final assignmentDoc = await _firestore
            .collection('assignments')
            .doc(assignmentId)
            .get();
        if (assignmentDoc.exists) {
          isCompleted =
              (assignmentDoc.data()?['status'] as String?) == 'completed';
        }
      }

      return TaskStatsModel(
        taskId: sanitizedTaskId,
        taskTitle: taskTitle,
        totalDuration: totalDuration,
        totalSessions: querySnapshot.docs.length,
        suggestedDuration: suggestedDuration,
        lastSessionDate: lastSessionDate,
        isCompleted: isCompleted,
      );
    } on FirebaseException catch (error, stackTrace) {
      _logError('getTaskStats', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Obtiene estadísticas agregadas de una clase (vista docente).
  Future<ClassStatsModel> getClassStats({
    required String classId,
    required String teacherId,
    TimeFilter timeFilter = TimeFilter.thisWeek,
  }) async {
    final sanitizedClassId = classId.trim();
    if (sanitizedClassId.isEmpty) {
      throw ArgumentError('El ID de la clase es obligatorio');
    }
    if (teacherId.trim().isEmpty) {
      throw ArgumentError('El ID del docente es obligatorio');
    }
    try {
      final sessionsSnapshot = await _buildFilteredQuery(
        classId: sanitizedClassId,
        teacherId: teacherId,
        timeFilter: timeFilter,
      );

      final classDoc = await _firestore
          .collection('classes')
          .doc(sanitizedClassId)
          .get();
      if (!classDoc.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'La clase no existe',
        );
      }
      final className = classDoc.data()?['name'] as String? ?? 'Clase';

      // Contar alumnos activos desde la colección memberships
      final membershipsSnapshot = await _firestore
          .collection('memberships')
          .where('classId', isEqualTo: sanitizedClassId)
          .where('isActive', isEqualTo: true)
          .get();
      final totalStudents = membershipsSnapshot.docs.length;

      int totalDuration = 0;
      final activeStudentIds = <String>{};
      final taskMap = <String, ({String title, int duration, int sessions})>{};

      for (final doc in sessionsSnapshot.docs) {
        final data = doc.data();
        final sessionDuration = (data['totalDuration'] as int?) ?? 0;
        totalDuration += sessionDuration;
        activeStudentIds.add(data['studentId'] as String);

        final taskId = data['taskId'] as String?;
        if (taskId != null) {
          final taskTitle = data['taskTitle'] as String? ?? 'Tarea';
          final existing = taskMap[taskId];
          if (existing != null) {
            taskMap[taskId] = (
              title: existing.title,
              duration: existing.duration + sessionDuration,
              sessions: existing.sessions + 1,
            );
          } else {
            taskMap[taskId] = (
              title: taskTitle,
              duration: sessionDuration,
              sessions: 1,
            );
          }
        }
      }

      final taskBreakdown = taskMap.entries
          .map(
            (entry) => TaskStatsModel(
              taskId: entry.key,
              taskTitle: entry.value.title,
              totalDuration: entry.value.duration,
              totalSessions: entry.value.sessions,
            ),
          )
          .toList();

      return ClassStatsModel(
        classId: sanitizedClassId,
        className: className,
        totalStudents: totalStudents,
        activeStudents: activeStudentIds.length,
        totalDuration: totalDuration,
        totalSessions: sessionsSnapshot.docs.length,
        taskBreakdown: taskBreakdown,
      );
    } on FirebaseException catch (error, stackTrace) {
      _logError('getClassStats', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Obtiene estadísticas por alumno dentro de una clase para un periodo de tiempo.
  Future<List<StudentClassStatsModel>> getStudentsClassStats({
    required String classId,
    required String teacherId,
    TimeFilter timeFilter = TimeFilter.thisWeek,
  }) async {
    final sanitizedClassId = classId.trim();
    if (sanitizedClassId.isEmpty) {
      throw ArgumentError('El ID de la clase es obligatorio');
    }
    try {
      // 1. Obtener membresías activas para nombres de alumnos
      final membershipsSnapshot = await _firestore
          .collection('memberships')
          .where('classId', isEqualTo: sanitizedClassId)
          .where('isActive', isEqualTo: true)
          .get();

      final studentNames = <String, String>{};
      for (final doc in membershipsSnapshot.docs) {
        final data = doc.data();
        final studentId = data['studentId'] as String?;
        final studentName = data['studentName'] as String?;
        if (studentId != null && studentName != null) {
          studentNames[studentId] = studentName;
        }
      }

      if (studentNames.isEmpty) return [];

      // 2. Consultar sesiones con el filtro de tiempo
      final sessionsSnapshot = await _buildFilteredQuery(
        classId: sanitizedClassId,
        teacherId: teacherId,
        timeFilter: timeFilter,
      );

      // 3. Agregar por alumno
      final studentMap =
          <String, ({int duration, int sessions, DateTime? lastSession})>{};
      for (final doc in sessionsSnapshot.docs) {
        final data = doc.data();
        final studentId = data['studentId'] as String?;
        if (studentId == null) continue;
        final duration = (data['totalDuration'] as int?) ?? 0;
        final dateLogged = (data['dateLogged'] as Timestamp?)?.toDate();
        final existing = studentMap[studentId];
        if (existing != null) {
          final best = existing.lastSession != null && dateLogged != null
              ? (dateLogged.isAfter(existing.lastSession!)
                    ? dateLogged
                    : existing.lastSession)
              : existing.lastSession ?? dateLogged;
          studentMap[studentId] = (
            duration: existing.duration + duration,
            sessions: existing.sessions + 1,
            lastSession: best,
          );
        } else {
          studentMap[studentId] = (
            duration: duration,
            sessions: 1,
            lastSession: dateLogged,
          );
        }
      }

      // 4. Construir lista incluyendo alumnos sin actividad
      final result = studentNames.entries.map((entry) {
        final stats = studentMap[entry.key];
        return StudentClassStatsModel(
          studentId: entry.key,
          studentName: entry.value,
          totalDuration: stats?.duration ?? 0,
          totalSessions: stats?.sessions ?? 0,
          lastSessionDate: stats?.lastSession,
        );
      }).toList()
        ..sort((a, b) => b.totalDuration.compareTo(a.totalDuration));

      return result;
    } on FirebaseException catch (error, stackTrace) {
      _logError('getStudentsClassStats', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _buildFilteredQuery({
    required String classId,
    required String teacherId,
    required TimeFilter timeFilter,
  }) async {
    var query = _sessionsCollection
        .where('classId', isEqualTo: classId)
        .where('teacherId', isEqualTo: teacherId);
    final now = DateTime.now();

    switch (timeFilter) {
      case TimeFilter.thisWeek:
        final weekStart = Timestamp.fromDate(
          now.subtract(const Duration(days: 7)),
        );
        return query
            .where('dateLogged', isGreaterThanOrEqualTo: weekStart)
            .orderBy('dateLogged', descending: true)
            .get();
      case TimeFilter.thisMonth:
        final monthBucket =
            '${now.year}-${now.month.toString().padLeft(2, '0')}';
        return query
            .where('monthBucket', isEqualTo: monthBucket)
            .orderBy('dateLogged', descending: true)
            .get();
      case TimeFilter.last3Months:
        final buckets = List.generate(3, (i) {
          final d = DateTime(now.year, now.month - i, 1);
          return '${d.year}-${d.month.toString().padLeft(2, '0')}';
        });
        return query
            .where('monthBucket', whereIn: buckets)
            .orderBy('dateLogged', descending: true)
            .get();
      case TimeFilter.last9Months:
        final buckets = List.generate(9, (i) {
          final d = DateTime(now.year, now.month - i, 1);
          return '${d.year}-${d.month.toString().padLeft(2, '0')}';
        });
        return query
            .where('monthBucket', whereIn: buckets)
            .orderBy('dateLogged', descending: true)
            .get();
      case TimeFilter.allTime:
        return query.orderBy('dateLogged', descending: true).get();
    }
  }

  String _getDayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _logError(
    String method,
    FirebaseException error,
    StackTrace stackTrace,
  ) {
    log(
      'StatisticsService#$method FirebaseException: ${error.code}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

const _sessionsCollectionName = 'sessions';

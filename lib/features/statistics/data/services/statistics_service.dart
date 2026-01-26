import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/daily_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';

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

  CollectionReference<Map<String, dynamic>> get _assignmentsCollection =>
      _firestore.collection(_assignmentsCollectionName);

  /// Obtiene estadísticas diarias para un estudiante en una fecha específica.
  ///
  /// Parámetros:
  /// - [studentId]: ID del estudiante
  /// - [date]: Fecha del día (sin componente de hora)
  ///
  /// Retorna [DailyStatsModel] con las métricas del día.
  /// Lanza [FirebaseErrorMapperException] si ocurre un error de Firestore.
  /// Lanza [ArgumentError] si los parámetros son inválidos.
  Future<DailyStatsModel> getDailyStats({
    required String studentId,
    required DateTime date,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw ArgumentError('El ID del estudiante es obligatorio');
    }

    try {
      // Normalizar fecha (sin hora, min, seg)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final startOfDay = Timestamp.fromDate(normalizedDate);
      final endOfDay = Timestamp.fromDate(
        normalizedDate.add(const Duration(days: 1)),
      );

      log(
        'StatisticsService: Consultando estadísticas diarias para $sanitizedId en $normalizedDate',
        name: 'StatisticsService',
      );

      // Consultar sesiones del día
      final querySnapshot = await _sessionsCollection
          .where('studentId', isEqualTo: sanitizedId)
          .where('dateLogged', isGreaterThanOrEqualTo: startOfDay)
          .where('dateLogged', isLessThan: endOfDay)
          .get();

      // Calcular métricas
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

  /// Obtiene estadísticas semanales para un estudiante.
  ///
  /// Parámetros:
  /// - [studentId]: ID del estudiante
  /// - [weekStart]: Fecha de inicio de la semana (lunes)
  ///
  /// Retorna [WeeklyStatsModel] con las métricas de la semana y desglose diario.
  Future<WeeklyStatsModel> getWeeklyStats({
    required String studentId,
    required DateTime weekStart,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw ArgumentError('El ID del estudiante es obligatorio');
    }

    try {
      // Normalizar a lunes de la semana
      final normalizedWeekStart = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      );
      final weekEnd = normalizedWeekStart.add(const Duration(days: 7));

      log(
        'StatisticsService: Consultando estadísticas semanales para $sanitizedId '
        'desde $normalizedWeekStart hasta $weekEnd',
        name: 'StatisticsService',
      );

      // Consultar sesiones de la semana
      final querySnapshot = await _sessionsCollection
          .where('studentId', isEqualTo: sanitizedId)
          .where(
            'dateLogged',
            isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedWeekStart),
          )
          .where('dateLogged', isLessThan: Timestamp.fromDate(weekEnd))
          .get();

      // Calcular métricas semanales
      int totalDuration = 0;
      final uniqueTasks = <String>{};
      final dailyMap = <String, List<SessionModel>>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final session = SessionModel.fromJson(data);

        totalDuration += session.totalDuration;
        uniqueTasks.add(session.taskId);

        // Agrupar por día
        final dayKey = _getDayKey(session.dateLogged.toDate());
        dailyMap.putIfAbsent(dayKey, () => []).add(session);
      }

      // Generar desglose diario (7 días)
      final dailyBreakdown = <DailyStatsModel>[];
      for (int i = 0; i < 7; i++) {
        final currentDay = normalizedWeekStart.add(Duration(days: i));
        final dayKey = _getDayKey(currentDay);
        final daySessions = dailyMap[dayKey] ?? [];

        int dayDuration = 0;
        final dayTasks = <String>{};
        for (final session in daySessions) {
          dayDuration += session.totalDuration;
          dayTasks.add(session.taskId);
        }

        dailyBreakdown.add(
          DailyStatsModel(
            date: Timestamp.fromDate(currentDay),
            totalDuration: dayDuration,
            totalSessions: daySessions.length,
            uniqueTasks: dayTasks.length,
          ),
        );
      }

      // Obtener duración de semana anterior (opcional)
      final previousWeekStart = normalizedWeekStart.subtract(
        const Duration(days: 7),
      );
      int? previousWeekDuration;
      try {
        final previousStats = await getWeeklyStats(
          studentId: studentId,
          weekStart: previousWeekStart,
        );
        previousWeekDuration = previousStats.totalDuration;
      } catch (e) {
        // Ignorar si no hay datos de semana anterior
        previousWeekDuration = null;
      }

      return WeeklyStatsModel(
        weekStart: Timestamp.fromDate(normalizedWeekStart),
        weekEnd: Timestamp.fromDate(weekEnd),
        totalDuration: totalDuration,
        totalSessions: querySnapshot.docs.length,
        uniqueTasks: uniqueTasks.length,
        dailyBreakdown: dailyBreakdown,
        previousWeekDuration: previousWeekDuration,
      );
    } on FirebaseException catch (error, stackTrace) {
      _logError('getWeeklyStats', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Obtiene estadísticas mensuales para un estudiante.
  ///
  /// Parámetros:
  /// - [studentId]: ID del estudiante
  /// - [month]: Mes (1-12)
  /// - [year]: Año (ej: 2026)
  ///
  /// Retorna [DailyStatsModel] con métricas del mes (reutilizamos el modelo).
  Future<DailyStatsModel> getMonthlyStats({
    required String studentId,
    required int month,
    required int year,
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

      log(
        'StatisticsService: Consultando estadísticas mensuales para '
        '$sanitizedId en $monthBucket',
        name: 'StatisticsService',
      );

      // Consultar sesiones usando monthBucket (optimizado)
      final querySnapshot = await _sessionsCollection
          .where('studentId', isEqualTo: sanitizedId)
          .where('monthBucket', isEqualTo: monthBucket)
          .get();

      // Calcular métricas
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

  /// Obtiene estadísticas de una tarea específica para un estudiante.
  ///
  /// Parámetros:
  /// - [taskId]: ID de la tarea
  /// - [studentId]: ID del estudiante (opcional para vista docente)
  ///
  /// Retorna [TaskStatsModel] con las métricas de la tarea.
  Future<TaskStatsModel> getTaskStats({
    required String taskId,
    String? studentId,
  }) async {
    final sanitizedTaskId = taskId.trim();
    if (sanitizedTaskId.isEmpty) {
      throw ArgumentError('El ID de la tarea es obligatorio');
    }

    try {
      log(
        'StatisticsService: Consultando estadísticas de tarea $sanitizedTaskId'
        '${studentId != null ? " para estudiante $studentId" : ""}',
        name: 'StatisticsService',
      );

      // Consultar sesiones de la tarea
      Query<Map<String, dynamic>> query = _sessionsCollection.where(
        'taskId',
        isEqualTo: sanitizedTaskId,
      );

      if (studentId != null && studentId.trim().isNotEmpty) {
        query = query.where('studentId', isEqualTo: studentId.trim());
      }

      final querySnapshot = await query.get();

      // Calcular métricas
      int totalDuration = 0;
      DateTime? lastSessionDate;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        totalDuration += (data['totalDuration'] as int?) ?? 0;

        final endTime = data['endTime'] as Timestamp?;
        if (endTime != null) {
          final sessionDate = endTime.toDate();
          if (lastSessionDate == null || sessionDate.isAfter(lastSessionDate)) {
            lastSessionDate = sessionDate;
          }
        }
      }

      // Obtener datos de assignment si hay studentId
      int? suggestedDuration;
      bool isCompleted = false;

      if (studentId != null && studentId.trim().isNotEmpty) {
        final assignmentId = '${sanitizedTaskId}_${studentId.trim()}';
        final assignmentDoc = await _assignmentsCollection
            .doc(assignmentId)
            .get();

        if (assignmentDoc.exists) {
          final assignmentData = assignmentDoc.data();
          final taskDoc = await _firestore
              .collection('tasks')
              .doc(sanitizedTaskId)
              .get();

          if (taskDoc.exists) {
            final taskData = taskDoc.data();
            final durationMinutes = taskData?['durationSuggested'] as int?;
            if (durationMinutes != null) {
              suggestedDuration = durationMinutes * 60; // convertir a segundos
            }
          }

          final status = assignmentData?['status'] as String?;
          isCompleted = status == 'completed';
        }
      }

      // Obtener título de tarea
      final taskDoc = await _firestore
          .collection('tasks')
          .doc(sanitizedTaskId)
          .get();
      final taskTitle = taskDoc.exists
          ? (taskDoc.data()?['title'] as String? ?? 'Tarea desconocida')
          : 'Tarea desconocida';

      return TaskStatsModel(
        taskId: sanitizedTaskId,
        taskTitle: taskTitle,
        totalDuration: totalDuration,
        totalSessions: querySnapshot.docs.length,
        suggestedDuration: suggestedDuration,
        isCompleted: isCompleted,
        lastSessionDate: lastSessionDate,
      );
    } on FirebaseException catch (error, stackTrace) {
      _logError('getTaskStats', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Obtiene estadísticas agregadas de una clase (vista docente).
  ///
  /// Parámetros:
  /// - [classId]: ID de la clase
  /// - [teacherId]: ID del docente (para validación)
  ///
  /// Retorna [ClassStatsModel] con las métricas de todos los alumnos.
  Future<ClassStatsModel> getClassStats({
    required String classId,
    required String teacherId,
  }) async {
    final sanitizedClassId = classId.trim();
    final sanitizedTeacherId = teacherId.trim();

    if (sanitizedClassId.isEmpty) {
      throw ArgumentError('El ID de la clase es obligatorio');
    }
    if (sanitizedTeacherId.isEmpty) {
      throw ArgumentError('El ID del docente es obligatorio');
    }

    try {
      log(
        'StatisticsService: Consultando estadísticas de clase $sanitizedClassId',
        name: 'StatisticsService',
      );

      // 1. Obtener información de la clase
      final classDoc = await _firestore
          .collection('classes')
          .doc(sanitizedClassId)
          .get();

      if (!classDoc.exists) {
        throw FirebaseErrorMapperException(
          StatisticsStrings.resourceNotFoundError,
        );
      }

      final className =
          classDoc.data()?['name'] as String? ?? 'Clase desconocida';

      // 2. Obtener membresías activas de la clase
      final membershipsSnapshot = await _firestore
          .collection('memberships')
          .where('classId', isEqualTo: sanitizedClassId)
          .where('isActive', isEqualTo: true)
          .get();

      final studentIds = membershipsSnapshot.docs
          .map((doc) => doc.data()['studentId'] as String)
          .toList();

      if (studentIds.isEmpty) {
        return ClassStatsModel(
          classId: sanitizedClassId,
          className: className,
          totalStudents: 0,
          activeStudents: 0,
          totalDuration: 0,
          totalSessions: 0,
        );
      }

      // 3. Obtener sesiones de todos los estudiantes de la clase
      final sessionsSnapshot = await _sessionsCollection
          .where('teacherId', isEqualTo: sanitizedTeacherId)
          .where('studentId', whereIn: studentIds)
          .get();

      // 4. Calcular métricas globales
      int totalDuration = 0;
      final activeStudentIds = <String>{};
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      for (final doc in sessionsSnapshot.docs) {
        final data = doc.data();
        totalDuration += (data['totalDuration'] as int?) ?? 0;

        // Contar estudiantes con actividad en la última semana
        final endTime = data['endTime'] as Timestamp?;
        if (endTime != null && endTime.toDate().isAfter(oneWeekAgo)) {
          final studentId = data['studentId'] as String?;
          if (studentId != null) {
            activeStudentIds.add(studentId);
          }
        }
      }

      // 5. Obtener estadísticas por tarea (opcional, simplificado)
      // En una implementación completa, aquí se consultarían tareas de la clase
      final taskBreakdown = <TaskStatsModel>[];

      return ClassStatsModel(
        classId: sanitizedClassId,
        className: className,
        totalStudents: studentIds.length,
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

  /// Genera una clave única para agrupar sesiones por día
  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Registra errores de Firebase en el log
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

// Constantes
const _sessionsCollectionName = 'sessions';
const _assignmentsCollectionName = 'assignments';

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/statistics/data/repositories/cached_stats.dart';
import 'package:playing_tracker/features/statistics/data/services/statistics_service.dart';
import 'package:playing_tracker/features/statistics/domain/exceptions/statistics_exception.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/daily_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';

/// Implementación concreta del [StatisticsRepository].
///
/// Orquesta el [StatisticsService] y mapea errores de Firestore a
/// excepciones de dominio con mensajes en español desde [StatisticsStrings].
final class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl({
    StatisticsService? statisticsService,
    FirebaseFirestore? firestore,
  }) : _statisticsService = statisticsService ?? StatisticsService(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  final StatisticsService _statisticsService;
  final FirebaseFirestore _firestore;

  /// TTL de la caché en memoria: 2 minutos para reflejar sesiones recientes.
  static const _cacheTtl = Duration(minutes: 2);

  /// Caché en memoria indexada por "classId_filterName".
  final Map<String, CachedStats<ClassStatsModel>> _classStatsCache = {};

  /// Caché en memoria para las estadísticas de estudiantes.
  final Map<String, CachedStats<WeeklyStatsModel>> _studentStatsCache = {};

  /// Caché en memoria para el progreso general del estudiante.
  final Map<String, CachedStats<StudentProgressModel>> _studentProgressCache =
      {};

  /// Caché en memoria para el ranking de alumnos por clase.
  final Map<String, CachedStats<List<StudentClassStatsModel>>>
  _studentsClassStatsCache = {};

  @override
  Future<DailyStatsModel> getDailyStats({
    required String studentId,
    required DateTime date,
    String? classId,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidDateRangeException(
        userMessage: 'El ID del estudiante es obligatorio',
      );
    }

    try {
      return await _statisticsService.getDailyStats(
        studentId: sanitizedId,
        date: date,
        classId: classId,
      );
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getDailyStats',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<WeeklyStatsModel> getWeeklyStats({
    required String studentId,
    required DateTime weekStart,
    String? classId,
  }) async {
    return getStudentStats(
      studentId: studentId,
      timeFilter: TimeFilter.thisWeek,
      classId: classId,
    );
  }

  @override
  Future<WeeklyStatsModel> getStudentStats({
    required String studentId,
    TimeFilter timeFilter = TimeFilter.thisWeek,
    String? classId,
    bool forceRefresh = false,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidDateRangeException(
        userMessage: 'El ID del estudiante es obligatorio',
      );
    }

    final activeFilter = timeFilter;
    final cacheKey = '${sanitizedId}_${activeFilter.name}_${classId ?? "all"}';

    if (!forceRefresh) {
      final cached = _studentStatsCache[cacheKey];
      if (cached != null && !cached.isExpired(_cacheTtl)) {
        log(
          'StatisticsRepositoryImpl: Cache HIT para $cacheKey',
          name: 'StatisticsRepositoryImpl',
        );
        return cached.stats;
      }
    } else {
      _studentStatsCache.remove(cacheKey);
    }

    try {
      log(
        'StatisticsRepositoryImpl: Cache MISS para $cacheKey. Consultando Firestore...',
        name: 'StatisticsRepositoryImpl',
      );

      final stats = await _statisticsService.getStudentStats(
        studentId: sanitizedId,
        timeFilter: timeFilter,
        classId: classId,
      );

      _studentStatsCache[cacheKey] = CachedStats(
        stats: stats,
        timestamp: DateTime.now(),
      );

      return stats;
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getStudentStats',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<DailyStatsModel> getMonthlyStats({
    required String studentId,
    required int month,
    required int year,
    String? classId,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidDateRangeException(
        userMessage: 'El ID del estudiante es obligatorio',
      );
    }

    if (month < 1 || month > 12) {
      throw const InvalidDateRangeException(userMessage: '');
    }

    if (year < 2000 || year > 2100) {
      throw const InvalidDateRangeException(userMessage: '');
    }

    try {
      return await _statisticsService.getMonthlyStats(
        studentId: sanitizedId,
        month: month,
        year: year,
        classId: classId,
      );
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getMonthlyStats',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<TaskStatsModel> getTaskStats({
    required String taskId,
    String? studentId,
  }) async {
    final sanitizedTaskId = taskId.trim();
    if (sanitizedTaskId.isEmpty) {
      throw const ResourceNotFoundException(
        resourceType: 'Task',
        resourceId: '',
        userMessage: '',
      );
    }

    try {
      return await _statisticsService.getTaskStats(
        taskId: sanitizedTaskId,
        studentId: studentId,
      );
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getTaskStats',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ClassStatsModel> getClassStats({
    required String classId,
    required String teacherId,
    TimeFilter? timeFilter,
    bool forceRefresh = false,
  }) async {
    final sanitizedClassId = classId.trim();
    final sanitizedTeacherId = teacherId.trim();

    if (sanitizedClassId.isEmpty) {
      throw const ResourceNotFoundException(
        resourceType: 'Class',
        resourceId: '',
        userMessage: '',
      );
    }

    if (sanitizedTeacherId.isEmpty) {
      throw const PermissionDeniedException(userMessage: '');
    }

    final activeFilter = timeFilter ?? TimeFilter.thisWeek;
    final cacheKey = '${sanitizedClassId}_${activeFilter.name}';

    // ① Consultar caché si no se fuerza el refresco
    if (!forceRefresh) {
      final cached = _classStatsCache[cacheKey];
      if (cached != null && !cached.isExpired(_cacheTtl)) {
        log(
          'StatisticsRepositoryImpl: Cache HIT para $cacheKey',
          name: 'StatisticsRepositoryImpl',
        );
        return cached.stats;
      }
    } else {
      // Invalidar solo la entrada de este filtro
      _classStatsCache.remove(cacheKey);
    }

    try {
      log(
        'StatisticsRepositoryImpl: Cache MISS para $cacheKey. Consultando Firestore…',
        name: 'StatisticsRepositoryImpl',
      );

      final stats = await _statisticsService.getClassStats(
        classId: sanitizedClassId,
        teacherId: sanitizedTeacherId,
        timeFilter: activeFilter,
      );

      // ② Guardar en caché
      _classStatsCache[cacheKey] = CachedStats(
        stats: stats,
        timestamp: DateTime.now(),
      );

      return stats;
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getClassStats',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<StudentProgressModel> getStudentProgress({
    required String studentId,
    bool forceRefresh = false,
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw const ResourceNotFoundException(
        resourceType: 'Student',
        resourceId: '',
        userMessage: '',
      );
    }

    final cacheKey = sanitizedId;

    if (!forceRefresh) {
      final cached = _studentProgressCache[cacheKey];
      if (cached != null && !cached.isExpired(_cacheTtl)) {
        log(
          'StatisticsRepositoryImpl: Cache HIT (progress) para $cacheKey',
          name: 'StatisticsRepositoryImpl',
        );
        return cached.stats;
      }
    } else {
      _studentProgressCache.remove(cacheKey);
    }

    try {
      log(
        'StatisticsRepositoryImpl: Calculando progreso para estudiante $sanitizedId',
        name: 'StatisticsRepositoryImpl',
      );

      // 1. Obtener datos del estudiante desde Firestore
      final studentDoc = await _firestore
          .collection('students')
          .doc(sanitizedId)
          .get();

      if (!studentDoc.exists) {
        throw const ResourceNotFoundException(
          resourceType: 'Student',
          resourceId: '',
          userMessage: '',
        );
      }

      final studentData = studentDoc.data()!;
      final firstName = studentData['firstName'] as String? ?? '';
      final lastName = studentData['lastName'] as String? ?? '';
      final studentName = '$firstName $lastName';

      final totalDurationLogged =
          studentData['totalDurationLogged'] as int? ?? 0;
      final totalSessionsCount = studentData['totalSessionsCount'] as int? ?? 0;
      final lastSessionTimestamp = studentData['lastSessionDate'] as Timestamp?;

      // 2. Obtener asignaciones del estudiante
      final assignmentsSnapshot = await _firestore
          .collection('assignments')
          .where('studentId', isEqualTo: sanitizedId)
          .get();

      final totalTasks = assignmentsSnapshot.docs.length;
      final completedTasks = assignmentsSnapshot.docs
          .where((doc) => (doc.data()['status'] as String?) == 'completed')
          .length;

      // 3. Calcular rachas de forma eficiente (Batch Fetching)
      final streakMetrics = await _getStreakMetrics(sanitizedId);
      final currentStreak = streakMetrics.current;
      final longestStreak = streakMetrics.longest;

      // 4. Calcular promedio por sesión
      final averageSessionDuration = totalSessionsCount > 0
          ? (totalDurationLogged / totalSessionsCount).round()
          : 0;

      final progress = StudentProgressModel(
        studentId: sanitizedId,
        studentName: studentName,
        totalDuration: totalDurationLogged,
        totalSessions: totalSessionsCount,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastSessionDate: lastSessionTimestamp,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        averageSessionDuration: averageSessionDuration,
      );

      _studentProgressCache[cacheKey] = CachedStats(
        stats: progress,
        timestamp: DateTime.now(),
      );

      return progress;
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getStudentProgress',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Obtiene las métricas de racha (actual y máxima) en una sola consulta de lote.
  /// Esto optimiza las lecturas de Firestore drásticamente en comparación con bucles.
  Future<({int current, int longest})> _getStreakMetrics(
    String studentId,
  ) async {
    try {
      // 1. Obtener las fechas de los últimos registros (ej: los últimos registros de actividad)
      final sessionsSnapshot = await _firestore
          .collection('sessions')
          .where('studentId', isEqualTo: studentId)
          .orderBy('dateLogged', descending: true)
          .limit(
            200,
          ) // Límite razonable para calcular rachas sin denormalización
          .get();

      if (sessionsSnapshot.docs.isEmpty) return (current: 0, longest: 0);

      // 2. Extraer fechas únicas (sin hora) en orden descendente
      final practiceDates =
          sessionsSnapshot.docs
              .map((doc) => (doc.data()['dateLogged'] as Timestamp).toDate())
              .map((date) => DateTime(date.year, date.month, date.day))
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));

      if (practiceDates.isEmpty) return (current: 0, longest: 0);

      // 3. Variables para el cálculo
      int currentStreak = 0;
      int maxStreak = 0;
      int tempStreak = 1;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      // 4. Calcular racha actual (solo si hubo práctica hoy o ayer)
      if (!practiceDates.first.isBefore(yesterday)) {
        currentStreak = 1;
        for (int i = 0; i < practiceDates.length - 1; i++) {
          if (practiceDates[i].difference(practiceDates[i + 1]).inDays == 1) {
            currentStreak++;
          } else {
            break;
          }
        }
      }

      // 5. Calcular racha máxima histórica (dentro de los datos recuperados)
      maxStreak = 1;
      for (int i = 0; i < practiceDates.length - 1; i++) {
        if (practiceDates[i].difference(practiceDates[i + 1]).inDays == 1) {
          tempStreak++;
        } else {
          if (tempStreak > maxStreak) maxStreak = tempStreak;
          tempStreak = 1;
        }
      }
      if (tempStreak > maxStreak) maxStreak = tempStreak;

      return (current: currentStreak, longest: maxStreak);
    } catch (e) {
      log(
        'Error calculating streak metrics: $e',
        name: 'StatisticsRepositoryImpl',
      );
      return (current: 0, longest: 0);
    }
  }

  @override
  Future<List<StudentClassStatsModel>> getStudentsClassStats({
    required String classId,
    required String teacherId,
    TimeFilter timeFilter = TimeFilter.thisWeek,
    bool forceRefresh = false,
  }) async {
    final sanitizedClassId = classId.trim();
    final activeFilter = timeFilter;
    final cacheKey = 'students_${sanitizedClassId}_${activeFilter.name}';

    if (!forceRefresh) {
      final cached = _studentsClassStatsCache[cacheKey];
      if (cached != null && !cached.isExpired(_cacheTtl)) {
        log(
          'StatisticsRepositoryImpl: Cache HIT para $cacheKey',
          name: 'StatisticsRepositoryImpl',
        );
        return cached.stats;
      }
    } else {
      _studentsClassStatsCache.remove(cacheKey);
    }

    try {
      log(
        'StatisticsRepositoryImpl: Cache MISS para $cacheKey. Consultando Firestore…',
        name: 'StatisticsRepositoryImpl',
      );
      final stats = await _statisticsService.getStudentsClassStats(
        classId: sanitizedClassId,
        teacherId: teacherId,
        timeFilter: activeFilter,
      );
      _studentsClassStatsCache[cacheKey] = CachedStats(
        stats: stats,
        timestamp: DateTime.now(),
      );
      return stats;
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getStudentsClassStats',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Mapea errores a excepciones de dominio
  Never _throwRepositoryException({
    required String method,
    required Object error,
    required StackTrace stackTrace,
  }) {
    log(
      'StatisticsRepositoryImpl#$method error',
      error: error,
      stackTrace: stackTrace,
    );

    // Re-lanzar excepciones de estadísticas
    if (error is StatisticsException) {
      throw error;
    }

    // Mapear excepciones de Firebase
    if (error is FirebaseErrorMapperException) {
      throw StatisticsServiceException(userMessage: '', message: error.message);
    }

    // Excepciones genéricas
    throw const StatisticsServiceException(
      userMessage: '',
      message: 'Unknown error occurred',
    );
  }
}

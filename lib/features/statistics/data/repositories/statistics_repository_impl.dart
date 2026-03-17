import 'dart:developer';

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
/// excepciones de dominio.
final class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl({StatisticsService? statisticsService})
    : _statisticsService = statisticsService ?? StatisticsService();

  final StatisticsService _statisticsService;

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

      final progress = await _statisticsService.getStudentProgress(
        studentId: sanitizedId,
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

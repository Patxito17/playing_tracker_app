import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/statistics/data/services/statistics_service.dart';
import 'package:playing_tracker/features/statistics/domain/exceptions/statistics_exception.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/daily_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';

/// Implementación concreta del [StatisticsRepository].
///
/// Orquesta el [StatisticsService] y mapea errores de Firestore a
/// excepciones de dominio con mensajes en español desde [StatisticsStrings].
final class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl({StatisticsService? statisticsService})
    : _statisticsService = statisticsService ?? StatisticsService();

  final StatisticsService _statisticsService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<DailyStatsModel> getDailyStats({
    required String studentId,
    required DateTime date,
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
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidDateRangeException(
        userMessage: 'El ID del estudiante es obligatorio',
      );
    }

    try {
      return await _statisticsService.getWeeklyStats(
        studentId: sanitizedId,
        weekStart: weekStart,
      );
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getWeeklyStats',
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
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidDateRangeException(
        userMessage: 'El ID del estudiante es obligatorio',
      );
    }

    if (month < 1 || month > 12) {
      throw const InvalidDateRangeException(
        userMessage: StatisticsStrings.invalidDateRangeError,
      );
    }

    if (year < 2000 || year > 2100) {
      throw const InvalidDateRangeException(
        userMessage: StatisticsStrings.invalidDateRangeError,
      );
    }

    try {
      return await _statisticsService.getMonthlyStats(
        studentId: sanitizedId,
        month: month,
        year: year,
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
        userMessage: StatisticsStrings.resourceNotFoundError,
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
  }) async {
    final sanitizedClassId = classId.trim();
    final sanitizedTeacherId = teacherId.trim();

    if (sanitizedClassId.isEmpty) {
      throw const ResourceNotFoundException(
        resourceType: 'Class',
        resourceId: '',
        userMessage: StatisticsStrings.resourceNotFoundError,
      );
    }

    if (sanitizedTeacherId.isEmpty) {
      throw const PermissionDeniedException(
        userMessage: StatisticsStrings.permissionDeniedError,
      );
    }

    try {
      return await _statisticsService.getClassStats(
        classId: sanitizedClassId,
        teacherId: sanitizedTeacherId,
      );
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
  }) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      throw const ResourceNotFoundException(
        resourceType: 'Student',
        resourceId: '',
        userMessage: StatisticsStrings.resourceNotFoundError,
      );
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
          userMessage: StatisticsStrings.resourceNotFoundError,
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

      // 3. Calcular rachas (simplificado - en producción usar lógica más compleja)
      final currentStreak = await _calculateCurrentStreak(sanitizedId);
      final longestStreak = await _calculateLongestStreak(sanitizedId);

      // 4. Calcular promedio por sesión
      final averageSessionDuration = totalSessionsCount > 0
          ? (totalDurationLogged / totalSessionsCount).round()
          : 0;

      return StudentProgressModel(
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
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getStudentProgress',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calcula la racha actual de días consecutivos con práctica
  Future<int> _calculateCurrentStreak(String studentId) async {
    try {
      final now = DateTime.now();
      int streak = 0;

      // Revisar los últimos 365 días (límite razonable)
      for (int i = 0; i < 365; i++) {
        final checkDate = now.subtract(Duration(days: i));
        final stats = await _statisticsService.getDailyStats(
          studentId: studentId,
          date: checkDate,
        );

        if (stats.totalSessions > 0) {
          streak++;
        } else {
          // Si no hay sesiones, la racha se rompe
          if (i == 0) {
            // Si hoy no hay práctica, racha es 0
            return 0;
          }
          break;
        }
      }

      return streak;
    } catch (e) {
      log(
        'Error calculating current streak: $e',
        name: 'StatisticsRepositoryImpl',
      );
      return 0;
    }
  }

  /// Calcula la racha más larga de días consecutivos
  Future<int> _calculateLongestStreak(String studentId) async {
    // En una implementación real, esto debería estar pre-calculado
    // o almacenado como agregado en el documento del estudiante
    // Por ahora, retornamos un valor conservador
    return 0;
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
      throw StatisticsServiceException(
        userMessage: StatisticsStrings.statisticsServiceError,
        message: error.message,
      );
    }

    // Excepciones genéricas
    throw const StatisticsServiceException(
      userMessage: StatisticsStrings.statisticsGenericError,
      message: 'Unknown error occurred',
    );
  }
}

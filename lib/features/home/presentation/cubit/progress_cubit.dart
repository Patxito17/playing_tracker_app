import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';

import 'progress_state.dart';

/// Cubit que gestiona y transforma los datos de sesiones y tareas en progreso semanal dinámico.
class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({
    required SessionRepository sessionRepository,
    required TaskRepository taskRepository,
  }) : _sessionRepository = sessionRepository,
       _taskRepository = taskRepository,
       super(const ProgressInitial());

  final SessionRepository _sessionRepository;
  final TaskRepository _taskRepository;

  StreamSubscription<List<SessionModel>>? _sessionsSubscription;
  StreamSubscription<List<AssignmentModel>>? _tasksSubscription;

  List<SessionModel>? _currentSessions;
  List<AssignmentModel>? _currentAssignments;
  bool _hasError = false;

  /// Inicia la observación del progreso semanal de un estudiante.
  void watchProgress(String studentId) {
    _hasError = false;
    _currentSessions = null;
    _currentAssignments = null;

    emit(const ProgressLoading());

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeek = startOfDay.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    _sessionsSubscription?.cancel();
    _sessionsSubscription = _sessionRepository
        .watchWeeklySessions(
          studentId: studentId,
          startDate: startOfDay,
          endDate: endOfWeek,
        )
        .listen(
          (sessions) {
            _currentSessions = sessions;
            _calculateAndEmitProgress(startOfDay, endOfWeek);
          },
          onError: (error) {
            _hasError = true;
            emit(ProgressError(error.toString()));
          },
        );

    _tasksSubscription?.cancel();
    _tasksSubscription = _taskRepository
        .watchStudentAssignments(studentId)
        .listen(
          (assignments) {
            _currentAssignments = assignments;
            _calculateAndEmitProgress(startOfDay, endOfWeek);
          },
          onError: (error) {
            _hasError = true;
            emit(ProgressError(error.toString()));
          },
        );
  }

  void _calculateAndEmitProgress(DateTime startOfWeek, DateTime endOfWeek) {
    if (_hasError) return;

    // Solo emitimos si tenemos datos de ambos (o al menos han emitido [] una vez)
    if (_currentSessions == null || _currentAssignments == null) return;

    final sessions = _currentSessions!;
    final assignments = _currentAssignments!;

    // 1. Calcular Meta Semanal Dinámica
    final weeklyTasks = assignments.where((a) {
      if (!a.isActive) return false;

      final assignedAt = a.assignedAt.toDate();
      final dueDate = a.dueDate?.toDate();
      final completedAt = a.completedAt?.toDate();

      final isAssignedThisWeek =
          assignedAt.isAfter(
            startOfWeek.subtract(const Duration(seconds: 1)),
          ) &&
          assignedAt.isBefore(endOfWeek.add(const Duration(seconds: 1)));

      final isDueThisWeek =
          dueDate != null &&
          dueDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          dueDate.isBefore(endOfWeek.add(const Duration(seconds: 1)));

      final isCompletedThisWeek =
          completedAt != null &&
          completedAt.isAfter(
            startOfWeek.subtract(const Duration(seconds: 1)),
          ) &&
          completedAt.isBefore(endOfWeek.add(const Duration(seconds: 1)));

      final shouldInclude =
          isAssignedThisWeek ||
          isDueThisWeek ||
          a.isInProgress ||
          isCompletedThisWeek;

      if (shouldInclude) {
        print(
          'ProgressCubit: [DEBUG] Incluyendo tarea: ${a.taskId} - Duración: ${a.durationSuggested}s - Status: ${a.status}',
        );
      }

      return shouldInclude;
    }).toList();

    int weeklyGoalSeconds = 0;
    for (final task in weeklyTasks) {
      weeklyGoalSeconds += (task.durationSuggested ?? 0);
    }

    print(
      'ProgressCubit: [DEBUG] Suma de duraciones sugeridas: $weeklyGoalSeconds s (${weeklyGoalSeconds / 60} min)',
    );

    // Solo aplicamos fallback si NO hay tareas asignadas para esta semana
    if (weeklyGoalSeconds == 0 && weeklyTasks.isEmpty) {
      print(
        'ProgressCubit: [DEBUG] Sin tareas semanales. Aplicando fallback de 30 min (1800s)',
      );
      weeklyGoalSeconds = 1800;
    } else if (weeklyGoalSeconds < 60) {
      // Si la meta es ridículamente baja (menos de 1 min), ponemos 1 min para evitar problemas
      weeklyGoalSeconds = 60;
    }

    // 2. Agrupar Sesiones por Día
    final dailySeconds = List<int>.filled(7, 0);
    int totalWeeklySeconds = 0;

    print(
      'ProgressCubit: [DEBUG] Rango de sesiones: $startOfWeek a $endOfWeek',
    );
    for (final session in sessions) {
      final date = session.dateLogged.toDate();
      final weekday = date.weekday;
      dailySeconds[weekday - 1] += session.totalDuration;
      totalWeeklySeconds += session.totalDuration;
      print(
        'ProgressCubit: [DEBUG] -> Sesión: ${session.id} - Fecha: $date - Duración: ${session.totalDuration}s',
      );
    }

    print(
      'ProgressCubit: [DEBUG] Total practicado esta semana: $totalWeeklySeconds s (${totalWeeklySeconds / 60} min)',
    );

    // 3. Normalizar para el gráfico (escala visual)
    // El dailyGoal es el objetivo diario sugerido (1/7 de la meta semanal)
    final dailyGoalSeconds = (weeklyGoalSeconds / 7).clamp(300.0, 3600.0);
    final dailyValues = dailySeconds
        .map((s) => (s / dailyGoalSeconds).clamp(0.0, 1.0))
        .toList();

    // 4. Calcular Porcentaje Total
    final double weeklyPercentage =
        (totalWeeklySeconds / weeklyGoalSeconds * 100).clamp(0.0, 100.0);

    print(
      'ProgressCubit: [DEBUG] Meta: $weeklyGoalSeconds s | Practicado: $totalWeeklySeconds s | Porcentaje: $weeklyPercentage%',
    );

    emit(
      ProgressLoaded(
        dailyValues: dailyValues,
        weeklyPercentage: weeklyPercentage,
        totalDurationSeconds: totalWeeklySeconds,
      ),
    );
  }

  @override
  Future<void> close() {
    _sessionsSubscription?.cancel();
    _tasksSubscription?.cancel();
    return super.close();
  }
}

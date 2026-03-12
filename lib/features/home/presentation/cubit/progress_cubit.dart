import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';

import 'progress_state.dart';

/// Cubit que gestiona y transforma los datos de sesiones en progreso semanal.
class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._sessionRepository) : super(const ProgressInitial());

  final SessionRepository _sessionRepository;
  StreamSubscription<List<SessionModel>>? _subscription;

  /// Inicia la observación del progreso semanal de un estudiante.
  void watchProgress(String studentId) {
    emit(const ProgressLoading());

    final now = DateTime.now();
    // Obtener el lunes de la semana actual
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    // Obtener el domingo de la semana actual (al final del día)
    final endOfWeek = startOfDay.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    _subscription?.cancel();
    _subscription = _sessionRepository
        .watchWeeklySessions(
          studentId: studentId,
          startDate: startOfDay,
          endDate: endOfWeek,
        )
        .listen(
          (sessions) => _onSessionsUpdated(sessions),
          onError: (error) => emit(ProgressError(error.toString())),
        );
  }

  void _onSessionsUpdated(List<SessionModel> sessions) {
    // Inicializar 7 días (L-D) con 0 segundos
    final dailySeconds = List<int>.filled(7, 0);
    int totalWeeklySeconds = 0;

    for (final session in sessions) {
      final weekday = session.dateLogged.toDate().weekday; // 1 (Lun) a 7 (Dom)
      dailySeconds[weekday - 1] += session.totalDuration;
      totalWeeklySeconds += session.totalDuration;
    }

    // Normalizar valores para el gráfico (ej. el día con más práctica es 1.0, o basado en un objetivo diario)
    // Para simplificar, normalizaremos respecto a un "objetivo diario" de 1 hora (3600s)
    const dailyGoalSeconds = 3600; 
    final dailyValues = dailySeconds.map((s) => (s / dailyGoalSeconds).clamp(0.0, 1.0)).toList();

    // Calcular porcentaje semanal basado en un objetivo de 5 horas a la semana
    const weeklyGoalSeconds = 5 * 3600;
    final weeklyPercentage = (totalWeeklySeconds / weeklyGoalSeconds * 100).clamp(0.0, 100.0);

    emit(ProgressLoaded(
      dailyValues: dailyValues,
      weeklyPercentage: weeklyPercentage,
      totalDurationSeconds: totalWeeklySeconds,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

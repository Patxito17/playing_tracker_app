import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';

/// Estados del Cubit de estadísticas del alumno
sealed class StudentStatsState extends Equatable {
  const StudentStatsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
final class StudentStatsInitial extends StudentStatsState {
  const StudentStatsInitial();
}

/// Estado de carga
final class StudentStatsLoading extends StudentStatsState {
  const StudentStatsLoading();
}

/// Estado de éxito con datos cargados
final class StudentStatsLoaded extends StudentStatsState {
  const StudentStatsLoaded({required this.progress, required this.weeklyStats});

  final StudentProgressModel progress;
  final WeeklyStatsModel weeklyStats;

  @override
  List<Object?> get props => [progress, weeklyStats];
}

/// Estado de error
final class StudentStatsError extends StudentStatsState {
  const StudentStatsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

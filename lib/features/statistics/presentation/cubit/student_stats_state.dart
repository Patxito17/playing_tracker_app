import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';

/// Estados del Cubit de estadísticas del alumno.
sealed class StudentStatsState extends Equatable {
  const StudentStatsState({required this.timeFilter});

  final TimeFilter timeFilter;

  @override
  List<Object?> get props => [timeFilter];
}

/// Estado inicial.
final class StudentStatsInitial extends StudentStatsState {
  const StudentStatsInitial() : super(timeFilter: TimeFilter.thisWeek);
}

/// Estado de carga.
final class StudentStatsLoading extends StudentStatsState {
  const StudentStatsLoading({
    required super.timeFilter,
    this.progress,
    this.weeklyStats,
  });

  final StudentProgressModel? progress;
  final WeeklyStatsModel? weeklyStats;

  @override
  List<Object?> get props => [timeFilter, progress, weeklyStats];
}

/// Estado de éxito con datos cargados.
final class StudentStatsLoaded extends StudentStatsState {
  const StudentStatsLoaded({
    required super.timeFilter,
    required this.progress,
    required this.weeklyStats,
  });

  final StudentProgressModel progress;
  final WeeklyStatsModel weeklyStats;

  @override
  List<Object?> get props => [timeFilter, progress, weeklyStats];
}

/// Estado de error.
final class StudentStatsError extends StudentStatsState {
  const StudentStatsError({
    required super.timeFilter,
    required this.message,
    this.progress,
    this.weeklyStats,
  });

  final String message;
  final StudentProgressModel? progress;
  final WeeklyStatsModel? weeklyStats;

  @override
  List<Object?> get props => [timeFilter, message, progress, weeklyStats];
}

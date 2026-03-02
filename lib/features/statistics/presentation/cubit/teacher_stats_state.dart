import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';

/// Estados del Cubit de estadísticas del docente.
///
/// Maneja el flujo de carga de estadísticas de una clase específica
/// para la vista del docente, ahora integrando un filtro de tiempo.
sealed class TeacherStatsState extends Equatable {
  const TeacherStatsState({required this.timeFilter});

  final TimeFilter timeFilter;

  @override
  List<Object?> get props => [timeFilter];
}

/// Estado inicial antes de cargar datos.
final class TeacherStatsInitial extends TeacherStatsState {
  const TeacherStatsInitial() : super(timeFilter: TimeFilter.thisWeek);
}

/// Estado de carga mientras se obtienen las estadísticas.
final class TeacherStatsLoading extends TeacherStatsState {
  const TeacherStatsLoading({required super.timeFilter, this.classStats});

  final ClassStatsModel? classStats;

  @override
  List<Object?> get props => [timeFilter, classStats];
}

/// Estado exitoso con las estadísticas de la clase cargadas.
class TeacherStatsLoaded extends TeacherStatsState {
  const TeacherStatsLoaded({
    required super.timeFilter,
    required this.classStats,
  });

  final ClassStatsModel classStats;

  @override
  List<Object?> get props => [timeFilter, classStats];
}

/// Estado de error al cargar estadísticas.
class TeacherStatsError extends TeacherStatsState {
  const TeacherStatsError({
    required super.timeFilter,
    required this.message,
    this.classStats,
  });

  final String message;
  final ClassStatsModel? classStats;

  @override
  List<Object?> get props => [timeFilter, message, classStats];
}

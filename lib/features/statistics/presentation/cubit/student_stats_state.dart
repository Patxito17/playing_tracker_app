import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';

/// Estados del Cubit de estadísticas del alumno.
///
/// Todos los estados llevan el [timeFilter] activo para que la UI pueda
/// mostrar el selector de filtros correctamente incluso durante la carga.
sealed class StudentStatsState extends Equatable {
  const StudentStatsState({required this.timeFilter});

  /// Filtro de tiempo activo en el momento de emitir este estado.
  final TimeFilter timeFilter;

  @override
  List<Object?> get props => [timeFilter];
}

/// Estado inicial.
final class StudentStatsInitial extends StudentStatsState {
  const StudentStatsInitial() : super(timeFilter: TimeFilter.thisWeek);
}

/// Estado de carga mientras se obtienen las estadísticas del alumno.
///
/// Lleva los datos anteriores ([progress] y [weeklyStats]) para que la UI
/// pueda mostrarlos mientras carga, evitando parpadeos.
final class StudentStatsLoading extends StudentStatsState {
  const StudentStatsLoading({
    required super.timeFilter,
    this.progress,
    this.weeklyStats,
  });

  /// Datos de progreso de la carga anterior (pueden ser null en la primera carga).
  final StudentProgressModel? progress;

  /// Estadísticas semanales de la carga anterior (pueden ser null en la primera carga).
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

  /// Progreso global del alumno (racha, totales acumulados, etc.).
  final StudentProgressModel progress;

  /// Estadísticas del periodo activo (sesiones, duración, desglose diario).
  final WeeklyStatsModel weeklyStats;

  @override
  List<Object?> get props => [timeFilter, progress, weeklyStats];
}

/// Estado de error al cargar estadísticas.
///
/// Conserva los datos de la última carga exitosa para que la UI pueda
/// mostrar datos obsoletos junto con el mensaje de error.
final class StudentStatsError extends StudentStatsState {
  const StudentStatsError({
    required super.timeFilter,
    required this.message,
    this.progress,
    this.weeklyStats,
  });

  /// Mensaje de error legible para mostrar en la UI.
  final String message;

  /// Últimos datos de progreso disponibles antes del error (pueden ser null).
  final StudentProgressModel? progress;

  /// Últimas estadísticas semanales disponibles antes del error (pueden ser null).
  final WeeklyStatsModel? weeklyStats;

  @override
  List<Object?> get props => [timeFilter, message, progress, weeklyStats];
}

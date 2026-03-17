import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';

/// Estados del Cubit de estadísticas del docente.
///
/// Maneja el flujo de carga de estadísticas de una clase específica para la
/// vista del docente, incluyendo estadísticas agregadas y ranking individual.
/// Todos los estados llevan el [timeFilter] activo para mantener el selector
/// de filtros visible durante la carga.
sealed class TeacherStatsState extends Equatable {
  const TeacherStatsState({required this.timeFilter});

  /// Filtro de tiempo activo en el momento de emitir este estado.
  final TimeFilter timeFilter;

  @override
  List<Object?> get props => [timeFilter];
}

/// Estado inicial antes de cargar datos.
final class TeacherStatsInitial extends TeacherStatsState {
  const TeacherStatsInitial() : super(timeFilter: TimeFilter.thisWeek);
}

/// Estado de carga mientras se obtienen las estadísticas.
///
/// Conserva los datos anteriores para evitar parpadeos en la UI durante
/// cambios de filtro.
final class TeacherStatsLoading extends TeacherStatsState {
  const TeacherStatsLoading({
    required super.timeFilter,
    this.classStats,
    this.studentsStats,
  });

  /// Estadísticas de clase de la carga anterior (pueden ser null en la primera carga).
  final ClassStatsModel? classStats;

  /// Ranking de alumnos de la carga anterior (pueden ser null en la primera carga).
  final List<StudentClassStatsModel>? studentsStats;

  @override
  List<Object?> get props => [timeFilter, classStats, studentsStats];
}

/// Estado exitoso con las estadísticas de la clase cargadas.
class TeacherStatsLoaded extends TeacherStatsState {
  const TeacherStatsLoaded({
    required super.timeFilter,
    required this.classStats,
    required this.studentsStats,
  });

  /// Estadísticas agregadas de la clase (total de alumnos, duración, sesiones).
  final ClassStatsModel classStats;

  /// Ranking de alumnos ordenado por duración total descendente.
  final List<StudentClassStatsModel> studentsStats;

  @override
  List<Object?> get props => [timeFilter, classStats, studentsStats];
}

/// Estado de error al cargar estadísticas.
class TeacherStatsError extends TeacherStatsState {
  const TeacherStatsError({
    required super.timeFilter,
    required this.message,
    this.classStats,
    this.studentsStats,
  });

  /// Mensaje de error legible para mostrar en la UI.
  final String message;

  /// Estadísticas de clase disponibles antes del error, si las hay.
  final ClassStatsModel? classStats;

  /// Ranking de alumnos disponible antes del error, si lo hay.
  final List<StudentClassStatsModel>? studentsStats;

  @override
  List<Object?> get props => [timeFilter, message, classStats, studentsStats];
}

import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';

/// Estados del Cubit de estadísticas del docente.
///
/// Maneja el flujo de carga de estadísticas de una clase específica
/// para la vista del docente.
sealed class TeacherStatsState extends Equatable {
  const TeacherStatsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de cargar datos.
final class TeacherStatsInitial extends TeacherStatsState {
  const TeacherStatsInitial();
}

/// Estado de carga mientras se obtienen las estadísticas.
final class TeacherStatsLoading extends TeacherStatsState {
  const TeacherStatsLoading();
}

/// Estado exitoso con las estadísticas de la clase cargadas.
final class TeacherStatsLoaded extends TeacherStatsState {
  const TeacherStatsLoaded({required this.classStats});

  final ClassStatsModel classStats;

  @override
  List<Object?> get props => [classStats];
}

/// Estado de error al cargar estadísticas.
final class TeacherStatsError extends TeacherStatsState {
  const TeacherStatsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

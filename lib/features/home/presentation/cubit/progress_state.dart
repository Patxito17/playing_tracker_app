import 'package:equatable/equatable.dart';

/// Estados para el progreso semanal del estudiante.
sealed class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del progreso.
final class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

/// Cargando datos de progreso.
final class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

/// Datos de progreso cargados exitosamente.
final class ProgressLoaded extends ProgressState {
  const ProgressLoaded({
    required this.dailyValues,
    required this.weeklyPercentage,
    required this.totalDurationSeconds,
  });

  /// Valores normalizados (0.0 a 1.0) para cada día de la semana (7 elementos).
  final List<double> dailyValues;

  /// Porcentaje de progreso comparado con un objetivo o promedio (0.0 a 100.0).
  final double weeklyPercentage;

  /// Duración total en segundos de la semana actual.
  final int totalDurationSeconds;

  @override
  List<Object?> get props => [dailyValues, weeklyPercentage, totalDurationSeconds];
}

/// Error al cargar el progreso.
final class ProgressError extends ProgressState {
  const ProgressError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';

/// Posibles estados de la pantalla de historial de sesiones
sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del historial
final class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

/// Estado de carga del historial
final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Estado de éxito al cargar el historial
final class HistorySuccess extends HistoryState {
  const HistorySuccess({required this.sessions, this.taskId, this.studentId});

  final List<SessionModel> sessions;
  final String? taskId;
  final String? studentId;

  @override
  List<Object?> get props => [sessions, taskId, studentId];
}

/// Estado de historial vacío
final class HistoryEmpty extends HistoryState {
  const HistoryEmpty();
}

/// Estado de error al cargar el historial
final class HistoryError extends HistoryState {
  const HistoryError({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

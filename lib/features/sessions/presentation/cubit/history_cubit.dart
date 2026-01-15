import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';
import 'package:playing_tracker/features/sessions/presentation/cubit/history_state.dart';

/// Cubit encargado de gestionar la lógica del historial de sesiones.
final class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._repository) : super(const HistoryInitial());

  final SessionRepository _repository;
  StreamSubscription? _sessionsSubscription;

  /// Observa las sesiones de un estudiante, opcionalmente filtradas por tarea.
  Future<void> watchSessions({
    required String studentId,
    String? taskId,
    int? limit,
  }) async {
    emit(const HistoryLoading());
    await _sessionsSubscription?.cancel();

    if (taskId != null && taskId.isNotEmpty) {
      _sessionsSubscription = _repository
          .watchTaskSessions(
            taskId: taskId,
            studentId: studentId,
            limit: limit ?? 0,
          )
          .listen(
            (sessions) => _handleSessions(sessions, studentId, taskId),
            onError: _handleError,
          );
    } else {
      _sessionsSubscription = _repository
          .watchStudentSessions(studentId: studentId, limit: limit ?? 0)
          .listen(
            (sessions) => _handleSessions(sessions, studentId, null),
            onError: _handleError,
          );
    }
  }

  void _handleSessions(
    List<dynamic> sessions,
    String studentId,
    String? taskId,
  ) {
    if (sessions.isEmpty) {
      emit(const HistoryEmpty());
      return;
    }

    emit(
      HistorySuccess(
        sessions: List.unmodifiable(sessions),
        studentId: studentId,
        taskId: taskId,
      ),
    );
  }

  void _handleError(dynamic error) {
    if (error is SessionRepositoryException) {
      emit(HistoryError(message: error.message, cause: error));
    } else {
      emit(
        const HistoryError(
          message: 'Ocurrió un error inesperado al cargar el historial',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _sessionsSubscription?.cancel();
    return super.close();
  }
}

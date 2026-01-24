import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/sessions/data/services/session_service.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';

/// Implementación concreta de [SessionRepository] que orquesta el servicio de
/// sesiones respetando la arquitectura Domain → Repository → Service.
final class SessionRepositoryImpl implements SessionRepository {
  /// Crea una instancia con dependencias inyectables para facilitar las pruebas.
  SessionRepositoryImpl({SessionServiceContract? sessionService})
    : _sessionService = sessionService ?? SessionService();

  final SessionServiceContract _sessionService;

  @override
  Future<void> createSession(SessionModel session) async {
    // Validaciones básicas
    if (session.id.trim().isEmpty) {
      throw const InvalidSessionArgumentException(
        'El identificador de la sesión es obligatorio',
      );
    }
    if (session.studentId.trim().isEmpty) {
      throw const InvalidSessionArgumentException(
        'El identificador del estudiante es obligatorio',
      );
    }
    if (session.taskId.trim().isEmpty) {
      throw const InvalidSessionArgumentException(
        'El identificador de la tarea es obligatorio',
      );
    }
    if (session.totalDuration < 0) {
      throw const InvalidSessionArgumentException(
        'La duración total no puede ser negativa',
      );
    }
    if (session.pausedDuration < 0) {
      throw const InvalidSessionArgumentException(
        'La duración de pausa no puede ser negativa',
      );
    }

    try {
      await _sessionService.createSession(session);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'createSession',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible guardar la sesión de práctica.',
      );
    }
  }

  @override
  Future<SessionModel?> getSessionById(String sessionId) async {
    final sanitizedId = sessionId.trim();
    if (sanitizedId.isEmpty) {
      throw const InvalidSessionArgumentException(
        'El identificador de la sesión es obligatorio',
      );
    }

    try {
      return await _sessionService.getSessionById(sanitizedId);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getSessionById',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible obtener la sesión solicitada.',
      );
    }
  }

  @override
  Stream<List<SessionModel>> watchStudentSessions({
    required String studentId,
    int limit = _defaultPaginationLimit,
  }) {
    final normalizedId = studentId.trim();
    if (normalizedId.isEmpty) {
      return Stream<List<SessionModel>>.error(
        const InvalidSessionArgumentException(
          'El identificador del estudiante es obligatorio',
        ),
      );
    }

    final stream = _sessionService.watchStudentSessions(
      studentId: normalizedId,
      limit: limit,
    );

    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (sessions, sink) => sink.add(sessions),
        handleError: (error, stackTrace, sink) {
          final mapped = _mapToRepositoryException(
            method: 'watchStudentSessions',
            error: error,
            fallbackMessage: 'No fue posible cargar tus sesiones de práctica.',
          );
          sink.addError(mapped, stackTrace);
        },
      ),
    );
  }

  @override
  Stream<List<SessionModel>> watchTaskSessions({
    required String taskId,
    required String studentId,
    int limit = _defaultPaginationLimit,
  }) {
    final normalizedTaskId = taskId.trim();
    final normalizedStudentId = studentId.trim();

    if (normalizedTaskId.isEmpty || normalizedStudentId.isEmpty) {
      return Stream<List<SessionModel>>.error(
        const InvalidSessionArgumentException(
          'El ID de la tarea y del estudiante son obligatorios',
        ),
      );
    }

    final stream = _sessionService.watchTaskSessions(
      taskId: normalizedTaskId,
      studentId: normalizedStudentId,
      limit: limit,
    );

    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (sessions, sink) => sink.add(sessions),
        handleError: (error, stackTrace, sink) {
          final mapped = _mapToRepositoryException(
            method: 'watchTaskSessions',
            error: error,
            fallbackMessage:
                'No fue posible cargar las sesiones de esta tarea.',
          );
          sink.addError(mapped, stackTrace);
        },
      ),
    );
  }

  /// Lanza una excepción del repositorio mapeando el error original.
  Never _throwRepositoryException({
    required String method,
    required Object error,
    required String fallbackMessage,
    StackTrace? stackTrace,
  }) {
    log(
      'SessionRepositoryImpl#$method error',
      error: error,
      stackTrace: stackTrace,
    );

    // Si ya es una excepción del repositorio, la re-lanza tal cual
    if (error is SessionRepositoryException) {
      throw error;
    }

    // Si es una excepción mapeada de Firebase, la convierte a excepción del repositorio
    if (error is FirebaseErrorMapperException) {
      // Verificar si es un error de "no encontrado" o "creación"
      if (error.message.toLowerCase().contains('no existe')) {
        throw SessionCreationException(error.message, cause: error);
      }
      throw UnknownSessionRepositoryException(error.message, cause: error);
    }

    // Si es una excepción directa de Firebase, la mapea primero
    if (error is FirebaseException) {
      final message = FirebaseErrorMapper.map(error);
      throw UnknownSessionRepositoryException(message, cause: error);
    }

    // Cualquier otro error no esperado
    throw UnknownSessionRepositoryException(fallbackMessage, cause: error);
  }

  /// Mapea un error a una excepción del repositorio sin lanzarla.
  SessionRepositoryException _mapToRepositoryException({
    required String method,
    required Object error,
    required String fallbackMessage,
  }) {
    SessionRepositoryException mapped = UnknownSessionRepositoryException(
      fallbackMessage,
      cause: error,
    );
    try {
      _throwRepositoryException(
        method: method,
        error: error,
        fallbackMessage: fallbackMessage,
      );
    } on SessionRepositoryException catch (repositoryException) {
      mapped = repositoryException;
    }
    return mapped;
  }
}

const _defaultPaginationLimit = 50;

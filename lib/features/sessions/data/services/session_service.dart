import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';

/// Contrato para interactuar con la colección `sessions`.
abstract interface class SessionServiceContract {
  /// Crea una nueva sesión de práctica y actualiza los contadores relacionados.
  ///
  /// Este método realiza una transacción atómica que:
  /// 1. Inserta el registro de sesión en la colección `sessions`
  /// 2. Actualiza los contadores en `assignments/{assignmentId}`:
  ///    - Incrementa `sessionsCount`
  ///    - Incrementa `totalDurationLogged`
  ///    - Actualiza `lastSessionDate`
  /// 3. Actualiza los contadores en `students/{studentId}`:
  ///    - Incrementa `totalSessionsCount`
  ///    - Incrementa `totalDurationLogged`
  ///    - Actualiza `lastSessionDate`
  ///
  /// Lanza [FirebaseErrorMapperException] si ocurre un error de Firestore.
  /// Lanza [ArgumentError] si los datos de la sesión son inválidos.
  Future<void> createSession(SessionModel session);

  /// Obtiene una sesión por su ID.
  Future<SessionModel?> getSessionById(String sessionId);

  /// Obtiene todas las sesiones de un estudiante.
  Stream<List<SessionModel>> watchStudentSessions({
    required String studentId,
    int limit,
  });

  /// Obtiene todas las sesiones de una tarea específica para un estudiante.
  Stream<List<SessionModel>> watchTaskSessions({
    required String taskId,
    required String studentId,
    int limit,
  });
}

/// Servicio para operaciones sobre la colección `sessions` de Firestore.
///
/// Implementa la lógica de negocio para crear y consultar sesiones de práctica,
/// incluyendo la actualización transaccional de contadores en `assignments` y `students`.
final class SessionService implements SessionServiceContract {
  SessionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sessionsCollection =>
      _firestore.collection(_sessionsCollectionName);

  CollectionReference<Map<String, dynamic>> get _assignmentsCollection =>
      _firestore.collection(_assignmentsCollectionName);

  CollectionReference<Map<String, dynamic>> get _studentsCollection =>
      _firestore.collection(_studentsCollectionName);

  @override
  Future<void> createSession(SessionModel session) async {
    // Validaciones
    if (session.id.trim().isEmpty) {
      throw ArgumentError('El ID de la sesión es obligatorio');
    }
    if (session.studentId.trim().isEmpty) {
      throw ArgumentError('El ID del estudiante es obligatorio');
    }
    if (session.taskId.trim().isEmpty) {
      throw ArgumentError('El ID de la tarea es obligatorio');
    }
    if (session.totalDuration < 0) {
      throw ArgumentError('La duración total no puede ser negativa');
    }

    try {
      // Generar el ID del assignment (taskId_studentId)
      final assignmentId = AssignmentModel.generateId(
        session.taskId,
        session.studentId,
      );

      log(
        'SessionService: Creando sesión ${session.id} para estudiante ${session.studentId}, '
        'tarea ${session.taskId}, duración ${session.totalDuration}s',
        name: 'SessionService',
      );

      // Ejecutar transacción atómica
      await _firestore.runTransaction((transaction) async {
        // 1. Referencias a los documentos
        final sessionRef = _sessionsCollection.doc(session.id);
        final assignmentRef = _assignmentsCollection.doc(assignmentId);
        final studentRef = _studentsCollection.doc(session.studentId);

        // 2. Leer el assignment y student para verificar que existen
        final assignmentSnapshot = await transaction.get(assignmentRef);
        final studentSnapshot = await transaction.get(studentRef);

        if (!assignmentSnapshot.exists) {
          throw FirebaseErrorMapperException(
            'La asignación $assignmentId no existe. '
            'Asegúrate de que la tarea está asignada al estudiante.',
          );
        }

        if (!studentSnapshot.exists) {
          throw FirebaseErrorMapperException(
            'El estudiante ${session.studentId} no existe.',
          );
        }

        // 3. Crear la sesión
        transaction.set(sessionRef, session.toJson());

        // 4. Actualizar contadores en assignment
        transaction.update(assignmentRef, {
          'sessionsCount': FieldValue.increment(1),
          'totalDurationLogged': FieldValue.increment(session.totalDuration),
          'lastSessionDate': session.endTime,
        });

        // 5. Actualizar contadores en student
        transaction.update(studentRef, {
          'totalSessionsCount': FieldValue.increment(1),
          'totalDurationLogged': FieldValue.increment(session.totalDuration),
          'lastSessionDate': session.endTime,
        });

        log(
          'SessionService: Transacción completada exitosamente para sesión ${session.id}',
          name: 'SessionService',
        );
      });
    } on FirebaseException catch (error, stackTrace) {
      _logError('createSession', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    } on FirebaseErrorMapperException {
      // Re-throw custom exceptions
      rethrow;
    } catch (error, stackTrace) {
      log(
        'SessionService#createSession Error inesperado',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(
        'Error al crear la sesión: ${error.toString()}',
      );
    }
  }

  @override
  Future<SessionModel?> getSessionById(String sessionId) async {
    final sanitizedId = sessionId.trim();
    if (sanitizedId.isEmpty) {
      throw ArgumentError('El identificador de la sesión es obligatorio');
    }

    try {
      final snapshot = await _sessionsCollection.doc(sanitizedId).get();
      if (!snapshot.exists) {
        return null;
      }
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (error, stackTrace) {
      _logError('getSessionById', error, stackTrace);
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
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
        ArgumentError('El identificador del estudiante es obligatorio'),
      );
    }

    Query<Map<String, dynamic>> query = _sessionsCollection
        .where('studentId', isEqualTo: normalizedId)
        .orderBy('endTime', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(_mapSnapshot).toList(),
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
        ArgumentError('El ID de la tarea y del estudiante son obligatorios'),
      );
    }

    Query<Map<String, dynamic>> query = _sessionsCollection
        .where('taskId', isEqualTo: normalizedTaskId)
        .where('studentId', isEqualTo: normalizedStudentId)
        .orderBy('endTime', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(_mapSnapshot).toList(),
    );
  }

  /// Mapea un snapshot de Firestore a un [SessionModel]
  SessionModel _mapSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw FirebaseErrorMapperException(
        'La sesión solicitada no contiene datos.',
      );
    }
    // Asegurar que el ID esté presente
    data['id'] = data['id'] ?? snapshot.id;
    return SessionModel.fromJson(data);
  }

  /// Registra errores de Firebase en el log
  void _logError(
    String method,
    FirebaseException error,
    StackTrace stackTrace,
  ) {
    log(
      'SessionService#$method FirebaseException: ${error.code}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

// Constantes
const _sessionsCollectionName = 'sessions';
const _assignmentsCollectionName = 'assignments';
const _studentsCollectionName = 'students';
const _defaultPaginationLimit = 50;

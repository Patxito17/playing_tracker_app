import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';

/// Contrato de dominio responsable de orquestar la lógica de sesiones de práctica.
///
/// Este repositorio actúa como capa anti-corrupción entre los Cubits y el
/// servicio de acceso a datos (SessionService). Ningún widget o Cubit debe
/// comunicarse con servicios directamente.
abstract interface class SessionRepository {
  /// Crea una nueva sesión de práctica.
  ///
  /// La implementación debe:
  /// - Validar los campos de la sesión
  /// - Crear la sesión en Firestore
  /// - Actualizar contadores en assignment y student (transaccionalmente)
  ///
  /// Lanza [SessionRepositoryException] si ocurre un error.
  Future<void> createSession(SessionModel session);

  /// Obtiene una sesión específica por su identificador.
  ///
  /// Retorna `null` cuando la sesión no existe o el usuario no tiene permisos.
  Future<SessionModel?> getSessionById(String sessionId);

  /// Observa en tiempo real las sesiones de un estudiante.
  ///
  /// `studentId` es el identificador del estudiante.
  /// `limit` es el número máximo de sesiones a retornar (0 = sin límite).
  ///
  /// Las sesiones se retornan ordenadas por fecha de finalización descendente
  /// (más recientes primero).
  Stream<List<SessionModel>> watchStudentSessions({
    required String studentId,
    int limit,
  });

  /// Observa en tiempo real las sesiones de una tarea específica para un estudiante.
  ///
  /// `taskId` es el identificador de la tarea.
  /// `studentId` es el identificador del estudiante.
  /// `limit` es el número máximo de sesiones a retornar (0 = sin límite).
  ///
  /// Las sesiones se retornan ordenadas por fecha de finalización descendente
  /// (más recientes primero).
  Stream<List<SessionModel>> watchTaskSessions({
    required String taskId,
    required String studentId,
    int limit,
  });

  /// Observa en tiempo real las sesiones de un estudiante en un rango de fechas.
  Stream<List<SessionModel>> watchWeeklySessions({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Excepción base del repositorio de sesiones.
///
/// Esta jerarquía se utiliza para mapear errores de infraestructura (Firestore,
/// red, validaciones) a mensajes de dominio legibles para la UI sin exponer
/// detalles sensibles.
sealed class SessionRepositoryException implements Exception {
  /// Crea una excepción de repositorio con un [message] legible y una
  /// [cause] opcional con el error original.
  const SessionRepositoryException(this.message, {this.cause});

  /// Mensaje human-readable (no exponer detalles sensibles a la UI).
  final String message;

  /// Excepción original u objeto asociado (opcional).
  final Object? cause;

  @override
  String toString() => 'SessionRepositoryException: $message';
}

/// Se lanza cuando una sesión solicitada no existe o no es accesible.
final class SessionNotFoundException extends SessionRepositoryException {
  /// Crea una excepción indicando que la sesión no fue encontrada.
  const SessionNotFoundException(super.message, {super.cause});
}

/// Se lanza cuando hay un error al crear una sesión.
final class SessionCreationException extends SessionRepositoryException {
  /// Crea una excepción indicando que hubo un error al crear la sesión.
  const SessionCreationException(super.message, {super.cause});
}

/// Excepción genérica para errores no clasificados del repositorio.
final class UnknownSessionRepositoryException
    extends SessionRepositoryException {
  /// Crea una excepción genérica de repositorio de sesiones.
  const UnknownSessionRepositoryException(super.message, {super.cause});
}

/// Excepción que indica parámetros inválidos al invocar métodos del repositorio.
final class InvalidSessionArgumentException extends SessionRepositoryException {
  /// Crea una excepción para argumentos inválidos en operaciones del
  /// repositorio de sesiones.
  const InvalidSessionArgumentException(super.message, {super.cause});
}

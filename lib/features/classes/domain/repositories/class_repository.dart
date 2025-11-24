import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/create_class_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';

/// Contrato de dominio responsable de orquestar la lógica de clases y membresías.
///
/// El repositorio actúa como capa anti-corrupción entre los Cubits y los
/// servicios de acceso a datos (Firestore, helpers de fan-out, etc.).
/// Ningún widget o Cubit debe comunicarse con servicios directamente.
abstract interface class ClassRepository {
  /// Crea una clase asociada a un docente y retorna el modelo persistido.
  ///
  /// Implementación esperada: generar código de acceso, validar duplicados
  /// y persistir en la colección `classes`.
  Future<ClassModel> createClass(CreateClassInput input);

  /// Stream que emite las clases del docente actual.
  ///
  /// Debe paginarse en lotes de [limit] (por defecto 20) y reemitir cuando
  /// Firestore notifique cambios en la colección.
  Stream<List<ClassModel>> watchTeacherClasses({
    required String teacherId,
    int limit = 20,
  });

  /// Obtiene una clase específica por su identificador.
  ///
  /// Retorna null cuando la clase no existe o el usuario no tiene permisos.
  Future<ClassModel?> getClassById(String classId);

  /// Invita o agrega un alumno a la clase indicada.
  ///
  /// Debe validar que el docente sea el owner y evitar duplicados.
  Future<void> inviteStudent(InviteStudentInput input);

  /// Permite a un alumno unirse a una clase mediante un código de acceso.
  ///
  /// Debe validar formato del código, existencia de la clase y estado activo.
  Future<void> joinClassWithCode(JoinClassInput input);

  /// Actualiza el estado `isActive` de una clase (activar/archivar).
  ///
  /// Los Cubits usarán este método para archivar clases sin borrarlas.
  Future<void> updateClassStatus({
    required String classId,
    required bool isActive,
  });

  /// Remueve por completo a un alumno de una clase determinada.
  ///
  /// Puede implementarse como borrado lógico (isActive=false) o físico
  /// dependiendo de las reglas definidas en el servicio.
  Future<void> removeStudentFromClass({
    required String classId,
    required String studentId,
  });

  /// Regenera el código de acceso de una clase e invalida el anterior.
  ///
  /// Debe garantizar unicidad del código y propagar la actualización a la UI.
  Future<void> regenerateAccessCode(String classId);

  /// Hook para preparar el fan-out de tareas hacia asignaciones.
  ///
  /// La implementación de Sprint 3 únicamente debe dejar logs y TODOs,
  /// delegando la lógica real al helper de la Fase 4.
  Future<void> fanOutTask({required String taskId, required String classId});
}

/// Excepción base del repositorio de clases.
sealed class ClassRepositoryException implements Exception {
  const ClassRepositoryException(this.message, {this.cause});

  /// Mensaje human-readable (no exponer detalles sensibles a la UI).
  final String message;

  /// Excepción original u objeto asociado (opcional).
  final Object? cause;

  @override
  String toString() => 'ClassRepositoryException: $message';
}

/// Se lanza cuando una clase solicitada no existe o no es accesible.
final class ClassNotFoundException extends ClassRepositoryException {
  const ClassNotFoundException(super.message, {super.cause});
}

/// Se lanza cuando se detecta una colisión al generar o reutilizar códigos.
final class DuplicateAccessCodeException extends ClassRepositoryException {
  const DuplicateAccessCodeException(super.message, {super.cause});
}

/// Se lanza cuando un alumno intenta unirse con un código inválido o expirado.
final class InvalidAccessCodeException extends ClassRepositoryException {
  const InvalidAccessCodeException(super.message, {super.cause});
}

/// Se lanza cuando no se encuentra la membresía solicitada.
final class MembershipNotFoundException extends ClassRepositoryException {
  const MembershipNotFoundException(super.message, {super.cause});
}

/// Excepción genérica para errores no clasificados del repositorio.
final class UnknownClassRepositoryException extends ClassRepositoryException {
  const UnknownClassRepositoryException(super.message, {super.cause});
}

/// Excepción que indica parámetros inválidos al invocar métodos del repositorio.
final class InvalidClassRepositoryArgumentException
    extends ClassRepositoryException {
  const InvalidClassRepositoryArgumentException(super.message, {super.cause});
}

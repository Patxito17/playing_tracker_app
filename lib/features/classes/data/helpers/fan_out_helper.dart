import 'dart:developer';

import 'package:playing_tracker/features/classes/data/services/membership_service.dart';

/// Contrato para helpers de fan-out.
abstract interface class FanOutHelperContract {
  Future<void> prepareFanOut(String taskId, String classId);

  Future<void> propagateToAssignments(String taskId, String classId);
}

/// Helper encargado de preparar y propagar el fan-out de tareas hacia
/// la colección `assignments`.
///
/// Durante el Sprint 3 únicamente registra logs y valida contratos para
/// dejar la infraestructura lista para el Sprint 4.
final class FanOutHelper implements FanOutHelperContract {
  /// Crea una instancia permitiendo inyectar dependencias para pruebas.
  FanOutHelper({MembershipServiceContract? membershipService})
    : _membershipService = membershipService ?? MembershipService();

  final MembershipServiceContract _membershipService;

  /// Prepara la información necesaria para un fan-out.
  ///
  /// Actualmente sólo valida los parámetros y registra logs explicativos.
  @override
  Future<void> prepareFanOut(String taskId, String classId) async {
    _assertIds(taskId, classId);
    log(
      'Preparando fan-out para tarea $taskId y clase $classId',
      name: 'FanOutHelper',
    );
    final studentIds = await _membershipService.getStudentsForClass(classId);
    log(
      'Fan-out pendiente. Alumnos detectados: ${studentIds.length}',
      name: 'FanOutHelper',
      error: {
        'taskId': taskId,
        'classId': classId,
        'studentIds': studentIds,
        'status': 'pending',
      },
    );
    // TODO(Sprint4): Persistir fan-out y devolver assignments generadas.
  }

  /// Propaga la tarea a los documentos `assignments`.
  ///
  /// Implementación pendiente hasta Sprint 4: únicamente registra el hook.
  @override
  Future<void> propagateToAssignments(String taskId, String classId) async {
    _assertIds(taskId, classId);
    log(
      'Propagación pendiente para tarea $taskId / clase $classId',
      name: 'FanOutHelper',
      error: {'taskId': taskId, 'classId': classId, 'status': 'pending'},
    );
    // TODO(Sprint4): Implementar escritura en assignments (batch/transaction).
  }

  void _assertIds(String taskId, String classId) {
    if (taskId.trim().isEmpty) {
      throw ArgumentError('El identificador de la tarea es obligatorio');
    }
    if (classId.trim().isEmpty) {
      throw ArgumentError('El identificador de la clase es obligatorio');
    }
  }
}

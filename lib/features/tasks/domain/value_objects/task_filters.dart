import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';

/// Record que encapsula filtros de alto nivel para consultas de tareas y
/// asignaciones.
///
/// Este value object se utiliza tanto para:
/// - Listar tareas de un docente (`watchTeacherTasks`).
/// - Listar asignaciones de un alumno (`watchStudentAssignments`).
///
/// Restricciones (alineadas con Firestore):
/// - Docente: `createdBy + isActive + createdAt` **o**
///   `createdBy + isActive + dueDate` (no ambas combinaciones a la vez).
/// - Alumno: `studentId + status + assignedAt`.
///
/// Campos:
/// - `isActive`: Filtra por estado activo/archivado de la tarea.
/// - `createdFrom`/`createdTo`: Rango por fecha de creación.
/// - `dueFrom`/`dueTo`: Rango por fecha de vencimiento.
/// - `status`: Estado de la asignación (solo para alumnos).
/// - `assignedFrom`/`assignedTo`: Rango por fecha de asignación
///   (solo para alumnos).
typedef TaskFilters = ({
  bool? isActive,
  DateTime? createdFrom,
  DateTime? createdTo,
  DateTime? dueFrom,
  DateTime? dueTo,
  TaskStatus? status,
  DateTime? assignedFrom,
  DateTime? assignedTo,
});

/// Valida combinaciones básicas de filtros compatibles con Firestore.
///
/// Esta validación NO aplica la query, solo garantiza que no se creen
/// combinaciones imposibles (por ejemplo, mezclar rangos de `createdAt` y
/// `dueDate` en la misma consulta).
///
/// Lanza [ArgumentError] cuando se detectan combinaciones no soportadas.
void validateTaskFilters(TaskFilters filters) {
  final usesCreatedRange =
      filters.createdFrom != null || filters.createdTo != null;
  final usesDueRange = filters.dueFrom != null || filters.dueTo != null;

  // No permitir combinar rangos de createdAt y dueDate en la misma consulta.
  if (usesCreatedRange && usesDueRange) {
    throw ArgumentError(
      'No es posible combinar rangos de creación y vencimiento en la misma '
      'consulta. Usa solo createdAt o solo dueDate.',
    );
  }

  // Validaciones simples de coherencia de rangos.
  if (filters.createdFrom != null &&
      filters.createdTo != null &&
      filters.createdFrom!.isAfter(filters.createdTo!)) {
    throw ArgumentError(
      'El rango de fechas de creación es inválido: createdFrom es posterior '
      'a createdTo.',
    );
  }

  if (filters.dueFrom != null &&
      filters.dueTo != null &&
      filters.dueFrom!.isAfter(filters.dueTo!)) {
    throw ArgumentError(
      'El rango de fechas de vencimiento es inválido: dueFrom es posterior '
      'a dueTo.',
    );
  }

  if (filters.assignedFrom != null &&
      filters.assignedTo != null &&
      filters.assignedFrom!.isAfter(filters.assignedTo!)) {
    throw ArgumentError(
      'El rango de fechas de asignación es inválido: assignedFrom es '
      'posterior a assignedTo.',
    );
  }
}

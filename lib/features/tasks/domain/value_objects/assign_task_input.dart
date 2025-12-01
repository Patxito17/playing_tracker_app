/// Record que encapsula los datos necesarios para asignar una tarea a una
/// clase concreta.
///
/// Este value object no modela todavía el fan-out completo, solo el contrato
/// mínimo que el repositorio necesita para delegar en la capa de
/// infraestructura (servicios + FanOutHelper).
///
/// Campos:
/// - [taskId]: Identificador único de la tarea a asignar.
/// - [classId]: Identificador único de la clase destino.
/// - [teacherId]: Identificador del docente que realiza la asignación.
typedef AssignTaskInput = ({String taskId, String classId, String teacherId});

/// Valida de forma sincrónica los campos requeridos para asignar una tarea.
///
/// Lanza [ArgumentError] cuando se detectan identificadores vacíos o
/// compuestos únicamente por espacios.
void validateAssignTaskInput(AssignTaskInput input) {
  if (input.taskId.trim().isEmpty) {
    throw ArgumentError('El identificador de la tarea es obligatorio');
  }
  if (input.classId.trim().isEmpty) {
    throw ArgumentError('El identificador de la clase es obligatorio');
  }
  if (input.teacherId.trim().isEmpty) {
    throw ArgumentError('El identificador del docente es obligatorio');
  }
}

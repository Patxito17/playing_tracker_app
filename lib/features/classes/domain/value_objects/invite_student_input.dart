/// Record que describe la información necesaria para invitar o agregar
/// manualmente un alumno a una clase existente.
///
/// Campos:
/// - `classId`: Identificador único de la clase de destino.
/// - `studentId`: UID del alumno en Firebase Auth.
/// - `teacherId`: UID del docente propietario (denormalizado para permisos).
/// - `className`: Nombre de la clase (denormalizado para notificaciones/UI).
///
/// Ejemplo de uso:
/// ```dart
/// final inviteInput = (
///   classId: 'class_uuid_456',
///   studentId: 'student_uid_789',
///   teacherId: 'teacher_uid_123',
///   className: 'Piano nivel 1',
/// );
/// validateInviteStudentInput(inviteInput);
/// await classRepository.inviteStudent(inviteInput);
/// ```
typedef InviteStudentInput = ({
  String classId,
  String studentId,
  String teacherId,
  String className,
});

/// Valida que todos los campos necesarios para la invitación estén presentes.
void validateInviteStudentInput(InviteStudentInput input) {
  if (input.classId.trim().isEmpty) {
    throw ArgumentError('El identificador de la clase es obligatorio');
  }

  if (input.studentId.trim().isEmpty) {
    throw ArgumentError('El identificador del alumno es obligatorio');
  }

  if (input.teacherId.trim().isEmpty) {
    throw ArgumentError('El identificador del docente es obligatorio');
  }

  if (input.className.trim().isEmpty) {
    throw ArgumentError('El nombre denormalizado de la clase es obligatorio');
  }
}

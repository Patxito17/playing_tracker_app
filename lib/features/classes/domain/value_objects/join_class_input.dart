/// Record que encapsula los datos necesarios para que un alumno se una
/// a una clase utilizando un código de acceso.
///
/// Campos:
/// - [studentId]: UID del alumno autenticado en Firebase.
/// - [accessCode]: Código alfanumérico de 6 caracteres generado por el docente.
///
/// Ejemplo de uso:
/// ```dart
/// final joinInput = (
///   studentId: 'student_uid_789',
///   accessCode: 'ABC123',
/// );
/// validateJoinClassInput(joinInput);
/// await classRepository.joinClassWithCode(joinInput);
/// ```
typedef JoinClassInput = ({String studentId, String accessCode});

/// Asegura que los datos mínimos para unirse con código sean válidos.
void validateJoinClassInput(JoinClassInput input) {
  if (input.studentId.trim().isEmpty) {
    throw ArgumentError('El identificador del alumno es obligatorio');
  }

  if (input.accessCode.trim().length != 6) {
    throw ArgumentError(
      'El código de acceso debe tener exactamente 6 caracteres',
    );
  }
}

/// Record que encapsula los datos necesarios para crear una clase.
///
/// Este value object garantiza que todas las capas compartan el mismo contrato
/// minimalista y permite validar los campos de entrada antes de llegar al
/// repositorio o servicio correspondiente.
///
/// Campos:
/// - [name]: Nombre visible de la clase. Debe tener al menos 3 caracteres.
/// - [description]: Descripción opcional mostrada en la UI.
/// - [ownerId]: Identificador único del docente que crea la clase.
///
/// Ejemplo de uso:
/// ```dart
/// final input = (
///   name: 'Piano nivel 1',
///   description: 'Sesiones introductorias',
///   ownerId: 'teacher_uid_123',
/// );
/// validateCreateClassInput(input);
/// await classRepository.createClass(input);
/// ```
typedef CreateClassInput = ({String name, String? description, String ownerId});

/// Valida de forma sincrónica los campos requeridos para crear una clase.
///
/// Lanza [ArgumentError] cuando se detecta información faltante o inválida.
void validateCreateClassInput(CreateClassInput input) {
  if (input.name.trim().length < 3) {
    throw ArgumentError(
      'El nombre de la clase debe tener al menos 3 caracteres',
    );
  }

  if (input.ownerId.trim().isEmpty) {
    throw ArgumentError('El identificador del docente es obligatorio');
  }
}

/// Record que encapsula los datos necesarios para crear una tarea.
///
/// Este value object garantiza que todas las capas compartan el mismo contrato
/// y permite validar los campos de entrada antes de llegar al repositorio o
/// servicio correspondiente.
///
/// Campos:
/// - [title]: Título visible de la tarea. Debe tener al menos 3 caracteres.
/// - [description]: Descripción opcional mostrada en la UI.
/// - [createdBy]: Identificador único del docente que crea la tarea.
/// - [durationSuggested]: Duración sugerida de práctica en segundos (> 0).
/// - [attachmentUrl]: URL opcional de material de referencia (video, enlace web).
/// - [dueDate]: Fecha de vencimiento opcional (nivel dominio, DateTime).
///
/// Ejemplo de uso:
/// ```dart
/// final input = (
///   title: 'Escalas de Do mayor',
///   description: 'Practicar escalas en dos octavas',
///   createdBy: 'teacher_uid_123',
///   durationSuggested: 1800,
///   attachmentUrl: 'https://youtube.com/...',
///   dueDate: DateTime.now().add(const Duration(days: 7)),
/// );
/// validateCreateTaskInput(input);
/// await taskRepository.createTask(input);
/// ```
typedef CreateTaskInput = ({
  String title,
  String? description,
  String createdBy,
  int durationSuggested,
  String? attachmentUrl,
  DateTime? dueDate,
});

/// Valida de forma sincrónica los campos requeridos para crear una tarea.
///
/// Lanza [ArgumentError] cuando se detecta información faltante o inválida.
void validateCreateTaskInput(CreateTaskInput input) {
  final title = input.title.trim();
  if (title.length < 3) {
    throw ArgumentError(
      'El título de la tarea debe tener al menos 3 caracteres',
    );
  }

  if (input.createdBy.trim().isEmpty) {
    throw ArgumentError('El identificador del docente es obligatorio');
  }

  if (input.durationSuggested <= 0) {
    throw ArgumentError('La duración sugerida debe ser mayor a 0 segundos');
  }

  final url = input.attachmentUrl?.trim();
  if (url != null && url.isNotEmpty) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      throw ArgumentError('La URL del material de referencia no es válida');
    }
  }
}

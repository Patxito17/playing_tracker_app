/// Record que encapsula los datos necesarios para actualizar una tarea.
///
/// Este value object permite realizar actualizaciones parciales de una tarea
/// garantizando que siempre exista un identificador válido y al menos un
/// campo modificable.
///
/// Campos:
/// - [taskId]: Identificador único de la tarea a actualizar (obligatorio).
/// - [title]: Nuevo título opcional (mínimo 3 caracteres si se proporciona).
/// - [description]: Nueva descripción opcional.
/// - [durationSuggested]: Nueva duración sugerida en segundos (> 0 si se
///   proporciona).
/// - [attachmentUrl]: Nueva URL de material de referencia opcional. Pasar
///   cadena vacía para eliminar la URL existente.
/// - [dueDate]: Nueva fecha de vencimiento opcional.
/// - [isActive]: Permite archivar/activar la tarea.
typedef UpdateTaskInput = ({
  String taskId,
  String? title,
  String? description,
  int? durationSuggested,
  String? attachmentUrl,
  DateTime? dueDate,
  bool? isActive,
});

/// Valida de forma sincrónica los campos requeridos para actualizar una tarea.
///
/// Lanza [ArgumentError] cuando:
/// - El [taskId] está vacío.
/// - No se proporciona ningún campo modificable.
/// - Algún campo proporcionado no cumple las reglas mínimas.
void validateUpdateTaskInput(UpdateTaskInput input) {
  if (input.taskId.trim().isEmpty) {
    throw ArgumentError('El identificador de la tarea es obligatorio');
  }

  final hasUpdatableField =
      input.title != null ||
      input.description != null ||
      input.durationSuggested != null ||
      input.attachmentUrl != null ||
      input.dueDate != null ||
      input.isActive != null;

  if (!hasUpdatableField) {
    throw ArgumentError(
      'Debe proporcionarse al menos un campo para actualizar la tarea',
    );
  }

  final title = input.title?.trim();
  if (title != null && title.length < 3) {
    throw ArgumentError(
      'El título de la tarea debe tener al menos 3 caracteres',
    );
  }

  final duration = input.durationSuggested;
  if (duration != null && duration <= 0) {
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

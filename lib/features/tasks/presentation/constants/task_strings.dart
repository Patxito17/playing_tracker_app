/// Strings relacionados con tareas
class TaskStrings {
  // Títulos y acciones
  static const String createTask = 'Crear nueva tarea';
  static const String tasksTitle = 'Tareas';
  static const String myTasksTitle = 'Mis tareas';
  static const String taskDetailTitle = 'Detalle de tarea';
  static const String newTaskTitle = 'Nueva tarea';
  static const String assignedTo = 'Asignada a';
  static const String studentsLabel = 'estudiantes';
  static const String startStudySession = 'Iniciar sesión de estudio';
  static const String viewDetails = 'Ver detalles';
  static const String createTaskButton = 'Crear tarea';
  static const String editTask = 'Editar tarea';
  static const String deleteTask = 'Eliminar tarea';
  static const String assignTask = 'Asignar tarea';
  static const String startTimer = 'Iniciar cronómetro';
  static const String backToTasks = 'Volver a tareas';

  // Formulario crear tarea
  static const String taskTitleLabel = 'Título';
  static const String taskTitleHint = 'Título de la tarea';
  static const String taskDescriptionLabel = 'Descripción';
  static const String taskDescriptionHint = 'Descripción detallada de la tarea';
  static const String estimatedTimeLabel = 'Tiempo estimado';
  static const String estimatedTimeHint = 'Ej: 30 minutos';
  static const String dueDateHint = 'Selecciona una fecha límite';
  static const String recipientsLabel = 'Destinatarios';
  static const String recipientsHint = 'Selecciona los estudiantes';
  static const String attachmentsLabel = 'Adjuntos';
  static const String attachmentsHint =
      'Enlaces externos (YouTube, Drive, etc.)';
  static const String addAttachment = 'Agregar adjunto';
  static const String noAttachments = 'No hay adjuntos';
  static const String selectAllStudents = 'Todos';
  static const String deselectAllStudents = 'Ninguno';

  // Información de tarea
  static const String taskInformation = 'Información de la tarea';
  static const String estimatedTime = 'Tiempo estimado';
  static const String createdDate = 'Fecha de creación';
  static const String dueDate = 'Fecha límite';
  static const String recipients = 'Destinatarios';
  static const String description = 'Descripción';
  static const String attachments = 'Adjuntos';
  static const String minutes = 'minutos';
  static const String hours = 'horas';
  static const String noRecipients = 'No hay destinatarios asignados';
  static const String selectedRecipients = 'estudiantes seleccionados';

  // Estados de tareas
  static const String status = 'Estado';
  static const String pending = 'Pendiente';
  static const String inProgress = 'En progreso';
  static const String completed = 'Completada';
  static const String active = 'Activa';
  static const String archived = 'Archivada';

  // Filtros
  static const String filters = 'Filtros';
  static const String filterByActiveStatus = 'Filtrar por estado activo';
  static const String filterByStatus = 'Filtrar por estado';
  static const String filterByDate = 'Filtrar por fecha';
  static const String filterByClass = 'Filtrar por clase';
  static const String allStatuses = 'Todos los estados';
  static const String allDates = 'Todas las fechas';
  static const String allClasses = 'Todas las clases';
  static const String showActiveOnly = 'Mostrar solo tareas activas';
  static const String showArchivedOnly = 'Mostrar solo tareas archivadas';
  static const String selectDueDate = 'Fecha de vencimiento';
  static const String selectCreatedDate = 'Fecha de creación';
  static const String applyFilters = 'Aplicar filtros';
  static const String clearFilters = 'Limpiar filtros';
  static const String fromLabel = 'Desde';
  static const String toLabel = 'Hasta';

  // Estados vacíos
  static const String noTasksInClass = 'No hay tareas en esta clase';
  static const String createFirstTask = 'Crea tu primera tarea para comenzar';
  static const String noTasksAssigned = 'No hay tareas asignadas';
  static const String waitForTasks = 'Espera a que tu profesor asigne tareas';
  static const String noTasksFound = 'No se encontraron tareas';
  static const String adjustFilters =
      'Ajusta los filtros para ver más resultados';

  // Mensajes de acciones
  static const String taskCreateSuccess = 'Tarea creada correctamente.';
  static const String taskUpdateSuccess = 'Tarea actualizada correctamente.';
  static const String taskDeleteSuccess = 'Tarea eliminada correctamente.';
  static const String taskAssignSuccess = 'Tarea asignada correctamente.';
  static const String confirmDeleteTask = 'Confirmar eliminación de tarea';
  static const String confirmDeleteTaskMessage =
      'Esta acción eliminará la tarea para todos los alumnos. '
      'Podrás crear una nueva más adelante si lo necesitas.';
  static const String selectClassToAssign = 'Selecciona la clase destino';
  static const String assigningTask = 'Asignando tarea...';
  static const String recipientsTitle = 'Seleccionar alumnos';
  static const String assignToAllStudents = 'Asignar a todos los alumnos';
  static const String assignToSelectedStudents =
      'Asignar a alumnos seleccionados';

  // Errores genéricos
  static const String taskGenericError =
      'Ocurrió un error al procesar la tarea. Intenta nuevamente.';
  static const String noStudentsInClassError =
      'No se puede crear la tarea porque no hay estudiantes en la(s) clase(s) seleccionada(s).';

  // Estados vacíos específicos
  static const String noTasksCreated =
      'Todavía no has creado ninguna tarea para tus clases.';
  static const String noAssignmentsReceived =
      'Aún no tienes tareas asignadas. Tu profesor las verá aquí cuando las publique.';

  // UI de alumno
  static const String myAssignmentsTitle = 'Mis tareas';
  static const String assignmentDetailTitle = 'Detalle de tarea';
  static const String startPractice = 'Iniciar práctica';
  static const String practiceAvailableSoon =
      'El cronómetro estará disponible en la próxima versión';
  static const String filterByAssignmentStatus = 'Filtrar por estado';
  static const String sessionsCompleted = 'Sesiones completadas';
  static const String totalPracticeTime = 'Tiempo total practicado';
  static const String assignedAt = 'Asignada el';
  static const String durationSuggested = 'Duración sugerida';

  // Mensajes de fecha límite
  static String daysRemaining(int days) => 'Faltan $days días';
  static const String dueTomorrow = '¡Vence mañana!';
  static const String dueToday = '¡Vence hoy!';
  static String overdueDays(int days) => 'Vencida hace $days días';
  static const String noDueDate = 'Sin fecha límite';

  // Mensajes motivadores de tiempo de estudio
  static String studyTimeRemaining(String time) =>
      '¡Ánimo! Te quedan $time para alcanzar tu objetivo';
  static String extraStudyTime(String time) =>
      '🎉 ¡Increíble! Has estudiado $time extra. ¡Sigue así!';
  static const String studyGoalReached =
      '✅ ¡Objetivo cumplido! Has completado el tiempo sugerido';

  // Diálogo de progreso
  static const String taskProgressTitle = 'Tu progreso';
  static const String keepGoing = '¡Tú puedes!';

  /// Formatea una fecha corta en formato dd/MM/yyyy para usar en filtros.
  static String formatShortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

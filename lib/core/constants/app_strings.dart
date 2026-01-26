/// Strings de la aplicación Playing Tracker
///
/// Este archivo contiene todos los strings de la aplicación organizados
/// por categorías para facilitar el mantenimiento y la internacionalización futura.
///
/// Sprint 0 - Fase 5: Strings centralizados para pantallas de autenticación
library;

/// Strings relacionados con autenticación (login, registro, recuperación de contraseña)
class AuthStrings {
  // Títulos de pantallas
  static const String loginTitle = 'Iniciar sesión';
  static const String registerTitle = 'Crear cuenta';
  static const String forgotPasswordTitle = 'Recuperar contraseña';

  // Títulos principales
  static const String welcomeTitle = 'Bienvenido';
  static const String loginSubtitle = 'Inicia sesión para continuar';
  static const String createAccountTitle = 'Crea tu cuenta';
  static const String createAccountSubtitle =
      'Completa el formulario para registrarte';
  static const String forgotPasswordQuestion = '¿Olvidaste tu contraseña?';
  static const String forgotPasswordInstructions =
      'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.';

  // Labels de campos de formulario
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Contraseña';
  static const String confirmPasswordLabel = 'Confirmar contraseña';
  static const String firstNameLabel = 'Nombre';
  static const String lastNameLabel = 'Apellidos';
  static const String accountTypeLabel = 'Tipo de cuenta';

  // Hints de campos
  static const String emailHint = 'usuario@ejemplo.com';
  static const String passwordHint = 'Ingresa tu contraseña';
  static const String passwordMinLengthHint = 'Mínimo 6 caracteres';
  static const String confirmPasswordHint = 'Repite tu contraseña';
  static const String firstNameHint = 'Ingresa tu nombre';
  static const String lastNameHint = 'Ingresa tus apellidos';

  // Roles
  static const String teacherRole = 'Docente';
  static const String studentRole = 'Alumno';

  // Botones
  static const String loginButton = 'Iniciar sesión';
  static const String loginAsStudentButton = 'Iniciar como alumno (Mock)';
  static const String registerButton = 'Registrarse';
  static const String sendRecoveryLinkButton = 'Enviar enlace de recuperación';

  // Links y acciones
  static const String noAccountQuestion = '¿No tienes cuenta? ';
  static const String registerLink = 'Regístrate';
  static const String alreadyHaveAccountQuestion = '¿Ya tienes cuenta? ';
  static const String loginLink = 'Inicia sesión';
  static const String forgotPasswordLink = '¿Olvidaste tu contraseña?';
  static const String rememberPasswordQuestion = '¿Recordaste tu contraseña? ';

  // Términos y condiciones
  static const String acceptTermsPrefix = 'Acepto los ';
  static const String termsAndConditions = 'términos y condiciones';
  static const String acceptTermsMiddle = ' y la ';
  static const String privacyPolicy = 'política de privacidad';

  // Mensajes de confirmación
  static const String emailSentTitle = 'Email enviado';
  static const String emailSentMessage =
      'Revisa tu bandeja de entrada. Si no encuentras el email, verifica tu carpeta de spam.';
  static const String termsNotAcceptedMessage =
      'Debes aceptar los términos y condiciones';

  // Accesibilidad y Semantics
  static const String loginErrorSemanticLabel =
      'Error al iniciar sesión. Revisa los datos ingresados.';
  static const String registerErrorSemanticLabel =
      'Error al registrarte. Revisa la información del formulario.';
  static const String forgotPasswordSuccessSemanticLabel =
      'Enlace de recuperación enviado correctamente.';
  static const String forgotPasswordErrorSemanticLabel =
      'No se pudo enviar el enlace de recuperación.';
}

/// Strings relacionados con validación de formularios
class ValidationStrings {
  // Validación de campos requeridos
  static String required(String fieldName) => '$fieldName es requerido';

  // Validación de email
  static const String emailRequired = 'El email es requerido';
  static const String emailInvalidFormat = 'El formato del email no es válido';

  // Validación de contraseña
  static const String passwordRequired = 'La contraseña es requerida';
  static const String passwordMinLength =
      'La contraseña debe tener al menos 6 caracteres';

  // Validación de confirmación de contraseña
  static const String confirmPasswordRequired = 'Debes confirmar tu contraseña';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';

  // Validación de nombres
  static String nameRequired(String fieldName) => '$fieldName es requerido';
  static String nameMinLength(String fieldName) =>
      '$fieldName debe tener al menos 3 caracteres';
  static String nameInvalidCharacters(String fieldName) =>
      '$fieldName solo puede contener letras y espacios';

  // Validación de clases
  static const String atLeastOneClassRequired =
      'Debes seleccionar al menos una clase';

  // Nombres de campos para validación
  static const String firstNameField = 'El nombre';
  static const String lastNameField = 'Los apellidos';
}

/// Strings relacionados con clases
class ClassesStrings {
  // Títulos de pantallas
  static const String myClassesTitle = 'Mis clases';
  static const String classesCreatedTitle = 'Clases creadas';
  static const String classesTitle = 'Clases';

  // Acciones
  static const String createClass = 'Crear clase';
  static const String createNewClass = 'Crear nueva clase';
  static const String joinClass = 'Unirse a clase';
  static const String joinClassAction = 'Unirse a clase';

  // Estados vacíos - Docente
  static const String noClassesCreated = 'No tienes clases creadas';
  static const String createFirstClass = 'Crea tu primera clase para comenzar';

  // Estados vacíos - Estudiante
  static const String noClassesJoined = 'No estás en ninguna clase';
  static const String joinClassWithCode = 'Únete a una clase con un código';

  // Información de clases
  static const String studentsCount = 'estudiantes';
  static const String teacherLabel = 'Profesor: ';

  // Crear clase
  static const String createClassTitle = 'Crear nueva clase';
  static const String classNameLabel = 'Nombre de la clase';
  static const String classNameHint = 'Ej: Piano Nivel 1';
  static const String classDescriptionLabel = 'Descripción';
  static const String classDescriptionHint = 'Descripción de la clase';
  static const String accessCodeLabel = 'Código de acceso';
  static const String accessCodeGenerated = 'Se generará automáticamente';
  static const String accessCodeValueLabel = 'Código';
  static const String accessCodeInvalidFormat =
      'El código debe tener 6 caracteres válidos';
  static const String createClassButton = 'Crear clase';
  static const String classStatusActive = 'Clase activa';
  static const String classStatusArchived = 'Clase archivada';
  static const String archiveClassAction = 'Archivar clase';
  static const String activateClassAction = 'Activar clase';
  static const String deleteClassAction = 'Eliminar clase';
  static const String deleteClassConfirmation =
      'Esta acción eliminará definitivamente la clase y todas sus membresías.';
  static const String regenerateAccessCodeAction = 'Regenerar código';
  static const String regenerateCodeConfirmation =
      'Generaremos un nuevo código y el anterior dejará de funcionar.';

  // Unirse a clase
  static const String joinClassTitle = 'Unirse a una clase';
  static const String accessCodeHint = 'Ingresa el código de la clase';
  static const String accessCodeInstructions =
      'Pide el código de acceso a tu profesor para unirte a la clase.';
  static const String joinButton = 'Unirse';

  // Mensajes operativos
  static const String classGenericError =
      'Ocurrió un error al gestionar tus clases.';
  static const String classCreateSuccess = 'Clase creada correctamente.';
  static const String classStatusUpdatedSuccess =
      'El estado de la clase se actualizó correctamente.';
  static const String classDeleteSuccess =
      'La clase fue eliminada correctamente.';
  static const String membershipGenericError =
      'Ocurrió un error al gestionar las membresías.';
  static const String membershipInviteSuccess =
      'Alumno agregado correctamente.';
  static const String membershipJoinSuccess =
      'Te uniste a la clase correctamente.';
  static const String membershipRemoveSuccess =
      'Alumno removido correctamente.';
  static const String membershipActivateSuccess =
      'Alumno activado correctamente.';
  static const String membershipDeactivateSuccess =
      'Alumno inactivado correctamente.';
  static const String membershipDeleteSuccess =
      'La membresía se eliminó definitivamente.';
  static const String membershipRegenerateSuccess =
      'Código de acceso regenerado correctamente.';
  static const String membershipDeleteConfirmation =
      'Esta acción eliminará de forma permanente al alumno de la clase.';
  static const String membershipRevokedError =
      'Fuiste eliminado de esta clase. Contacta al profesor para reingresar.';
}

/// Strings relacionados con navegación
class NavigationStrings {
  // Tabs del BottomNavigationBar
  static const String homeTab = 'Inicio';
  static const String classesTab = 'Clases';
  static const String historyTab = 'Historial';
  static const String statisticsTab = 'Estadísticas';
  static const String settingsTab = 'Ajustes';
}

/// Strings comunes utilizados en toda la aplicación
class CommonStrings {
  // Acciones de contraseña
  static const String showPassword = 'Mostrar contraseña';
  static const String hidePassword = 'Ocultar contraseña';

  // Estados de carga
  static const String loading = 'Cargando...';

  // Acciones comunes
  static const String cancel = 'Cancelar';
  static const String save = 'Guardar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String retry = 'Reintentar';
  static const String confirm = 'Confirmar';
  static const String loadMore = 'Cargar más';
  static const String close = 'Cerrar';
  static const String back = 'Volver';
  static const String next = 'Siguiente';
  static const String done = 'Hecho';
  static const String copy = 'Copiar';
  static const String copied = 'Copiado';
  static const String download = 'Descargar';
}

/// Strings relacionados con detalles de clase y tabs
class ClassDetailStrings {
  // Títulos de tabs
  static const String tasksTab = 'Tareas';
  static const String studentsTab = 'Estudiantes';
  static const String statisticsTab = 'Estadísticas';
  static const String infoTab = 'Información';

  // Títulos de pantallas
  static const String classDetailTitle = 'Detalle de clase';
  static const String manageStudentsTitle = 'Gestionar alumnos';

  // Estadísticas
  static const String classStatisticsTitle = 'Estadísticas de la clase';
  static const String myStatisticsTitle = 'Mis estadísticas';
  static const String totalTime = 'Tiempo total';
  static const String totalTimeDescription =
      'Tiempo total de todos los estudiantes';
  static const String myTotalTimeDescription = 'Tiempo total de estudio';
  static const String totalSessions = 'Sesiones totales';
  static const String mySessions = 'Mis sesiones';
  static const String totalSessionsDescription =
      'Total de sesiones de todos los estudiantes';
  static const String mySessionsDescription = 'Total de sesiones completadas';
  static const String activeStudents = 'Estudiantes activos';
  static const String activeStudentsDescription =
      'Estudiantes con actividad esta semana';

  // Información de clase
  static const String classDescription = 'Descripción';
  static const String teacherInfo = 'Información del docente';
  static const String classInfo = 'Información de la clase';
  static const String accessCode = 'Código de acceso';
  static const String created = 'Creada';
  static const String students = 'Estudiantes';
  static const String email = 'Email';

  static const String classArchivedExitMessage =
      'Esta clase fue archivada y ya no está disponible.';
  static const String classDeletedExitMessage =
      'La clase fue eliminada y volveremos a la lista.';
  static const String membershipRevokedExitMessage =
      'Tu acceso a esta clase fue revocado.';
}

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
      'Archivos adjuntos (PDF, imágenes, etc.)';
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

/// Strings relacionados con estudiantes
class StudentStrings {
  // Títulos
  static const String studentsTitle = 'Estudiantes de la clase';
  static const String studentsListTitle = 'Alumnos de la clase';

  // Información de estudiantes
  static const String studentNameLabel = 'Alumno';
  static const String studentEmailLabel = 'Correo del alumno';
  static const String studentIdLabel = 'ID del alumno';
  static const String joinedAtLabel = 'Se unió el';
  static const String sessions = 'sesiones';
  static const String hours = 'horas';
  static const String sessionsHours = 'sesiones •';

  // Acciones
  static const String viewProfile = 'Ver perfil';
  static const String removeStudent = 'Eliminar estudiante';
  static const String removeStudentConfirmation =
      'Esta acción quitará al alumno de la clase.';
  static const String activateStudentAction = 'Activar alumno';
  static const String deactivateStudentAction = 'Inactivar alumno';
  static const String deleteStudentAction = 'Eliminar alumno';
  static const String inactiveStudentLabel = 'Alumno inactivo';

  // Estados vacíos
  static const String noStudentsInClass = 'No hay estudiantes en esta clase';
  static const String studentsJoinWithCode =
      'Los estudiantes pueden unirse con el código de acceso';
}

/// Strings relacionados con configuración
class SettingsStrings {
  // Título de pantalla
  static const String settingsTitle = 'Configuración';

  // Secciones
  static const String profileSection = 'Perfil';
  static const String notificationsSection = 'Notificaciones';
  static const String appearanceSection = 'Apariencia';
  static const String accountSection = 'Cuenta';

  // Opciones
  static const String editProfile = 'Editar perfil';
  static const String notificationSettings = 'Configuración de notificaciones';
  static const String themeSettings = 'Configuración de tema';
  static const String logout = 'Cerrar sesión';

  // Mensajes
  static const String inDevelopment = 'Esta sección está en desarrollo.';
  static const String futureFeatures =
      'En futuros sprints se añadirá:\n'
      '- Gestión de perfil\n'
      '- Preferencias de notificaciones\n'
      '- Configuración de tema\n'
      '- Cerrar sesión';
}

/// Strings relacionados con los home screens de docente y alumno
class HomeStrings {
  // Títulos generales
  static const String teacherHomeTitle = 'Inicio docente';
  static const String studentHomeTitle = 'Inicio alumno';
  static const String quickActionsTitle = 'Acciones rápidas';

  // Mensajes de bienvenida
  static const String teacherWelcomeTitle = 'Tus clases están listas';
  static const String teacherWelcomeSubtitle =
      'Gestiona tus clases, asigna tareas y monitorea el progreso de tus estudiantes.';
  static const String studentWelcomeTitle = 'Tu práctica continúa';
  static const String studentWelcomeSubtitle =
      'Revisa tus clases activas, únete a nuevas secciones y mantén tus sesiones registradas.';

  // Subtítulos de acciones
  static const String teacherQuickActionsSubtitle =
      'Gestiona tu día a día desde un solo lugar.';
  static const String studentQuickActionsSubtitle =
      'Sigue avanzando con tus clases y tareas pendientes.';

  // Acciones docentes
  static const String manageClassesAction = 'Mis clases';
  static const String manageClassesDescription =
      'Consulta o crea clases nuevas para tus estudiantes.';
  static const String createClassAction = 'Crear clase';
  static const String createClassDescription =
      'Abre una nueva clase y comparte su código de acceso.';
  static const String teacherTasksAction = 'Tareas asignadas';
  static const String teacherTasksDescription =
      'Crea, edita o revisa las tareas activas.';
  static const String teacherStatsAction = 'Estadísticas';
  static const String teacherStatsDescription =
      'Analiza el progreso semanal y los estudiantes activos.';

  // Acciones alumnos
  static const String studentClassesAction = 'Mis clases';
  static const String studentClassesDescription =
      'Explora las clases en las que estás inscrito.';
  static const String joinClassAction = 'Unirse a clase';
  static const String joinClassDescription =
      'Ingresa el código que te compartió tu docente.';
  static const String studentTasksAction = 'Mis tareas';
  static const String studentTasksDescription =
      'Revisa lo que tienes pendiente y marca tus avances.';
  static const String practiceAction = 'Continuar práctica';
  static const String practiceDescription =
      'Registra nuevas sesiones y mantén tu racha activa.';
  static const String studentStatsAction = 'Mis estadísticas';
  static const String studentStatsDescription =
      'Consulta tus métricas personales y celebra tus logros.';

  // Resumen
  static const String highlightsTitle = 'Resumen rápido';
  static const String teacherHighlightsDescription =
      'Pronto verás alertas de clases con poca actividad y tareas próximas a vencer.';
  static const String studentHighlightsDescription =
      'Muy pronto podrás ver tus próximas tareas y el tiempo total invertido.';
}

/// Strings relacionados con sesiones y cronómetro
class SessionStrings {
  // Títulos de pantallas
  static const String timerTitle = 'Cronómetro';
  static const String sessionHistoryTitle = 'Historial de sesiones';

  // Controles del cronómetro
  static const String start = 'Iniciar';
  static const String pause = 'Pausar';
  static const String resume = 'Reanudar';
  static const String reset = 'Reiniciar';
  static const String finish = 'Finalizar sesión';

  // Estados del cronómetro
  static const String idle = 'Inactivo';
  static const String running = 'En ejecución';
  static const String paused = 'Pausado';
  static const String completed = 'Completada';

  // Información de sesión
  static const String currentTask = 'Tarea actual';
  static const String duration = 'Duración';
  static const String date = 'Fecha';
  static const String taskName = 'Tarea';
  static const String elapsedTime = 'Tiempo transcurrido';
  static const String estimatedTimeLabel = 'Tiempo estimado';

  // Historial de sesiones
  static const String noSessions = 'No hay sesiones registradas';
  static const String startFirstSession =
      'Inicia tu primera sesión de estudio para comenzar';
  static const String filterByDate = 'Filtrar por fecha';
  static const String today = 'Hoy';
  static const String thisWeek = 'Esta semana';
  static const String thisMonth = 'Este mes';
  static const String all = 'Todas';
  static const String sessionDate = 'Fecha de sesión';
  static const String sessionDuration = 'Duración';
  static const String sessionTask = 'Tarea';
  static const String viewDetails = 'Ver detalles';
}

/// Strings relacionados con estadísticas
class StatisticsStrings {
  // Títulos de pantallas
  static const String statisticsTitle = 'Estadísticas';
  static const String myStatsTitle = 'Mis estadísticas';
  static const String classStatsTitle = 'Estadísticas de clase';
  static const String studentStatsTitle = 'Estadísticas del alumno';
  static const String taskStatsTitle = 'Estadísticas de tarea';

  // Períodos de tiempo
  static const String today = 'Hoy';
  static const String thisWeek = 'Esta semana';
  static const String thisMonth = 'Este mes';
  static const String thisYear = 'Este año';
  static const String customPeriod = 'Período personalizado';
  static const String selectPeriod = 'Selecciona período';

  // Etiquetas de métricas
  static const String totalTime = 'Tiempo total';
  static const String totalSessions = 'Sesiones totales';
  static const String averageTime = 'Tiempo promedio';
  static const String averagePerSession = 'Promedio por sesión';
  static const String averagePerDay = 'Promedio diario';
  static const String averagePerStudent = 'Promedio por alumno';
  static const String uniqueTasks = 'Tareas trabajadas';
  static const String activeDays = 'Días activos';
  static const String currentStreak = 'Racha actual';
  static const String longestStreak = 'Mejor racha';
  static const String completionRate = 'Tasa de completitud';
  static const String activeStudents = 'Alumnos activos';
  static const String progressPercentage = 'Progreso';

  // Etiquetas de gráficos
  static const String dailyStats = 'Estadísticas diarias';
  static const String weeklyStats = 'Estadísticas semanales';
  static const String monthlyStats = 'Estadísticas mensuales';
  static const String yearlyStats = 'Estadísticas anuales';
  static const String progressChart = 'Gráfico de progreso';
  static const String distributionChart = 'Distribución por tarea';
  static const String trendChart = 'Tendencia';
  static const String comparisonChart = 'Comparativa';

  // Estados y mensajes informativos
  static const String noDataAvailable = 'No hay datos disponibles';
  static const String noDataForPeriod =
      'No hay datos para el período seleccionado';
  static const String selectDifferentPeriod = 'Selecciona otro período';
  static const String loadingStatistics = 'Cargando estadísticas...';
  static const String calculatingStats = 'Calculando estadísticas...';
  static const String tapForDetails = 'Toca para ver detalles';

  // Comparativas
  static const String vsLastWeek = 'vs. semana anterior';
  static const String vsLastMonth = 'vs. mes anterior';
  static const String improvement = 'Mejora';
  static const String decrease = 'Disminución';
  static const String noChange = 'Sin cambios';

  // Rachas
  static String daysStreak(int days) => '$days días seguidos';
  static const String keepItUp = '¡Sigue así!';
  static const String startYourStreak = 'Inicia tu racha hoy';
  static const String streakBroken = 'Racha interrumpida';

  // Mensajes motivacionales
  static const String greatProgress = '¡Excelente progreso!';
  static const String keepGoing = '¡Continúa así!';
  static const String almostThere = '¡Casi lo logras!';
  static const String goalReached = '¡Objetivo alcanzado!';

  // Mensajes de error
  static const String statisticsGenericError =
      'Ocurrió un error al cargar las estadísticas.';
  static const String noDataFoundError =
      'No hay datos disponibles para el período seleccionado.';
  static const String invalidDateRangeError =
      'El rango de fechas seleccionado no es válido.';
  static const String statisticsServiceError =
      'Error al consultar las estadísticas. Intenta nuevamente.';
  static const String resourceNotFoundError =
      'No se encontró el recurso solicitado.';
  static const String permissionDeniedError =
      'No tienes permisos para ver estas estadísticas.';

  // Filtros
  static const String filterByPeriod = 'Filtrar por período';
  static const String filterByTask = 'Filtrar por tarea';
  static const String filterByClass = 'Filtrar por clase';
  static const String filterByStudent = 'Filtrar por alumno';
  static const String allTasks = 'Todas las tareas';
  static const String allStudents = 'Todos los alumnos';

  // Exportación
  static const String exportData = 'Exportar datos';
  static const String exportCSV = 'Exportar a CSV';
  static const String exportPDF = 'Exportar a PDF';
  static const String shareStatistics = 'Compartir estadísticas';

  // Ranking
  static const String topStudents = 'Mejores alumnos';
  static const String topTasks = 'Tareas más practicadas';
  static const String ranking = 'Ranking';
  static String position(int pos) => '#$pos';

  // Formatos de tiempo
  static String hoursFormat(int hours) => '$hours h';
  static String minutesFormat(int minutes) => '$minutes min';
  static String secondsFormat(int seconds) => '$seconds s';
  static String hoursMinutesFormat(int hours, int minutes) =>
      '$hours h $minutes min';

  // Ayuda contextual
  static const String dailyStatsHelp =
      'Muestra tu actividad diaria de estudio y sesiones completadas.';
  static const String weeklyStatsHelp =
      'Compara tu progreso semanal y visualiza tendencias.';
  static const String monthlyStatsHelp =
      'Analiza tu evolución mensual y alcanza tus objetivos.';
  static const String streakHelp =
      'Mantén días consecutivos de práctica para mejorar tu racha.';
  static const String distributionHelp =
      'Visualiza cómo distribuyes tu tiempo entre diferentes tareas.';
}

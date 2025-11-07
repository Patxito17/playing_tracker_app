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
  static const String loginTitle = 'Iniciar Sesión';
  static const String registerTitle = 'Crear Cuenta';
  static const String forgotPasswordTitle = 'Recuperar Contraseña';

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
  static const String confirmPasswordLabel = 'Confirmar Contraseña';
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
  static const String loginButton = 'Iniciar Sesión';
  static const String loginAsStudentButton = 'Iniciar como Alumno (Mock)';
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

  // Nombres de campos para validación
  static const String firstNameField = 'El nombre';
  static const String lastNameField = 'Los apellidos';
}

/// Strings relacionados con clases
class ClassesStrings {
  // Títulos de pantallas
  static const String myClassesTitle = 'Mis Clases';
  static const String classesCreatedTitle = 'Clases Creadas';
  static const String classesTitle = 'Clases';

  // Acciones
  static const String createClass = 'Crear Clase';
  static const String createNewClass = 'Crear Nueva Clase';
  static const String joinClass = 'Unirse a Clase';
  static const String joinClassAction = 'Unirse a Clase';

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
  static const String createClassTitle = 'Crear Nueva Clase';
  static const String classNameLabel = 'Nombre de la Clase';
  static const String classNameHint = 'Ej: Piano Nivel 1';
  static const String classDescriptionLabel = 'Descripción';
  static const String classDescriptionHint = 'Descripción de la clase';
  static const String accessCodeLabel = 'Código de Acceso';
  static const String accessCodeGenerated = 'Se generará automáticamente';
  static const String createClassButton = 'Crear Clase';

  // Unirse a clase
  static const String joinClassTitle = 'Unirse a una Clase';
  static const String accessCodeHint = 'Ingresa el código de la clase';
  static const String accessCodeInstructions =
      'Pide el código de acceso a tu profesor para unirte a la clase.';
  static const String joinButton = 'Unirse';
}

/// Strings relacionados con navegación
class NavigationStrings {
  // Tabs del BottomNavigationBar
  static const String classesTab = 'Clases';
  static const String statisticsTab = 'Estadísticas';
  static const String settingsTab = 'Configuración';
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
  static const String classDetailTitle = 'Detalle de Clase';
  static const String manageStudentsTitle = 'Gestionar Alumnos';

  // Estadísticas
  static const String classStatisticsTitle = 'Estadísticas de la Clase';
  static const String myStatisticsTitle = 'Mis Estadísticas';
  static const String totalTime = 'Tiempo Total';
  static const String totalTimeDescription =
      'Tiempo total de todos los estudiantes';
  static const String myTotalTimeDescription = 'Tiempo total de estudio';
  static const String totalSessions = 'Sesiones Totales';
  static const String mySessions = 'Mis Sesiones';
  static const String totalSessionsDescription =
      'Total de sesiones de todos los estudiantes';
  static const String mySessionsDescription = 'Total de sesiones completadas';
  static const String activeStudents = 'Estudiantes Activos';
  static const String activeStudentsDescription =
      'Estudiantes con actividad esta semana';

  // Información de clase
  static const String classDescription = 'Descripción';
  static const String teacherInfo = 'Información del Docente';
  static const String classInfo = 'Información de la Clase';
  static const String accessCode = 'Código de acceso';
  static const String created = 'Creada';
  static const String students = 'Estudiantes';
  static const String email = 'Email';
}

/// Strings relacionados con tareas
class TaskStrings {
  // Títulos y acciones
  static const String createTask = 'Crear Nueva Tarea';
  static const String tasksTitle = 'Tareas';
  static const String myTasksTitle = 'Mis Tareas';
  static const String taskDetailTitle = 'Detalle de Tarea';
  static const String newTaskTitle = 'Nueva Tarea';
  static const String assignedTo = 'Asignada a';
  static const String studentsLabel = 'estudiantes';
  static const String startStudySession = 'Iniciar Sesión de Estudio';
  static const String viewDetails = 'Ver Detalles';
  static const String createTaskButton = 'Crear Tarea';
  static const String editTask = 'Editar Tarea';
  static const String deleteTask = 'Eliminar Tarea';
  static const String assignTask = 'Asignar Tarea';
  static const String startTimer = 'Iniciar Cronómetro';
  static const String backToTasks = 'Volver a Tareas';

  // Formulario crear tarea
  static const String taskTitleLabel = 'Título';
  static const String taskTitleHint = 'Título de la tarea';
  static const String taskDescriptionLabel = 'Descripción';
  static const String taskDescriptionHint = 'Descripción detallada de la tarea';
  static const String estimatedTimeLabel = 'Tiempo Estimado';
  static const String estimatedTimeHint = 'Ej: 30 minutos';
  static const String recipientsLabel = 'Destinatarios';
  static const String recipientsHint = 'Selecciona los estudiantes';
  static const String attachmentsLabel = 'Adjuntos';
  static const String attachmentsHint =
      'Archivos adjuntos (PDF, imágenes, etc.)';
  static const String addAttachment = 'Agregar Adjunto';
  static const String noAttachments = 'No hay adjuntos';
  static const String selectAllStudents = 'Todos';
  static const String deselectAllStudents = 'Ninguno';

  // Información de tarea
  static const String taskInformation = 'Información de la Tarea';
  static const String estimatedTime = 'Tiempo estimado';
  static const String createdDate = 'Fecha de creación';
  static const String dueDate = 'Fecha límite';
  static const String recipients = 'Destinatarios';
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

  // Filtros
  static const String filters = 'Filtros';
  static const String filterByStatus = 'Filtrar por estado';
  static const String filterByDate = 'Filtrar por fecha';
  static const String filterByClass = 'Filtrar por clase';
  static const String allStatuses = 'Todos los estados';
  static const String allDates = 'Todas las fechas';
  static const String allClasses = 'Todas las clases';

  // Estados vacíos
  static const String noTasksInClass = 'No hay tareas en esta clase';
  static const String createFirstTask = 'Crea tu primera tarea para comenzar';
  static const String noTasksAssigned = 'No hay tareas asignadas';
  static const String waitForTasks = 'Espera a que tu profesor asigne tareas';
  static const String noTasksFound = 'No se encontraron tareas';
  static const String adjustFilters =
      'Ajusta los filtros para ver más resultados';
}

/// Strings relacionados con estudiantes
class StudentStrings {
  // Títulos
  static const String studentsTitle = 'Estudiantes de la Clase';
  static const String studentsListTitle = 'Alumnos de la Clase';

  // Información de estudiantes
  static const String sessions = 'sesiones';
  static const String hours = 'horas';
  static const String sessionsHours = 'sesiones •';

  // Acciones
  static const String viewProfile = 'Ver perfil';
  static const String removeStudent = 'Eliminar estudiante';

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

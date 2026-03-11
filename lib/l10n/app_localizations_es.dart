// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get homeTab => 'Inicio';

  @override
  String get classesTab => 'Clases';

  @override
  String get historyTab => 'Historial';

  @override
  String get statisticsTab => 'Estadísticas';

  @override
  String get settingsTab => 'Ajustes';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get loading => 'Cargando...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get retry => 'Reintentar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get loadMore => 'Cargar más';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Volver';

  @override
  String get next => 'Siguiente';

  @override
  String get done => 'Hecho';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get download => 'Descargar';

  @override
  String fieldRequired(String fieldName) {
    return '$fieldName es requerido';
  }

  @override
  String get emailRequired => 'El email es requerido';

  @override
  String get emailInvalidFormat => 'El formato del email no es válido';

  @override
  String get passwordRequired => 'La contraseña es requerida';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get confirmPasswordRequired => 'Debes confirmar tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get errorEmptyFields => 'Por favor, completa todos los campos';

  @override
  String nameMinLength(String fieldName) {
    return '$fieldName debe tener al menos 2 caracteres';
  }

  @override
  String nameInvalidCharacters(String fieldName) {
    return '$fieldName solo puede contener letras y espacios';
  }

  @override
  String get atLeastOneClassRequired => 'Debes seleccionar al menos una clase';

  @override
  String get firstNameField => 'El nombre';

  @override
  String get lastNameField => 'Los apellidos';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get welcomeTitle => 'Bienvenido';

  @override
  String get loginSubtitle => 'Inicia sesión para continuar';

  @override
  String get createAccountTitle => 'Crea tu cuenta';

  @override
  String get createAccountSubtitle => 'Completa el formulario para registrarte';

  @override
  String get forgotPasswordQuestion => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordInstructions =>
      'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get emailLabel => 'Email';

  @override
  String get authErrorEmailAlreadyInUse =>
      'Este correo electrónico ya está asociado a una cuenta.';

  @override
  String get authErrorInvalidEmail =>
      'La dirección de correo electrónico no es válida.';

  @override
  String get authErrorUserDisabled =>
      'Esta cuenta ha sido desactivada. Por favor, contacta con soporte.';

  @override
  String get authErrorUserNotFound =>
      'No se encontró ninguna cuenta con este correo.';

  @override
  String get authErrorWrongPassword => 'La contraseña ingresada es incorrecta.';

  @override
  String get authErrorTooManyRequests =>
      'Demasiados intentos. Por favor, inténtalo más tarde.';

  @override
  String get authErrorWeakPassword =>
      'La contraseña es muy débil. Por favor, usa una más segura.';

  @override
  String get authErrorOperationNotAllowed =>
      'Esta operación no está permitida actualmente.';

  @override
  String get authErrorInvalidCredential =>
      'Las credenciales proporcionadas son inválidas o han caducado.';

  @override
  String get errorNetworkRequestFailed =>
      'Ocurrió un error de red. Por favor, verifica tu conexión.';

  @override
  String get errorNoInternetConnection => 'No se detectó conexión a internet.';

  @override
  String get errorPermissionDenied =>
      'No tienes permisos para realizar esta acción.';

  @override
  String get errorFailedPrecondition =>
      'Falta un índice requerido en la base de datos.';

  @override
  String get errorServiceUnavailable =>
      'El servicio no está disponible temporalmente. Intenta más tarde.';

  @override
  String get errorGeneric => 'Ocurrió un error inesperado. Intenta nuevamente.';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get firstNameLabel => 'Nombre';

  @override
  String get lastNameLabel => 'Apellidos';

  @override
  String get accountTypeLabel => 'Tipo de cuenta';

  @override
  String get emailHint => 'usuario@ejemplo.com';

  @override
  String get passwordHint => 'Ingresa tu contraseña';

  @override
  String get passwordMinLengthHint => 'Mínimo 6 caracteres';

  @override
  String get confirmPasswordHint => 'Repite tu contraseña';

  @override
  String get firstNameHint => 'Ingresa tu nombre';

  @override
  String get lastNameHint => 'Ingresa tus apellidos';

  @override
  String get teacherRole => 'Docente';

  @override
  String get studentRole => 'Alumno';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get sendRecoveryLinkButton => 'Enviar enlace de recuperación';

  @override
  String get noAccountQuestion => '¿No tienes cuenta? ';

  @override
  String get registerLink => 'Regístrate';

  @override
  String get alreadyHaveAccountQuestion => '¿Ya tienes cuenta? ';

  @override
  String get loginLink => 'Inicia sesión';

  @override
  String get forgotPasswordLink => '¿Olvidaste tu contraseña?';

  @override
  String get rememberPasswordQuestion => '¿Recordaste tu contraseña? ';

  @override
  String get acceptTermsPrefix => 'Acepto los ';

  @override
  String get termsAndConditions => 'términos y condiciones';

  @override
  String get acceptTermsMiddle => ' y la ';

  @override
  String get privacyPolicy => 'política de privacidad';

  @override
  String get emailSentTitle => 'Email enviado';

  @override
  String get emailSentMessage =>
      'Revisa tu bandeja de entrada. Si no encuentras el email, verifica tu carpeta de spam.';

  @override
  String get termsNotAcceptedMessage =>
      'Debes aceptar los términos y condiciones';

  @override
  String get loginErrorSemanticLabel =>
      'Error al iniciar sesión. Revisa los datos ingresados.';

  @override
  String get registerErrorSemanticLabel =>
      'Error al registrarte. Revisa la información del formulario.';

  @override
  String get forgotPasswordSuccessSemanticLabel =>
      'Enlace de recuperación enviado correctamente.';

  @override
  String get forgotPasswordErrorSemanticLabel =>
      'No se pudo enviar el enlace de recuperación.';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get googleSignInCanceled =>
      'El inicio de sesión con Google fue cancelado.';

  @override
  String get googleSignInError =>
      'Ocurrió un error al iniciar sesión con Google. Intenta de nuevo.';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get appleSignInCanceled =>
      'El inicio de sesión con Apple fue cancelado.';

  @override
  String get appleSignInError =>
      'Ocurrió un error al iniciar sesión con Apple. Intenta de nuevo.';

  @override
  String get completeProfileTitle => 'Completa tu perfil';

  @override
  String get completeProfileSubtitle =>
      'Selecciona tu rol y acepta los términos para continuar.';

  @override
  String get completeProfileButton => 'Completar registro';

  @override
  String get orDivider => 'o';

  @override
  String get teacherHomeTitle => 'Inicio docente';

  @override
  String welcomeUser(String name) {
    return 'Hola, $name';
  }

  @override
  String get studentHomeTitle => 'Inicio alumno';

  @override
  String get quickActionsTitle => 'Acciones rápidas';

  @override
  String get teacherWelcomeTitle => 'Tus clases están listas';

  @override
  String get teacherWelcomeSubtitle =>
      'Gestiona tus clases, asigna tareas y monitorea el progreso de tus estudiantes.';

  @override
  String get studentWelcomeTitle => 'Tu práctica continúa';

  @override
  String get studentWelcomeSubtitle =>
      'Revisa tus clases activas, únete a nuevas secciones y mantén tus sesiones registradas.';

  @override
  String get teacherQuickActionsSubtitle =>
      'Gestiona tu día a día desde un solo lugar.';

  @override
  String get studentQuickActionsSubtitle =>
      'Sigue avanzando con tus clases y tareas pendientes.';

  @override
  String get manageClassesAction => 'Mis clases';

  @override
  String get manageClassesDescription =>
      'Consulta o crea clases nuevas para tus estudiantes.';

  @override
  String get createClassAction => 'Crear clase';

  @override
  String get createClassDescription =>
      'Abre una nueva clase y comparte su código de acceso.';

  @override
  String get teacherTasksAction => 'Tareas asignadas';

  @override
  String get teacherTasksDescription =>
      'Crea, edita o revisa las tareas activas.';

  @override
  String get teacherStatsAction => 'Estadísticas';

  @override
  String get teacherStatsDescription =>
      'Analiza el progreso semanal y los estudiantes activos.';

  @override
  String get studentClassesAction => 'Mis clases';

  @override
  String get studentClassesDescription =>
      'Explora las clases en las que estás inscrito.';

  @override
  String get joinClassAction => 'Unirse a clase';

  @override
  String get joinClassDescription =>
      'Ingresa el código que te compartió tu docente.';

  @override
  String get studentTasksAction => 'Mis tareas';

  @override
  String get studentTasksDescription =>
      'Revisa lo que tienes pendiente y marca tus avances.';

  @override
  String get practiceAction => 'Continuar práctica';

  @override
  String get practiceDescription =>
      'Registra nuevas sesiones y mantén tu racha activa.';

  @override
  String get studentStatsAction => 'Mis estadísticas';

  @override
  String get studentStatsDescription =>
      'Consulta tus métricas personales y celebra tus logros.';

  @override
  String get highlightsTitle => 'Resumen rápido';

  @override
  String get teacherHighlightsDescription =>
      'Pronto verás alertas de clases con poca actividad y tareas próximas a vencer.';

  @override
  String get studentHighlightsDescription =>
      'Muy pronto podrás ver tus próximas tareas y el tiempo total invertido.';

  @override
  String get myClassesTitle => 'Mis clases';

  @override
  String get classesCreatedTitle => 'Clases creadas';

  @override
  String get noClassesCreated => 'No tienes clases creadas';

  @override
  String get createFirstClass => 'Crea tu primera clase para comenzar';

  @override
  String get noClassesJoined => 'No estás en ninguna clase';

  @override
  String get joinClassWithCode => 'Únete a una clase con un código';

  @override
  String studentsCount(int count) {
    return '$count estudiantes';
  }

  @override
  String get teacherLabel => 'Profesor: ';

  @override
  String get classNameLabel => 'Nombre de la clase';

  @override
  String get classNameHint => 'Ej: Piano Nivel 1';

  @override
  String get classDescriptionLabel => 'Descripción';

  @override
  String get classDescriptionHint => 'Descripción de la clase';

  @override
  String get accessCodeLabel => 'Código de acceso';

  @override
  String get accessCodeGenerated => 'Se generará automáticamente';

  @override
  String get accessCodeInvalidFormat =>
      'El código debe tener 6 caracteres válidos';

  @override
  String get classStatusActive => 'Clase activa';

  @override
  String get classStatusArchived => 'Clase archivada';

  @override
  String get archiveClassAction => 'Archivar clase';

  @override
  String get activateClassAction => 'Activar clase';

  @override
  String get deleteClassConfirmation =>
      'Esta acción eliminará definitivamente la clase y todas sus membresías.';

  @override
  String get regenerateAccessCodeAction => 'Regenerar código';

  @override
  String get regenerateCodeConfirmation =>
      'Generaremos un nuevo código y el anterior dejará de funcionar.';

  @override
  String get accessCodeHint => 'Ingresa el código de la clase';

  @override
  String get accessCodeInstructions =>
      'Pide el código de acceso a tu profesor para unirte a la clase.';

  @override
  String get classCreateSuccess => 'Clase creada correctamente.';

  @override
  String tasksCount(int count) {
    return '$count tareas';
  }

  @override
  String get createdDateLabel => 'Creada el';

  @override
  String activeStudentsCount(int count) {
    return '$count alumnos activos';
  }

  @override
  String get assignedToLabel => 'Asignada a';

  @override
  String get averageDurationLabel => 'Promedio por alumno';

  @override
  String get classStatusUpdatedSuccess =>
      'El estado de la clase se actualizó correctamente.';

  @override
  String get classDeleteSuccess => 'La clase fue eliminada correctamente.';

  @override
  String get membershipJoinSuccess => 'Te uniste a la clase correctamente.';

  @override
  String get membershipRegenerateSuccess =>
      'Código de acceso regenerado correctamente.';

  @override
  String get membershipServiceError =>
      'Ocurrió un error al procesar la solicitud.';

  @override
  String get genericOperationSuccess => 'Operación realizada correctamente.';

  @override
  String get membershipInactiveError =>
      'No puedes unirte a esta clase porque tu membresía ha sido desactivada. Contacta con tu profesor.';

  @override
  String get classGenericError => 'Ocurrió un error al gestionar tus clases.';

  @override
  String get classCreateError =>
      'No fue posible crear la clase. Intenta nuevamente.';

  @override
  String get classUpdateError => 'No fue posible actualizar la clase.';

  @override
  String get classLoadError => 'Ocurrió un error al cargar tus clases.';

  @override
  String get classRefreshNoTeacherError =>
      'No se ha configurado un docente para actualizar las clases.';

  @override
  String get deleteClassAction => 'Eliminar clase';

  @override
  String get joinButtonLabel => 'Unirse';

  @override
  String get createClassButtonLabel => 'Crear clase';

  @override
  String get tasksTab => 'Tareas';

  @override
  String get studentsTab => 'Estudiantes';

  @override
  String get infoTab => 'Información';

  @override
  String get classDetailTitle => 'Detalle de clase';

  @override
  String get manageStudentsTitle => 'Gestionar alumnos';

  @override
  String get classStatisticsTitle => 'Estadísticas de la clase';

  @override
  String get totalTime => 'Tiempo total';

  @override
  String get totalTimeDescription => 'Tiempo total de todos los estudiantes';

  @override
  String get totalSessions => 'Sesiones totales';

  @override
  String get activeStudents => 'Estudiantes activos';

  @override
  String get classArchivedExitMessage =>
      'Esta clase fue archivada y ya no está disponible.';

  @override
  String get classDeletedExitMessage =>
      'La clase fue eliminada y volveremos a la lista.';

  @override
  String get membershipRevokedExitMessage =>
      'Tu acceso a esta clase fue revocado.';

  @override
  String get studentsListTitle => 'Alumnos de la clase';

  @override
  String get joinedAtLabel => 'Se unió el';

  @override
  String sessionsCount(int count) {
    return '$count sesiones';
  }

  @override
  String hoursCount(int count) {
    return '$count horas';
  }

  @override
  String get removeStudent => 'Eliminar estudiante';

  @override
  String get removeStudentConfirmation =>
      'Esta acción quitará al alumno de la clase.';

  @override
  String get noStudentsInClass => 'No hay estudiantes en esta clase';

  @override
  String get studentsJoinWithCode =>
      'Los estudiantes pueden unirse con el código de acceso';

  @override
  String get createTask => 'Crear nueva tarea';

  @override
  String get myTasksTitle => 'Mis tareas';

  @override
  String get taskDetailTitle => 'Detalle de tarea';

  @override
  String get assignedTo => 'Asignada a';

  @override
  String get startStudySession => 'Iniciar sesión de estudio';

  @override
  String get taskTitleLabel => 'Título';

  @override
  String get taskTitleHint => 'Título de la tarea';

  @override
  String get taskDescriptionLabel => 'Descripción';

  @override
  String get estimatedTimeLabel => 'Tiempo estimado';

  @override
  String get noTasksInClass => 'No hay tareas en esta clase';

  @override
  String get confirmDeleteTaskMessage =>
      'Esta acción eliminará la tarea para todos los alumnos.';

  @override
  String daysRemaining(int days) {
    return 'Faltan $days días';
  }

  @override
  String overdueDays(int days) {
    return 'Vencida hace $days días';
  }

  @override
  String get timerTitle => 'Cronómetro';

  @override
  String get sessionHistoryTitle => 'Historial de sesiones';

  @override
  String get sessionHistoryDescription =>
      'Consulta tu historial de práctica y progreso.';

  @override
  String get elapsedTime => 'Tiempo transcurrido';

  @override
  String get noSessions => 'No hay sesiones registradas';

  @override
  String get generalOverview => 'Vista General';

  @override
  String get currentStreak => 'Racha actual';

  @override
  String daysStreak(int days) {
    return '$days días';
  }

  @override
  String get estimatedTimeHint => 'Ej: 20';

  @override
  String get dueDate => 'Fecha de entrega';

  @override
  String get dueDateHint => 'Sin fecha de entrega';

  @override
  String get taskCreateSuccess => 'Tarea creada correctamente.';

  @override
  String get noStudentsInClassError =>
      'No puedes asignar tareas a una clase sin alumnos.';

  @override
  String get addAttachment => 'Agregar adjunto';

  @override
  String get deselectAllStudents => 'Deseleccionar todos';

  @override
  String get selectAllStudents => 'Seleccionar todos';

  @override
  String get attachmentsLabel => 'Adjuntos';

  @override
  String get noAttachments => 'Sin adjuntos';

  @override
  String get attachmentsHint => 'Puedes agregar enlaces o archivos';

  @override
  String get attachmentUrlLabel => 'Enlace de material';

  @override
  String get attachmentUrlHint => 'Introduce la URL del material';

  @override
  String get createTaskButton => 'Crear tarea';

  @override
  String get myAssignmentsTitle => 'Mis tareas asignadas';

  @override
  String get filters => 'Filtros';

  @override
  String get adjustFilters => 'Ajusta los filtros para ver más resultados';

  @override
  String get noAssignmentsReceived => 'No has recibido tareas aún';

  @override
  String get filterByActiveStatus => 'Filtrar por estado';

  @override
  String get showActiveOnly => 'Solo activas';

  @override
  String get showArchivedOnly => 'Solo archivadas';

  @override
  String get filterByDate => 'Filtrar por fecha';

  @override
  String get selectCreatedDate => 'Fecha de creación';

  @override
  String get selectDueDate => 'Fecha de entrega';

  @override
  String get fromLabel => 'Desde';

  @override
  String get toLabel => 'Hasta';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get assignTask => 'Asignar tarea';

  @override
  String get selectClassToAssign => 'Selecciona una clase para asignar';

  @override
  String get recipientsTitle => 'Destinatarios';

  @override
  String get assignToAllStudents => 'Todos los estudiantes';

  @override
  String selectedRecipients(int count) {
    return '$count seleccionados';
  }

  @override
  String get assignToSelectedStudents => 'Estudiantes seleccionados';

  @override
  String get filterByAssignmentStatus => 'Estado de la tarea';

  @override
  String get pending => 'Pendiente';

  @override
  String get inProgress => 'En progreso';

  @override
  String get completed => 'Completada';

  @override
  String get dueToday => 'Entrega hoy';

  @override
  String get dueTomorrow => 'Entrega mañana';

  @override
  String get noDueDate => 'Sin fecha límite';

  @override
  String extraStudyTime(String time) {
    return 'Estudio extra: $time';
  }

  @override
  String get studyGoalReached => '¡Objetivo alcanzado!';

  @override
  String studyTimeRemaining(String time) {
    return 'Faltan $time';
  }

  @override
  String get taskProgressTitle => 'Progreso de la tarea';

  @override
  String get keepGoing => '¡Sigue así!';

  @override
  String get confirmDeleteTask => 'Confirmar eliminación';

  @override
  String get confirmDeleteTaskWarning =>
      'ATENCIÓN: Esta acción eliminará PERMANENTEMENTE la tarea y todas las asignaciones de los alumnos. No se podrá recuperar ninguna información. ¿Deseas continuar?';

  @override
  String get deleteTaskAction => 'Eliminar tarea';

  @override
  String get editTaskAction => 'Editar tarea';

  @override
  String get activeTaskLabel => 'Tarea activa';

  @override
  String get activeTaskSubtitle => 'Visible para los estudiantes';

  @override
  String get inactiveTaskSubtitle => 'No visible para los estudiantes';

  @override
  String get startTimerAction => 'Iniciar cronómetro';

  @override
  String get estimatedTimeRowLabel => 'Tiempo estimado';

  @override
  String get createdDateRowLabel => 'Fecha de creación';

  @override
  String get dueDateRowLabel => 'Fecha límite';

  @override
  String get recipientsRowLabel => 'Destinatarios';

  @override
  String get noRecipientsLabel => 'No hay destinatarios asignados';

  @override
  String get reTryLoadAction => 'Reintentar carga';

  @override
  String get loadingTaskMessage => 'Cargando tarea...';

  @override
  String get createTaskAction => 'Crear tarea';

  @override
  String get noTasksFound => 'No se encontraron tareas';

  @override
  String get taskUpdateSuccess => 'Tarea actualizada correctamente';

  @override
  String get taskDeleteSuccess => 'Tarea eliminada correctamente';

  @override
  String get loadingError => 'Error al cargar los datos';

  @override
  String get activitySummary => 'Resumen de actividad';

  @override
  String get workedTasks => 'Tareas trabajadas';

  @override
  String sessionsLabelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones',
      one: '1 sesión',
      zero: 'Sin sesiones',
    );
    return '$_temp0';
  }

  @override
  String get inDevelopment => 'Esta sección está en desarrollo.';

  @override
  String get sessionDuration => 'Duración de la sesión';

  @override
  String get sessionDate => 'Fecha de la sesión';

  @override
  String get noFilteredSessions => 'No hay sesiones para este filtro';

  @override
  String get adjustDateFilter => 'Intenta cambiar el filtro de fecha';

  @override
  String get errorLoadingHistory => 'Error al cargar el historial';

  @override
  String get taskHistory => 'Historial de la tarea';

  @override
  String get discardSessionTitle => '¿Descartar sesión?';

  @override
  String get discardSessionMessage =>
      'Perderás todo el progreso de esta sesión de práctica. ¿Estás seguro?';

  @override
  String get discardAction => 'Descartar';

  @override
  String get sessionSavedTitle => '¡Sesión Guardada!';

  @override
  String timePracticedLabel(String time) {
    return 'Tiempo practicado: $time';
  }

  @override
  String get continueAction => 'Continuar';

  @override
  String get runningStatus => 'En progreso...';

  @override
  String get pausedStatus => 'Pausado';

  @override
  String get readyToStartStatus => 'Listo para empezar';

  @override
  String get notesLabel => 'Notas de la sesión (opcional)';

  @override
  String get notesHint => 'Escribe aquí tus observaciones...';

  @override
  String get confirmAndSaveAction => 'Confirmar y guardar';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get notificationSettings => 'Configuración de notificaciones';

  @override
  String get themeSettings => 'Configuración de tema';

  @override
  String get futureFeatures =>
      'En futuros sprints se añadirá:\n- Gestión de perfil\n- Preferencias de notificaciones\n- Configuración de tema\n- Cerrar sesión';

  @override
  String get studentsLabel => 'Estudiantes';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get languageSection => 'Idioma y región';

  @override
  String get languageSettings => 'Idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'Automático (Sistema)';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get colorSettings => 'Color principal';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get generalSection => 'General';

  @override
  String get accountSection => 'Cuenta';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get termsAndConditionsLink => 'Términos y condiciones';

  @override
  String get privacyPolicyLink => 'Política de privacidad';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorPurple => 'Púrpura';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorRed => 'Rojo';

  @override
  String get filterThisWeek => 'Esta semana';

  @override
  String get filterThisMonth => 'Este mes';

  @override
  String get filterLast3Months => 'Últimos 3 meses';

  @override
  String get filterLast9Months => 'Últimos 9 meses';

  @override
  String get filterAllTime => 'Histórico';

  @override
  String get legalConsentTitle => 'Términos y Privacidad';

  @override
  String get legalConsentScrollInstruction =>
      'Lee el contenido completo para continuar';

  @override
  String get legalConsentCheckboxLabel =>
      'He leído y acepto los Términos y Condiciones y la Política de Privacidad';

  @override
  String get legalConsentAcceptButton => 'Aceptar y continuar';

  @override
  String get legalConsentDeclineButton => 'No acepto';

  @override
  String legalConsentVersionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get legalConsentUpdatedTitle => 'Términos actualizados';

  @override
  String get legalConsentUpdatedMessage =>
      'Hemos actualizado nuestros Términos y Condiciones y Política de Privacidad. Por favor, léelos y acéptalos para continuar usando la aplicación.';

  @override
  String get privacyPolicyTitle => 'Política de Privacidad';

  @override
  String get termsAndConditionsTitle => 'Términos y Condiciones';

  @override
  String get legalTextLoadError => 'No se pudieron cargar los términos.';

  @override
  String get firstNameRequired => 'El nombre es requerido';

  @override
  String get lastNameRequired => 'Los apellidos son requeridos';

  @override
  String get termsNotAccepted => 'Debes aceptar los términos y condiciones';

  @override
  String get roleLabel => 'Rol';

  @override
  String get roleTeacher => 'Profesor';

  @override
  String get roleStudent => 'Estudiante';

  @override
  String get termsLinkText => 'Términos y Condiciones';

  @override
  String get startFirstSession => 'Comienza tu primera sesión';

  @override
  String get today => 'Hoy';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get all => 'Todos';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get profileSection => 'Perfil';

  @override
  String get taskDescriptionHint => 'Descripción de la tarea';

  @override
  String get timerStart => 'Empezar';

  @override
  String get timerPause => 'Pausar';

  @override
  String get timerResume => 'Reanudar';
}

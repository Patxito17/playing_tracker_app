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
}

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

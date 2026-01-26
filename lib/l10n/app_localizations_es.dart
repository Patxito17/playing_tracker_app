// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String nameMinLength(String fieldName) {
    return '$fieldName debe tener al menos 3 caracteres';
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
}

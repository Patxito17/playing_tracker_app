import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Texto para mostrar contraseña oculta
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get showPassword;

  /// Texto para ocultar contraseña visible
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get hidePassword;

  /// Texto mostrado durante estados de carga
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// Botón para cancelar acción
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Botón para guardar cambios
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Botón para eliminar elemento
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Botón para editar elemento
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Botón para reintentar acción fallida
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Botón de confirmación
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// Botón para cargar más elementos
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get loadMore;

  /// Botón para cerrar diálogo o pantalla
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// Botón para volver atrás
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// Botón para ir al siguiente paso
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// Botón de finalización
  ///
  /// In es, this message translates to:
  /// **'Hecho'**
  String get done;

  /// Botón para copiar texto
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// Mensaje confirmando que se copió
  ///
  /// In es, this message translates to:
  /// **'Copiado'**
  String get copied;

  /// Botón para descargar archivo
  ///
  /// In es, this message translates to:
  /// **'Descargar'**
  String get download;

  /// Mensaje genérico de campo requerido
  ///
  /// In es, this message translates to:
  /// **'{fieldName} es requerido'**
  String fieldRequired(String fieldName);

  /// Email es campo obligatorio
  ///
  /// In es, this message translates to:
  /// **'El email es requerido'**
  String get emailRequired;

  /// Email con formato incorrecto
  ///
  /// In es, this message translates to:
  /// **'El formato del email no es válido'**
  String get emailInvalidFormat;

  /// Contraseña es campo obligatorio
  ///
  /// In es, this message translates to:
  /// **'La contraseña es requerida'**
  String get passwordRequired;

  /// Contraseña menor a longitud mínima
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get passwordMinLength;

  /// Confirmación de contraseña es obligatoria
  ///
  /// In es, this message translates to:
  /// **'Debes confirmar tu contraseña'**
  String get confirmPasswordRequired;

  /// Las contraseñas ingresadas no coinciden
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// Nombre menor a longitud mínima
  ///
  /// In es, this message translates to:
  /// **'{fieldName} debe tener al menos 3 caracteres'**
  String nameMinLength(String fieldName);

  /// Nombre contiene caracteres inválidos
  ///
  /// In es, this message translates to:
  /// **'{fieldName} solo puede contener letras y espacios'**
  String nameInvalidCharacters(String fieldName);

  /// Validación de selección de clase
  ///
  /// In es, this message translates to:
  /// **'Debes seleccionar al menos una clase'**
  String get atLeastOneClassRequired;

  /// Campo nombre para validaciones
  ///
  /// In es, this message translates to:
  /// **'El nombre'**
  String get firstNameField;

  /// Campo apellidos para validaciones
  ///
  /// In es, this message translates to:
  /// **'Los apellidos'**
  String get lastNameField;

  /// Título de pantalla de login
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginTitle;

  /// Título de pantalla de registro
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get registerTitle;

  /// Título de pantalla de recuperación
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get forgotPasswordTitle;

  /// Saludo de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get welcomeTitle;

  /// Subtítulo de login
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para continuar'**
  String get loginSubtitle;

  /// Título de creación de cuenta
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get createAccountTitle;

  /// Subtítulo de registro
  ///
  /// In es, this message translates to:
  /// **'Completa el formulario para registrarte'**
  String get createAccountSubtitle;

  /// Pregunta si olvidó su contraseña
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPasswordQuestion;

  /// Instrucciones de recuperación
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.'**
  String get forgotPasswordInstructions;

  /// Etiqueta del campo email
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Etiqueta del campo contraseña
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// Etiqueta de confirmación de contraseña
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPasswordLabel;

  /// Etiqueta del campo nombre
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get firstNameLabel;

  /// Etiqueta del campo apellidos
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get lastNameLabel;

  /// Etiqueta para tipo de cuenta
  ///
  /// In es, this message translates to:
  /// **'Tipo de cuenta'**
  String get accountTypeLabel;

  /// Placeholder del campo email
  ///
  /// In es, this message translates to:
  /// **'usuario@ejemplo.com'**
  String get emailHint;

  /// Placeholder del campo contraseña
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get passwordHint;

  /// Hint de longitud mínima
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get passwordMinLengthHint;

  /// Placeholder de confirmación
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get confirmPasswordHint;

  /// Placeholder del campo nombre
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get firstNameHint;

  /// Placeholder del campo apellidos
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus apellidos'**
  String get lastNameHint;

  /// Rol de docente
  ///
  /// In es, this message translates to:
  /// **'Docente'**
  String get teacherRole;

  /// Rol de estudiante
  ///
  /// In es, this message translates to:
  /// **'Alumno'**
  String get studentRole;

  /// Botón de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginButton;

  /// Botón de registro
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registerButton;

  /// Botón enviar enlace
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace de recuperación'**
  String get sendRecoveryLinkButton;

  /// Pregunta si no tiene cuenta
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get noAccountQuestion;

  /// Enlace a registro
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get registerLink;

  /// Pregunta si ya tiene cuenta
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get alreadyHaveAccountQuestion;

  /// Enlace a login
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get loginLink;

  /// Enlace a recuperación
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPasswordLink;

  /// Pregunta si ya recordó su contraseña
  ///
  /// In es, this message translates to:
  /// **'¿Recordaste tu contraseña? '**
  String get rememberPasswordQuestion;

  /// Inicio de aceptación de términos
  ///
  /// In es, this message translates to:
  /// **'Acepto los '**
  String get acceptTermsPrefix;

  /// Términos y condiciones
  ///
  /// In es, this message translates to:
  /// **'términos y condiciones'**
  String get termsAndConditions;

  /// Conector entre términos y privacidad
  ///
  /// In es, this message translates to:
  /// **' y la '**
  String get acceptTermsMiddle;

  /// Política de privacidad
  ///
  /// In es, this message translates to:
  /// **'política de privacidad'**
  String get privacyPolicy;

  /// Título de confirmación de envío
  ///
  /// In es, this message translates to:
  /// **'Email enviado'**
  String get emailSentTitle;

  /// Mensaje tras enviar email
  ///
  /// In es, this message translates to:
  /// **'Revisa tu bandeja de entrada. Si no encuentras el email, verifica tu carpeta de spam.'**
  String get emailSentMessage;

  /// Error si no aceptó términos
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos y condiciones'**
  String get termsNotAcceptedMessage;

  /// No description provided for @loginErrorSemanticLabel.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión. Revisa los datos ingresados.'**
  String get loginErrorSemanticLabel;

  /// Etiqueta semántica de error registro
  ///
  /// In es, this message translates to:
  /// **'Error al registrarte. Revisa la información del formulario.'**
  String get registerErrorSemanticLabel;

  /// Etiqueta semántica de éxito
  ///
  /// In es, this message translates to:
  /// **'Enlace de recuperación enviado correctamente.'**
  String get forgotPasswordSuccessSemanticLabel;

  /// Etiqueta semántica de error
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el enlace de recuperación.'**
  String get forgotPasswordErrorSemanticLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

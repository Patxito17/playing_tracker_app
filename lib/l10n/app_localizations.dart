import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Texto pestaña Inicio
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTab;

  /// Texto pestaña Clases
  ///
  /// In es, this message translates to:
  /// **'Mis Clases'**
  String get classesTab;

  /// Texto pestaña Alumnos
  ///
  /// In es, this message translates to:
  /// **'Alumnos'**
  String get studentsTab;

  /// Texto pestaña Perfil
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTab;

  /// Texto pestaña Historial
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historyTab;

  /// Texto pestaña Estadísticas
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statisticsTab;

  /// Texto pestaña Ajustes
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTab;

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

  /// Mensaje de error cuando hay campos vacíos
  ///
  /// In es, this message translates to:
  /// **'Por favor, completa todos los campos'**
  String get errorEmptyFields;

  /// Nombre más corto que la longitud mínima
  ///
  /// In es, this message translates to:
  /// **'{fieldName} debe tener al menos 2 caracteres'**
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
  /// **'¿Listo para seguir tu progreso?'**
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

  /// Etiqueta del campo de email
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Error cuando el correo ya está registrado
  ///
  /// In es, this message translates to:
  /// **'Este correo electrónico ya está asociado a una cuenta.'**
  String get authErrorEmailAlreadyInUse;

  /// Error cuando el formato del correo es inválido
  ///
  /// In es, this message translates to:
  /// **'La dirección de correo electrónico no es válida.'**
  String get authErrorInvalidEmail;

  /// Error cuando la cuenta está desactivada
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta ha sido desactivada. Por favor, contacta con soporte.'**
  String get authErrorUserDisabled;

  /// Error cuando el usuario no existe
  ///
  /// In es, this message translates to:
  /// **'No se encontró ninguna cuenta con este correo.'**
  String get authErrorUserNotFound;

  /// Error cuando la contraseña es incorrecta
  ///
  /// In es, this message translates to:
  /// **'La contraseña ingresada es incorrecta.'**
  String get authErrorWrongPassword;

  /// Error cuando se realizan demasiadas solicitudes
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Por favor, inténtalo más tarde.'**
  String get authErrorTooManyRequests;

  /// Error cuando la contraseña es débil
  ///
  /// In es, this message translates to:
  /// **'La contraseña es muy débil. Por favor, usa una más segura.'**
  String get authErrorWeakPassword;

  /// Error cuando la operación no está habilitada
  ///
  /// In es, this message translates to:
  /// **'Esta operación no está permitida actualmente.'**
  String get authErrorOperationNotAllowed;

  /// Error cuando las credenciales son inválidas
  ///
  /// In es, this message translates to:
  /// **'Las credenciales proporcionadas son inválidas o han caducado.'**
  String get authErrorInvalidCredential;

  /// Error de fallo en la solicitud de red
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error de red. Por favor, verifica tu conexión.'**
  String get errorNetworkRequestFailed;

  /// Error de falta de conexión a internet
  ///
  /// In es, this message translates to:
  /// **'No se detectó conexión a internet.'**
  String get errorNoInternetConnection;

  /// Error de permisos denegados de Firebase
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos para realizar esta acción.'**
  String get errorPermissionDenied;

  /// Error de precondición fallida de Firebase (usualmente falta de índice)
  ///
  /// In es, this message translates to:
  /// **'Falta un índice requerido en la base de datos.'**
  String get errorFailedPrecondition;

  /// Error de servicio no disponible de Firebase
  ///
  /// In es, this message translates to:
  /// **'El servicio no está disponible temporalmente. Intenta más tarde.'**
  String get errorServiceUnavailable;

  /// Error genérico inesperado
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado. Intenta nuevamente.'**
  String get errorGeneric;

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

  /// Etiqueta semántica de error login
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

  /// Botón de inicio de sesión / registro con Google
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get continueWithGoogle;

  /// Mensaje cuando el usuario cancela el flujo de Google
  ///
  /// In es, this message translates to:
  /// **'El inicio de sesión con Google fue cancelado.'**
  String get googleSignInCanceled;

  /// Error genérico de Google Sign-In
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error al iniciar sesión con Google. Intenta de nuevo.'**
  String get googleSignInError;

  /// Botón de inicio de sesión / registro con Apple
  ///
  /// In es, this message translates to:
  /// **'Apple'**
  String get continueWithApple;

  /// Mensaje cuando el usuario cancela el flujo de Apple
  ///
  /// In es, this message translates to:
  /// **'El inicio de sesión con Apple fue cancelado.'**
  String get appleSignInCanceled;

  /// Error genérico de Apple Sign-In
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error al iniciar sesión con Apple. Intenta de nuevo.'**
  String get appleSignInError;

  /// Título de la pantalla de completar perfil (flujo Google)
  ///
  /// In es, this message translates to:
  /// **'Completa tu perfil'**
  String get completeProfileTitle;

  /// Subtítulo de la pantalla de completar perfil (flujo Google)
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu rol y acepta los términos para continuar.'**
  String get completeProfileSubtitle;

  /// Botón para finalizar el registro vía Google
  ///
  /// In es, this message translates to:
  /// **'Completar registro'**
  String get completeProfileButton;

  /// Separador 'o' entre opciones de login
  ///
  /// In es, this message translates to:
  /// **'O continúa con'**
  String get orDivider;

  /// Título home docente
  ///
  /// In es, this message translates to:
  /// **'Inicio docente'**
  String get teacherHomeTitle;

  /// Saludo de bienvenida con nombre
  ///
  /// In es, this message translates to:
  /// **'¡Hola, {name}!'**
  String welcomeUser(String name);

  /// Título home alumno
  ///
  /// In es, this message translates to:
  /// **'Inicio alumno'**
  String get studentHomeTitle;

  /// Saludo especial para docentes
  ///
  /// In es, this message translates to:
  /// **'¡Buen día, Profe!'**
  String get teacherWelcomeProfe;

  /// Subtítulo del dashboard docente
  ///
  /// In es, this message translates to:
  /// **'Panel de control musical'**
  String get musicalControlPanel;

  /// Etiqueta para el conteo total de alumnos
  ///
  /// In es, this message translates to:
  /// **'Total Alumnos'**
  String get totalStudentsLabel;

  /// Etiqueta para las horas registradas hoy
  ///
  /// In es, this message translates to:
  /// **'Horas Hoy'**
  String get hoursTodayLabel;

  /// Título de la sección de clases en home
  ///
  /// In es, this message translates to:
  /// **'Gestionar mis clases'**
  String get manageMyClasses;

  /// Acción para ver todos los elementos de una lista
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get viewAll;

  /// Etiqueta para el botón de mis clases
  ///
  /// In es, this message translates to:
  /// **'Mis clases'**
  String get myClassesLabel;

  /// Título de la sección de tareas
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get tasksSectionTitle;

  /// Etiqueta para ver tareas
  ///
  /// In es, this message translates to:
  /// **'Ver tareas'**
  String get viewTasksLabel;

  /// Etiqueta para crear nueva tarea
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get newTaskLabel;

  /// Título de la sección de estadísticas
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statsSectionTitle;

  /// Etiqueta para ver progreso
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progressLabel;

  /// Etiqueta para ver historial
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historyLabel;

  /// Tooltip para el botón de notificaciones
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTooltip;

  /// Título acciones rápidas
  ///
  /// In es, this message translates to:
  /// **'Acciones rápidas'**
  String get quickActionsTitle;

  /// Bienvenida docente
  ///
  /// In es, this message translates to:
  /// **'Tus clases están listas'**
  String get teacherWelcomeTitle;

  /// Subtítulo bienvenida docente
  ///
  /// In es, this message translates to:
  /// **'Gestiona tus clases, asigna tareas y monitorea el progreso de tus estudiantes.'**
  String get teacherWelcomeSubtitle;

  /// Bienvenida alumno
  ///
  /// In es, this message translates to:
  /// **'Tu práctica continúa'**
  String get studentWelcomeTitle;

  /// Subtítulo bienvenida alumno
  ///
  /// In es, this message translates to:
  /// **'Revisa tus clases activas, únete a nuevas secciones y mantén tus sesiones registradas.'**
  String get studentWelcomeSubtitle;

  /// Subtítulo acciones docente
  ///
  /// In es, this message translates to:
  /// **'Gestiona tu día a día desde un solo lugar.'**
  String get teacherQuickActionsSubtitle;

  /// Subtítulo acciones alumno
  ///
  /// In es, this message translates to:
  /// **'Sigue avanzando con tus clases y tareas pendientes.'**
  String get studentQuickActionsSubtitle;

  /// Acción gestionar clases
  ///
  /// In es, this message translates to:
  /// **'Mis clases'**
  String get manageClassesAction;

  /// Descripción acción gestionar clases
  ///
  /// In es, this message translates to:
  /// **'Consulta o crea clases nuevas para tus estudiantes.'**
  String get manageClassesDescription;

  /// Acción crear clase
  ///
  /// In es, this message translates to:
  /// **'Crear clase'**
  String get createClassAction;

  /// Descripción acción crear clase
  ///
  /// In es, this message translates to:
  /// **'Abre una nueva clase y comparte su código de acceso.'**
  String get createClassDescription;

  /// Acción tareas asignadas
  ///
  /// In es, this message translates to:
  /// **'Tareas asignadas'**
  String get teacherTasksAction;

  /// Descripción acción tareas asignadas
  ///
  /// In es, this message translates to:
  /// **'Crea, edita o revisa las tareas activas.'**
  String get teacherTasksDescription;

  /// Acción estadísticas docente
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get teacherStatsAction;

  /// Descripción acción estadísticas docente
  ///
  /// In es, this message translates to:
  /// **'Analiza el progreso semanal y los estudiantes activos.'**
  String get teacherStatsDescription;

  /// Acción clases alumno
  ///
  /// In es, this message translates to:
  /// **'Mis clases'**
  String get studentClassesAction;

  /// Descripción clases alumno
  ///
  /// In es, this message translates to:
  /// **'Explora las clases en las que estás inscrito.'**
  String get studentClassesDescription;

  /// Acción unirse clase
  ///
  /// In es, this message translates to:
  /// **'Unirse a clase'**
  String get joinClassAction;

  /// Descripción unirse clase
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código que te compartió tu docente.'**
  String get joinClassDescription;

  /// Acción tareas alumno
  ///
  /// In es, this message translates to:
  /// **'Mis tareas'**
  String get studentTasksAction;

  /// Descripción tareas alumno
  ///
  /// In es, this message translates to:
  /// **'Revisa lo que tienes pendiente y marca tus avances.'**
  String get studentTasksDescription;

  /// Acción continuar práctica
  ///
  /// In es, this message translates to:
  /// **'Continuar práctica'**
  String get practiceAction;

  /// Descripción continuar práctica
  ///
  /// In es, this message translates to:
  /// **'Registra nuevas sesiones y mantén tu racha activa.'**
  String get practiceDescription;

  /// Acción estadísticas alumno
  ///
  /// In es, this message translates to:
  /// **'Mis estadísticas'**
  String get studentStatsAction;

  /// Descripción estadísticas alumno
  ///
  /// In es, this message translates to:
  /// **'Consulta tus métricas personales y celebra tus logros.'**
  String get studentStatsDescription;

  /// Título resumen rápido
  ///
  /// In es, this message translates to:
  /// **'Resumen rápido'**
  String get highlightsTitle;

  /// Descripción resumen docente
  ///
  /// In es, this message translates to:
  /// **'Pronto verás alertas de clases con poca actividad y tareas próximas a vencer.'**
  String get teacherHighlightsDescription;

  /// Descripción resumen alumno
  ///
  /// In es, this message translates to:
  /// **'Muy pronto podrás ver tus próximas tareas y el tiempo total invertido.'**
  String get studentHighlightsDescription;

  /// Título de la sección de progreso semanal
  ///
  /// In es, this message translates to:
  /// **'Progreso Semanal'**
  String get weeklyProgressTitle;

  /// Insignia de virtuoso
  ///
  /// In es, this message translates to:
  /// **'Virtuoso del Mes'**
  String get virtuosoBadge;

  /// Título de la medalla de constancia
  ///
  /// In es, this message translates to:
  /// **'Nueva Medalla: Constancia'**
  String get constancyMedal;

  /// Descripción de la medalla de constancia
  ///
  /// In es, this message translates to:
  /// **'Has practicado 7 días seguidos. ¡Sigue así!'**
  String get constancyDescription;

  /// Subtítulo de la tarjeta de racha cuando hay racha activa
  ///
  /// In es, this message translates to:
  /// **'{days} días seguidos practicando'**
  String streakSubtitleActive(int days);

  /// Subtítulo de la tarjeta de racha cuando no hay racha
  ///
  /// In es, this message translates to:
  /// **'¡Practica hoy para comenzar tu racha!'**
  String get streakSubtitleInactive;

  /// Acción para inscribirse en clases
  ///
  /// In es, this message translates to:
  /// **'Inscribirse'**
  String get inscriptionsAction;

  /// Título mis clases
  ///
  /// In es, this message translates to:
  /// **'Mis clases'**
  String get myClassesTitle;

  /// Título clases creadas
  ///
  /// In es, this message translates to:
  /// **'Clases creadas'**
  String get classesCreatedTitle;

  /// Estado vacío clases docente
  ///
  /// In es, this message translates to:
  /// **'No tienes clases creadas'**
  String get noClassesCreated;

  /// Instrucción crear primera clase
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera clase para comenzar'**
  String get createFirstClass;

  /// Estado vacío clases alumno
  ///
  /// In es, this message translates to:
  /// **'No estás en ninguna clase'**
  String get noClassesJoined;

  /// Instrucción unirse primera clase
  ///
  /// In es, this message translates to:
  /// **'Únete a una clase con un código'**
  String get joinClassWithCode;

  /// Contador de estudiantes
  ///
  /// In es, this message translates to:
  /// **'{count} estudiantes'**
  String studentsCount(int count);

  /// Etiqueta profesor
  ///
  /// In es, this message translates to:
  /// **'Profesor: '**
  String get teacherLabel;

  /// Etiqueta nombre clase
  ///
  /// In es, this message translates to:
  /// **'Nombre de la clase'**
  String get classNameLabel;

  /// Hint nombre clase
  ///
  /// In es, this message translates to:
  /// **'Ej: Piano Nivel 1'**
  String get classNameHint;

  /// Etiqueta descripción clase
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get classDescriptionLabel;

  /// Hint descripción clase
  ///
  /// In es, this message translates to:
  /// **'Descripción de la clase'**
  String get classDescriptionHint;

  /// Etiqueta código acceso
  ///
  /// In es, this message translates to:
  /// **'Código de acceso'**
  String get accessCodeLabel;

  /// Mensaje generación automática código
  ///
  /// In es, this message translates to:
  /// **'Se generará automáticamente'**
  String get accessCodeGenerated;

  /// Error formato código
  ///
  /// In es, this message translates to:
  /// **'El código debe tener 6 caracteres válidos'**
  String get accessCodeInvalidFormat;

  /// Estado clase activa
  ///
  /// In es, this message translates to:
  /// **'Clase activa'**
  String get classStatusActive;

  /// Estado clase archivada
  ///
  /// In es, this message translates to:
  /// **'Clase archivada'**
  String get classStatusArchived;

  /// Acción archivar clase
  ///
  /// In es, this message translates to:
  /// **'Archivar clase'**
  String get archiveClassAction;

  /// Acción activar clase
  ///
  /// In es, this message translates to:
  /// **'Activar clase'**
  String get activateClassAction;

  /// Mensaje confirmación eliminar clase
  ///
  /// In es, this message translates to:
  /// **'Esta acción eliminará definitivamente la clase y todas sus membresías.'**
  String get deleteClassConfirmation;

  /// Acción regenerar código
  ///
  /// In es, this message translates to:
  /// **'Regenerar código'**
  String get regenerateAccessCodeAction;

  /// Mensaje confirmación regenerar código
  ///
  /// In es, this message translates to:
  /// **'Generaremos un nuevo código y el anterior dejará de funcionar.'**
  String get regenerateCodeConfirmation;

  /// Hint ingresar código
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código de la clase'**
  String get accessCodeHint;

  /// Instrucciones código acceso
  ///
  /// In es, this message translates to:
  /// **'Pide el código de acceso a tu profesor para unirte a la clase.'**
  String get accessCodeInstructions;

  /// Éxito crear clase
  ///
  /// In es, this message translates to:
  /// **'Clase creada correctamente.'**
  String get classCreateSuccess;

  /// Contador de tareas
  ///
  /// In es, this message translates to:
  /// **'{count} tareas'**
  String tasksCount(int count);

  /// Etiqueta fecha creación
  ///
  /// In es, this message translates to:
  /// **'Creada el'**
  String get createdDateLabel;

  /// Contador de alumnos activos
  ///
  /// In es, this message translates to:
  /// **'{count} alumnos activos'**
  String activeStudentsCount(int count);

  /// Asignada a...
  ///
  /// In es, this message translates to:
  /// **'Asignada a'**
  String get assignedToLabel;

  /// Promedio duración por alumno
  ///
  /// In es, this message translates to:
  /// **'Promedio por alumno'**
  String get averageDurationLabel;

  /// Éxito actualizar estado clase
  ///
  /// In es, this message translates to:
  /// **'El estado de la clase se actualizó correctamente.'**
  String get classStatusUpdatedSuccess;

  /// Éxito eliminar clase
  ///
  /// In es, this message translates to:
  /// **'La clase fue eliminada correctamente.'**
  String get classDeleteSuccess;

  /// Éxito unirse clase
  ///
  /// In es, this message translates to:
  /// **'Te uniste a la clase correctamente.'**
  String get membershipJoinSuccess;

  /// Éxito regenerar código
  ///
  /// In es, this message translates to:
  /// **'Código de acceso regenerado correctamente.'**
  String get membershipRegenerateSuccess;

  /// Error genérico de membresía
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error al procesar la solicitud.'**
  String get membershipServiceError;

  /// Éxito genérico
  ///
  /// In es, this message translates to:
  /// **'Operación realizada correctamente.'**
  String get genericOperationSuccess;

  /// Error cuando un alumno intenta unirse a una clase de la que fue expulsado/desactivado
  ///
  /// In es, this message translates to:
  /// **'No puedes unirte a esta clase porque tu membresía ha sido desactivada. Contacta con tu profesor.'**
  String get membershipInactiveError;

  /// Error genérico de clases
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error al gestionar tus clases.'**
  String get classGenericError;

  /// Error al crear clase
  ///
  /// In es, this message translates to:
  /// **'No fue posible crear la clase. Intenta nuevamente.'**
  String get classCreateError;

  /// Error al actualizar clase
  ///
  /// In es, this message translates to:
  /// **'No fue posible actualizar la clase.'**
  String get classUpdateError;

  /// Error al cargar clases
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error al cargar tus clases.'**
  String get classLoadError;

  /// Error al refrescar clases sin teacherId
  ///
  /// In es, this message translates to:
  /// **'No se ha configurado un docente para actualizar las clases.'**
  String get classRefreshNoTeacherError;

  /// Acción eliminar clase
  ///
  /// In es, this message translates to:
  /// **'Eliminar clase'**
  String get deleteClassAction;

  /// Etiqueta botón unirse
  ///
  /// In es, this message translates to:
  /// **'Unirse'**
  String get joinButtonLabel;

  /// Etiqueta botón crear clase
  ///
  /// In es, this message translates to:
  /// **'Crear clase'**
  String get createClassButtonLabel;

  /// Pestaña tareas
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get tasksTab;

  /// Pestaña información
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get infoTab;

  /// Título detalle clase
  ///
  /// In es, this message translates to:
  /// **'Detalle de clase'**
  String get classDetailTitle;

  /// Título gestionar alumnos
  ///
  /// In es, this message translates to:
  /// **'Gestionar alumnos'**
  String get manageStudentsTitle;

  /// Título estadísticas clase
  ///
  /// In es, this message translates to:
  /// **'Estadísticas de la clase'**
  String get classStatisticsTitle;

  /// Etiqueta tiempo total
  ///
  /// In es, this message translates to:
  /// **'Tiempo total'**
  String get totalTime;

  /// Descripción tiempo total clase
  ///
  /// In es, this message translates to:
  /// **'Tiempo total de todos los estudiantes'**
  String get totalTimeDescription;

  /// Etiqueta sesiones totales
  ///
  /// In es, this message translates to:
  /// **'Sesiones totales'**
  String get totalSessions;

  /// Etiqueta estudiantes activos
  ///
  /// In es, this message translates to:
  /// **'Estudiantes activos'**
  String get activeStudents;

  /// Mensaje clase archivada
  ///
  /// In es, this message translates to:
  /// **'Esta clase fue archivada y ya no está disponible.'**
  String get classArchivedExitMessage;

  /// Mensaje clase eliminada
  ///
  /// In es, this message translates to:
  /// **'La clase fue eliminada y volveremos a la lista.'**
  String get classDeletedExitMessage;

  /// Mensaje acceso revocado
  ///
  /// In es, this message translates to:
  /// **'Tu acceso a esta clase fue revocado.'**
  String get membershipRevokedExitMessage;

  /// Título lista alumnos
  ///
  /// In es, this message translates to:
  /// **'Alumnos de la clase'**
  String get studentsListTitle;

  /// Etiqueta fecha unión
  ///
  /// In es, this message translates to:
  /// **'Se unió el'**
  String get joinedAtLabel;

  /// Contador de sesiones
  ///
  /// In es, this message translates to:
  /// **'{count} sesiones'**
  String sessionsCount(int count);

  /// Contador de horas
  ///
  /// In es, this message translates to:
  /// **'{count} horas'**
  String hoursCount(int count);

  /// Acción eliminar estudiante
  ///
  /// In es, this message translates to:
  /// **'Eliminar estudiante'**
  String get removeStudent;

  /// Mensaje confirmación eliminar alumno
  ///
  /// In es, this message translates to:
  /// **'Esta acción quitará al alumno de la clase.'**
  String get removeStudentConfirmation;

  /// Estado vacío lista estudiantes
  ///
  /// In es, this message translates to:
  /// **'No hay estudiantes en esta clase'**
  String get noStudentsInClass;

  /// Instrucción unión alumnos
  ///
  /// In es, this message translates to:
  /// **'Los estudiantes pueden unirse con el código de acceso'**
  String get studentsJoinWithCode;

  /// Acción crear tarea
  ///
  /// In es, this message translates to:
  /// **'Crear nueva tarea'**
  String get createTask;

  /// Título mis tareas
  ///
  /// In es, this message translates to:
  /// **'Mis tareas'**
  String get myTasksTitle;

  /// Título detalle tarea
  ///
  /// In es, this message translates to:
  /// **'Detalle de tarea'**
  String get taskDetailTitle;

  /// Etiqueta asignada a
  ///
  /// In es, this message translates to:
  /// **'Asignada a'**
  String get assignedTo;

  /// Acción iniciar estudio
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión de estudio'**
  String get startStudySession;

  /// Etiqueta título tarea
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get taskTitleLabel;

  /// Hint título tarea
  ///
  /// In es, this message translates to:
  /// **'Título de la tarea'**
  String get taskTitleHint;

  /// Etiqueta descripción tarea
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get taskDescriptionLabel;

  /// Etiqueta tiempo estimado
  ///
  /// In es, this message translates to:
  /// **'Tiempo estimado'**
  String get estimatedTimeLabel;

  /// Estado vacío tareas clase
  ///
  /// In es, this message translates to:
  /// **'No hay tareas en esta clase'**
  String get noTasksInClass;

  /// Subtítulo estado vacío tareas clase
  ///
  /// In es, this message translates to:
  /// **'Crea y asigna tareas a los alumnos de esta clase'**
  String get noTasksInClassSubtitle;

  /// Confirmación eliminar tarea
  ///
  /// In es, this message translates to:
  /// **'Esta acción eliminará la tarea para todos los alumnos.'**
  String get confirmDeleteTaskMessage;

  /// Días restantes
  ///
  /// In es, this message translates to:
  /// **'Faltan {days} días'**
  String daysRemaining(int days);

  /// Días de retraso
  ///
  /// In es, this message translates to:
  /// **'Vencida hace {days} días'**
  String overdueDays(int days);

  /// Título cronómetro
  ///
  /// In es, this message translates to:
  /// **'Cronómetro'**
  String get timerTitle;

  /// Título historial sesiones
  ///
  /// In es, this message translates to:
  /// **'Historial de sesiones'**
  String get sessionHistoryTitle;

  /// Descripción acción historial sesiones
  ///
  /// In es, this message translates to:
  /// **'Consulta tu historial de práctica y progreso.'**
  String get sessionHistoryDescription;

  /// Etiqueta tiempo transcurrido
  ///
  /// In es, this message translates to:
  /// **'Tiempo transcurrido'**
  String get elapsedTime;

  /// Estado vacío historial
  ///
  /// In es, this message translates to:
  /// **'No hay sesiones registradas'**
  String get noSessions;

  /// Título vista general estadísticas
  ///
  /// In es, this message translates to:
  /// **'Vista General'**
  String get generalOverview;

  /// Etiqueta racha actual
  ///
  /// In es, this message translates to:
  /// **'Racha actual'**
  String get currentStreak;

  /// Contador racha
  ///
  /// In es, this message translates to:
  /// **'{days} días'**
  String daysStreak(int days);

  /// Hint tiempo estimado
  ///
  /// In es, this message translates to:
  /// **'Ej: 20'**
  String get estimatedTimeHint;

  /// Etiqueta fecha entrega
  ///
  /// In es, this message translates to:
  /// **'Fecha de entrega'**
  String get dueDate;

  /// Hint fecha entrega
  ///
  /// In es, this message translates to:
  /// **'Sin fecha de entrega'**
  String get dueDateHint;

  /// Éxito crear tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea creada correctamente.'**
  String get taskCreateSuccess;

  /// Error asignar clase vacía
  ///
  /// In es, this message translates to:
  /// **'No puedes asignar tareas a una clase sin alumnos.'**
  String get noStudentsInClassError;

  /// Acción agregar adjunto
  ///
  /// In es, this message translates to:
  /// **'Agregar adjunto'**
  String get addAttachment;

  /// Acción deseleccionar todos
  ///
  /// In es, this message translates to:
  /// **'Deseleccionar todos'**
  String get deselectAllStudents;

  /// Acción seleccionar todos
  ///
  /// In es, this message translates to:
  /// **'Seleccionar todos'**
  String get selectAllStudents;

  /// Etiqueta adjuntos
  ///
  /// In es, this message translates to:
  /// **'Adjuntos'**
  String get attachmentsLabel;

  /// Estado sin adjuntos
  ///
  /// In es, this message translates to:
  /// **'Sin adjuntos'**
  String get noAttachments;

  /// Hint adjuntos
  ///
  /// In es, this message translates to:
  /// **'Puedes agregar enlaces o archivos'**
  String get attachmentsHint;

  /// Etiqueta para URL de material adjunto
  ///
  /// In es, this message translates to:
  /// **'Enlace de material'**
  String get attachmentUrlLabel;

  /// Hint para la URL de material adjunto
  ///
  /// In es, this message translates to:
  /// **'Introduce la URL del material'**
  String get attachmentUrlHint;

  /// Botón crear tarea
  ///
  /// In es, this message translates to:
  /// **'Crear tarea'**
  String get createTaskButton;

  /// Título mis tareas (alumno)
  ///
  /// In es, this message translates to:
  /// **'Mis tareas asignadas'**
  String get myAssignmentsTitle;

  /// Etiqueta filtros
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filters;

  /// Instrucción filtros
  ///
  /// In es, this message translates to:
  /// **'Ajusta los filtros para ver más resultados'**
  String get adjustFilters;

  /// Estado vacío tareas alumno
  ///
  /// In es, this message translates to:
  /// **'No has recibido tareas aún'**
  String get noAssignmentsReceived;

  /// Filtro estado
  ///
  /// In es, this message translates to:
  /// **'Filtrar por estado'**
  String get filterByActiveStatus;

  /// Opción solo activas
  ///
  /// In es, this message translates to:
  /// **'Solo activas'**
  String get showActiveOnly;

  /// Opción solo archivadas
  ///
  /// In es, this message translates to:
  /// **'Solo archivadas'**
  String get showArchivedOnly;

  /// Filtro fecha
  ///
  /// In es, this message translates to:
  /// **'Filtrar por fecha'**
  String get filterByDate;

  /// Seleccionar fecha creación
  ///
  /// In es, this message translates to:
  /// **'Fecha de creación'**
  String get selectCreatedDate;

  /// Seleccionar fecha entrega
  ///
  /// In es, this message translates to:
  /// **'Fecha de entrega'**
  String get selectDueDate;

  /// Etiqueta desde
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get fromLabel;

  /// Etiqueta hasta
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get toLabel;

  /// Acción limpiar filtros
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get clearFilters;

  /// Acción aplicar filtros
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get applyFilters;

  /// Acción asignar tarea
  ///
  /// In es, this message translates to:
  /// **'Asignar tarea'**
  String get assignTask;

  /// Instrucción asignar clase
  ///
  /// In es, this message translates to:
  /// **'Selecciona una clase para asignar'**
  String get selectClassToAssign;

  /// Título destinatarios
  ///
  /// In es, this message translates to:
  /// **'Destinatarios'**
  String get recipientsTitle;

  /// Opción todos alumnos
  ///
  /// In es, this message translates to:
  /// **'Todos los estudiantes'**
  String get assignToAllStudents;

  /// Contador seleccionados
  ///
  /// In es, this message translates to:
  /// **'{count} seleccionados'**
  String selectedRecipients(int count);

  /// Opción estudiantes seleccionados
  ///
  /// In es, this message translates to:
  /// **'Estudiantes seleccionados'**
  String get assignToSelectedStudents;

  /// Filtro estado tarea
  ///
  /// In es, this message translates to:
  /// **'Estado de la tarea'**
  String get filterByAssignmentStatus;

  /// Estado pendiente
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pending;

  /// Estado en progreso
  ///
  /// In es, this message translates to:
  /// **'En progreso'**
  String get inProgress;

  /// Estado completada
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get completed;

  /// Entrega hoy
  ///
  /// In es, this message translates to:
  /// **'Entrega hoy'**
  String get dueToday;

  /// Entrega mañana
  ///
  /// In es, this message translates to:
  /// **'Entrega mañana'**
  String get dueTomorrow;

  /// Sin fecha límite
  ///
  /// In es, this message translates to:
  /// **'Sin fecha límite'**
  String get noDueDate;

  /// Tiempo estudio extra
  ///
  /// In es, this message translates to:
  /// **'Estudio extra: {time}'**
  String extraStudyTime(String time);

  /// Objetivo alcanzado
  ///
  /// In es, this message translates to:
  /// **'¡Objetivo alcanzado!'**
  String get studyGoalReached;

  /// Tiempo restante estudio
  ///
  /// In es, this message translates to:
  /// **'Faltan {time}'**
  String studyTimeRemaining(String time);

  /// Título progreso tarea
  ///
  /// In es, this message translates to:
  /// **'Progreso de la tarea'**
  String get taskProgressTitle;

  /// Mensaje ánimo progreso
  ///
  /// In es, this message translates to:
  /// **'¡Sigue así!'**
  String get keepGoing;

  /// Título confirmar eliminar
  ///
  /// In es, this message translates to:
  /// **'Confirmar eliminación'**
  String get confirmDeleteTask;

  /// Aviso eliminación permanente
  ///
  /// In es, this message translates to:
  /// **'ATENCIÓN: Esta acción eliminará PERMANENTEMENTE la tarea y todas las asignaciones de los alumnos. No se podrá recuperar ninguna información. ¿Deseas continuar?'**
  String get confirmDeleteTaskWarning;

  /// Acción eliminar tarea
  ///
  /// In es, this message translates to:
  /// **'Eliminar tarea'**
  String get deleteTaskAction;

  /// Acción editar tarea
  ///
  /// In es, this message translates to:
  /// **'Editar tarea'**
  String get editTaskAction;

  /// Etiqueta tarea activa
  ///
  /// In es, this message translates to:
  /// **'Tarea activa'**
  String get activeTaskLabel;

  /// Subtítulo tarea activa
  ///
  /// In es, this message translates to:
  /// **'Visible para los estudiantes'**
  String get activeTaskSubtitle;

  /// Subtítulo tarea inactiva
  ///
  /// In es, this message translates to:
  /// **'No visible para los estudiantes'**
  String get inactiveTaskSubtitle;

  /// Acción iniciar cronómetro
  ///
  /// In es, this message translates to:
  /// **'Iniciar cronómetro'**
  String get startTimerAction;

  /// Label fila tiempo estimado
  ///
  /// In es, this message translates to:
  /// **'Tiempo estimado'**
  String get estimatedTimeRowLabel;

  /// Label fila fecha creación
  ///
  /// In es, this message translates to:
  /// **'Fecha de creación'**
  String get createdDateRowLabel;

  /// Label fila fecha límite
  ///
  /// In es, this message translates to:
  /// **'Fecha límite'**
  String get dueDateRowLabel;

  /// Label fila destinatarios
  ///
  /// In es, this message translates to:
  /// **'Destinatarios'**
  String get recipientsRowLabel;

  /// Estado sin destinatarios
  ///
  /// In es, this message translates to:
  /// **'No hay destinatarios asignados'**
  String get noRecipientsLabel;

  /// Acción reintentar
  ///
  /// In es, this message translates to:
  /// **'Reintentar carga'**
  String get reTryLoadAction;

  /// Mensaje carga tarea
  ///
  /// In es, this message translates to:
  /// **'Cargando tarea...'**
  String get loadingTaskMessage;

  /// Acción crear tarea docente
  ///
  /// In es, this message translates to:
  /// **'Crear tarea'**
  String get createTaskAction;

  /// Estado vacío tareas
  ///
  /// In es, this message translates to:
  /// **'No se encontraron tareas'**
  String get noTasksFound;

  /// Éxito actualización
  ///
  /// In es, this message translates to:
  /// **'Tarea actualizada correctamente'**
  String get taskUpdateSuccess;

  /// Éxito eliminación
  ///
  /// In es, this message translates to:
  /// **'Tarea eliminada correctamente'**
  String get taskDeleteSuccess;

  /// Error carga genérico
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los datos'**
  String get loadingError;

  /// Subtítulo resumen actividad
  ///
  /// In es, this message translates to:
  /// **'Resumen de actividad'**
  String get activitySummary;

  /// Título tareas trabajadas
  ///
  /// In es, this message translates to:
  /// **'Tareas trabajadas'**
  String get workedTasks;

  /// Contador sesiones
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin sesiones} =1{1 sesión} other{{count} sesiones}}'**
  String sessionsLabelCount(int count);

  /// Mensaje desarrollo
  ///
  /// In es, this message translates to:
  /// **'Esta sección está en desarrollo.'**
  String get inDevelopment;

  /// Etiqueta duración sesión
  ///
  /// In es, this message translates to:
  /// **'Duración de la sesión'**
  String get sessionDuration;

  /// Etiqueta fecha sesión
  ///
  /// In es, this message translates to:
  /// **'Fecha de la sesión'**
  String get sessionDate;

  /// Título genérico para sesión de práctica
  ///
  /// In es, this message translates to:
  /// **'Sesión de práctica'**
  String get practiceSession;

  /// Etiqueta notas en historial de sesión
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get sessionNotesLabel;

  /// Estado vacío filtrado
  ///
  /// In es, this message translates to:
  /// **'No hay sesiones para este filtro'**
  String get noFilteredSessions;

  /// Instrucción filtros fecha
  ///
  /// In es, this message translates to:
  /// **'Intenta cambiar el filtro de fecha'**
  String get adjustDateFilter;

  /// Error carga historial
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el historial'**
  String get errorLoadingHistory;

  /// Título historial tarea
  ///
  /// In es, this message translates to:
  /// **'Historial de la tarea'**
  String get taskHistory;

  /// Título descartar sesión
  ///
  /// In es, this message translates to:
  /// **'¿Descartar sesión?'**
  String get discardSessionTitle;

  /// Mensaje descartar sesión
  ///
  /// In es, this message translates to:
  /// **'Perderás todo el progreso de esta sesión de práctica. ¿Estás seguro?'**
  String get discardSessionMessage;

  /// Acción descartar
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get discardAction;

  /// Título éxito guardado
  ///
  /// In es, this message translates to:
  /// **'¡Sesión Guardada!'**
  String get sessionSavedTitle;

  /// Etiqueta tiempo practicado
  ///
  /// In es, this message translates to:
  /// **'Tiempo practicado: {time}'**
  String timePracticedLabel(String time);

  /// Acción continuar
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueAction;

  /// Estado corriendo
  ///
  /// In es, this message translates to:
  /// **'En progreso...'**
  String get runningStatus;

  /// Estado pausado
  ///
  /// In es, this message translates to:
  /// **'Pausado'**
  String get pausedStatus;

  /// Estado inicial
  ///
  /// In es, this message translates to:
  /// **'Listo para empezar'**
  String get readyToStartStatus;

  /// Label notas
  ///
  /// In es, this message translates to:
  /// **'Notas de la sesión (opcional)'**
  String get notesLabel;

  /// Hint notas
  ///
  /// In es, this message translates to:
  /// **'Escribe aquí tus observaciones...'**
  String get notesHint;

  /// Acción confirmar guardado
  ///
  /// In es, this message translates to:
  /// **'Confirmar y guardar'**
  String get confirmAndSaveAction;

  /// Acción editar perfil
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// Acción notificaciones
  ///
  /// In es, this message translates to:
  /// **'Configuración de notificaciones'**
  String get notificationSettings;

  /// Acción tema
  ///
  /// In es, this message translates to:
  /// **'Configuración de tema'**
  String get themeSettings;

  /// Lista funcionalidades futuras
  ///
  /// In es, this message translates to:
  /// **'En futuros sprints se añadirá:\n- Gestión de perfil\n- Preferencias de notificaciones\n- Configuración de tema\n- Cerrar sesión'**
  String get futureFeatures;

  /// Etiqueta estudiantes
  ///
  /// In es, this message translates to:
  /// **'Estudiantes'**
  String get studentsLabel;

  /// Acción cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// Sección idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma y región'**
  String get languageSection;

  /// Configuración idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageSettings;

  /// Idioma español
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Idioma inglés
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Opción detección automática del idioma del sistema
  ///
  /// In es, this message translates to:
  /// **'Automático (Sistema)'**
  String get languageSystem;

  /// Sección apariencia
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearanceSection;

  /// Configuración color
  ///
  /// In es, this message translates to:
  /// **'Color principal'**
  String get colorSettings;

  /// Título editar perfil
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfileTitle;

  /// Sección general
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get generalSection;

  /// Sección cuenta
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get accountSection;

  /// Label versión app
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String versionLabel(String version);

  /// Link términos
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get termsAndConditionsLink;

  /// Link privacidad
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicyLink;

  /// Tema claro
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// Tema oscuro
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// Tema del sistema
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// Color azul
  ///
  /// In es, this message translates to:
  /// **'Azul'**
  String get colorBlue;

  /// Color púrpura
  ///
  /// In es, this message translates to:
  /// **'Púrpura'**
  String get colorPurple;

  /// Color verde
  ///
  /// In es, this message translates to:
  /// **'Verde'**
  String get colorGreen;

  /// Color naranja
  ///
  /// In es, this message translates to:
  /// **'Naranja'**
  String get colorOrange;

  /// Color rojo
  ///
  /// In es, this message translates to:
  /// **'Rojo'**
  String get colorRed;

  /// Filtro temporal: Esta semana
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get filterThisWeek;

  /// Filtro temporal: Este mes
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get filterThisMonth;

  /// Filtro temporal: Últimos 3 meses
  ///
  /// In es, this message translates to:
  /// **'Últimos 3 meses'**
  String get filterLast3Months;

  /// Filtro temporal: Últimos 9 meses
  ///
  /// In es, this message translates to:
  /// **'Últimos 9 meses'**
  String get filterLast9Months;

  /// Filtro temporal: Histórico
  ///
  /// In es, this message translates to:
  /// **'Histórico'**
  String get filterAllTime;

  /// Título diálogo de consentimiento legal
  ///
  /// In es, this message translates to:
  /// **'Términos y Privacidad'**
  String get legalConsentTitle;

  /// Instrucción de scroll en el diálogo legal
  ///
  /// In es, this message translates to:
  /// **'Lee el contenido completo para continuar'**
  String get legalConsentScrollInstruction;

  /// Label del checkbox de aceptación
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto los Términos y Condiciones y la Política de Privacidad'**
  String get legalConsentCheckboxLabel;

  /// Botón de aceptación del consentimiento
  ///
  /// In es, this message translates to:
  /// **'Aceptar y continuar'**
  String get legalConsentAcceptButton;

  /// Botón de rechazo del consentimiento
  ///
  /// In es, this message translates to:
  /// **'No acepto'**
  String get legalConsentDeclineButton;

  /// Versión de los términos
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String legalConsentVersionLabel(String version);

  /// Título cuando los términos han cambiado
  ///
  /// In es, this message translates to:
  /// **'Términos actualizados'**
  String get legalConsentUpdatedTitle;

  /// Mensaje cuando los términos han cambiado
  ///
  /// In es, this message translates to:
  /// **'Hemos actualizado nuestros Términos y Condiciones y Política de Privacidad. Por favor, léelos y acéptalos para continuar usando la aplicación.'**
  String get legalConsentUpdatedMessage;

  /// Título sección política de privacidad
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyPolicyTitle;

  /// Título sección términos y condiciones
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsAndConditionsTitle;

  /// Error al cargar texto legal
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los términos.'**
  String get legalTextLoadError;

  /// Error de nombre requerido
  ///
  /// In es, this message translates to:
  /// **'El nombre es requerido'**
  String get firstNameRequired;

  /// Error de apellido requerido
  ///
  /// In es, this message translates to:
  /// **'Los apellidos son requeridos'**
  String get lastNameRequired;

  /// Error términos no aceptados
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos y condiciones'**
  String get termsNotAccepted;

  /// Etiqueta rol
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get roleLabel;

  /// Rol profesor
  ///
  /// In es, this message translates to:
  /// **'Profesor'**
  String get roleTeacher;

  /// Rol estudiante
  ///
  /// In es, this message translates to:
  /// **'Estudiante'**
  String get roleStudent;

  /// Texto enlace términos
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsLinkText;

  /// Texto iniciar primera sesión
  ///
  /// In es, this message translates to:
  /// **'Comienza tu primera sesión'**
  String get startFirstSession;

  /// Hoy
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// Esta semana
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// Este mes
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get thisMonth;

  /// Todo el tiempo
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// Título ajustes
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// Sección perfil
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileSection;

  /// Hint descripción tarea
  ///
  /// In es, this message translates to:
  /// **'Descripción de la tarea'**
  String get taskDescriptionHint;

  /// Botón empezar cronómetro
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get timerStart;

  /// Botón pausar cronómetro
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get timerPause;

  /// Botón reanudar cronómetro
  ///
  /// In es, this message translates to:
  /// **'Reanudar'**
  String get timerResume;

  /// Botón reiniciar cronómetro
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get timerReset;

  /// Botón finalizar cronómetro
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get timerFinish;

  /// Sección notificaciones
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsSection;

  /// Respuesta afirmativa
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yesAnswer;

  /// Respuesta negativa
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get noAnswer;

  /// Badge de estado: tarea activa
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get taskStatusActive;

  /// Badge de estado: tarea archivada
  ///
  /// In es, this message translates to:
  /// **'Archivada'**
  String get taskStatusArchived;

  /// Botón continuar sesión de estudio en progreso
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueStudySession;

  /// Título principal de la pantalla de estadísticas
  ///
  /// In es, this message translates to:
  /// **'Mis estadísticas'**
  String get myStatisticsTitle;

  /// Título de la sección para las estadísticas divididas por clase
  ///
  /// In es, this message translates to:
  /// **'Estadísticas por clase'**
  String get statisticsByClass;

  /// Botón o enlace para acceder a la vista de estadísticas
  ///
  /// In es, this message translates to:
  /// **'Ver estadísticas'**
  String get viewStatsAction;

  /// Mensaje de estado vacío cuando el usuario no tiene clases para generar estadísticas
  ///
  /// In es, this message translates to:
  /// **'No tienes clases para ver estadísticas todavía.'**
  String get noClassesForStats;

  /// Título de la sección del resumen general de progreso
  ///
  /// In es, this message translates to:
  /// **'Resumen general'**
  String get generalSummaryTitle;

  /// Etiqueta para el contador o métrica de sesiones de estudio
  ///
  /// In es, this message translates to:
  /// **'Sesiones'**
  String get sessionsLabel;

  /// Etiqueta para el contador de días seguidos de actividad (racha)
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get streakLabel;

  /// Título de la sección o gráfico de la actividad durante la semana
  ///
  /// In es, this message translates to:
  /// **'Actividad semanal'**
  String get weeklyActivityTitle;

  /// Título de la sección o gráfico que muestra cómo se distribuyen las tareas
  ///
  /// In es, this message translates to:
  /// **'Distribución por tarea'**
  String get taskDistributionTitle;

  /// Mensaje de error mostrado cuando falla la petición de estadísticas
  ///
  /// In es, this message translates to:
  /// **'Error al cargar estadísticas'**
  String get errorLoadingStats;

  /// Mensaje mostrado en los gráficos de tareas cuando no hay datos disponibles
  ///
  /// In es, this message translates to:
  /// **'Sin datos de tareas'**
  String get noTaskData;

  /// Texto que indica el total de estudiantes (estadísticas de clase).
  ///
  /// In es, this message translates to:
  /// **'De un total de {count} estudiantes'**
  String ofTotalStudents(int count);

  /// Botón para saltar el tutorial
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get tutorialSkip;

  /// Título del tile en Ajustes para repetir el tutorial
  ///
  /// In es, this message translates to:
  /// **'Repetir tutorial'**
  String get tutorialRepeatTitle;

  /// Subtítulo del tile en Ajustes para repetir el tutorial
  ///
  /// In es, this message translates to:
  /// **'Vuelve a ver la guía de bienvenida'**
  String get tutorialRepeatSubtitle;

  /// Título del paso 1 del tutorial de alumno: saludo
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido a Playing Tracker!'**
  String get tutorialStudentGreetingTitle;

  /// Descripción del paso 1 del tutorial de alumno
  ///
  /// In es, this message translates to:
  /// **'Este es tu panel de control musical. Aquí verás tu progreso y accederás a todo lo que necesitas.'**
  String get tutorialStudentGreetingDesc;

  /// Título del paso 2 del tutorial de alumno: progreso
  ///
  /// In es, this message translates to:
  /// **'Tu progreso semanal'**
  String get tutorialStudentProgressTitle;

  /// Descripción del paso 2 del tutorial de alumno
  ///
  /// In es, this message translates to:
  /// **'Aquí puedes ver cuánto has practicado esta semana. La barra y el gráfico se actualizan con cada sesión.'**
  String get tutorialStudentProgressDesc;

  /// Título del paso 3 del tutorial de alumno: racha
  ///
  /// In es, this message translates to:
  /// **'Tu racha activa'**
  String get tutorialStudentStreakTitle;

  /// Descripción del paso 3 del tutorial de alumno
  ///
  /// In es, this message translates to:
  /// **'¡Practica cada día para mantener tu racha! Cuanto más constante seas, más rápido avanzarás.'**
  String get tutorialStudentStreakDesc;

  /// Título del paso 4 del tutorial de alumno: clases
  ///
  /// In es, this message translates to:
  /// **'Mis clases'**
  String get tutorialStudentClassesTitle;

  /// Descripción del paso 4 del tutorial de alumno
  ///
  /// In es, this message translates to:
  /// **'Accede a todas tus clases musicales, revisa el contenido y registra tus sesiones de práctica.'**
  String get tutorialStudentClassesDesc;

  /// Título del paso 5 del tutorial de alumno: tareas
  ///
  /// In es, this message translates to:
  /// **'Mis tareas'**
  String get tutorialStudentTasksTitle;

  /// Descripción del paso 5 del tutorial de alumno
  ///
  /// In es, this message translates to:
  /// **'Aquí encontrarás todas las tareas asignadas por tu profesor. Completa cada una y registra tu tiempo de práctica.'**
  String get tutorialStudentTasksDesc;

  /// Título del paso 6 del tutorial de alumno: inscripción
  ///
  /// In es, this message translates to:
  /// **'Inscribirte en una clase'**
  String get tutorialStudentEnrollTitle;

  /// Descripción del paso 6 del tutorial de alumno
  ///
  /// In es, this message translates to:
  /// **'¿Tu profesor te dio un código de clase? Úsalo aquí para unirte y empezar a recibir tareas.'**
  String get tutorialStudentEnrollDesc;

  /// Título del paso 1 del tutorial de docente: saludo
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido, docente!'**
  String get tutorialTeacherGreetingTitle;

  /// Descripción del paso 1 del tutorial de docente
  ///
  /// In es, this message translates to:
  /// **'Este es tu panel de gestión musical. Desde aquí controlas tus clases, tareas y el progreso de tus alumnos.'**
  String get tutorialTeacherGreetingDesc;

  /// Título del paso 2 del tutorial de docente: ver clases
  ///
  /// In es, this message translates to:
  /// **'Ver mis clases'**
  String get tutorialTeacherClassesTitle;

  /// Descripción del paso 2 del tutorial de docente
  ///
  /// In es, this message translates to:
  /// **'Consulta todas tus clases activas, ve el listado de alumnos y gestiona el contenido de cada clase.'**
  String get tutorialTeacherClassesDesc;

  /// Título del paso 3 del tutorial de docente: crear clase
  ///
  /// In es, this message translates to:
  /// **'Crear una clase nueva'**
  String get tutorialTeacherCreateClassTitle;

  /// Descripción del paso 3 del tutorial de docente
  ///
  /// In es, this message translates to:
  /// **'Crea una nueva clase, asígnale un nombre y comparte el código con tus alumnos para que puedan unirse.'**
  String get tutorialTeacherCreateClassDesc;

  /// Título del paso 4 del tutorial de docente: tareas
  ///
  /// In es, this message translates to:
  /// **'Gestión de tareas'**
  String get tutorialTeacherTasksTitle;

  /// Descripción del paso 4 del tutorial de docente
  ///
  /// In es, this message translates to:
  /// **'Crea y asigna tareas a tus alumnos. Desde aquí puedes ver el estado de todas las tareas activas.'**
  String get tutorialTeacherTasksDesc;

  /// Título del paso 5 del tutorial de docente: estadísticas
  ///
  /// In es, this message translates to:
  /// **'Estadísticas y progreso'**
  String get tutorialTeacherStatsTitle;

  /// Descripción del paso 5 del tutorial de docente
  ///
  /// In es, this message translates to:
  /// **'Revisa el progreso de tus alumnos, sus tiempos de práctica y el rendimiento general de cada clase.'**
  String get tutorialTeacherStatsDesc;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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

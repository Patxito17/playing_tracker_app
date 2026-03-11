import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../constants/app_constants.dart';

/// Extension methods para BuildContext
///
/// Proporciona acceso rápido y conveniente a Theme, MediaQuery y otras
/// propiedades frecuentemente usadas del BuildContext.
///
/// Sprint 0 - Fase 2: Extension methods implementadas
/// Sprint 0 - Mejora: Extension methods para estilos de texto centralizados
extension BuildContextExtensions on BuildContext {
  /// Acceso rápido al ThemeData
  ///
  /// Uso: `context.theme` en lugar de `Theme.of(context)`
  ThemeData get theme => Theme.of(this);

  /// Acceso rápido al ColorScheme
  ///
  /// Uso: `context.colorScheme` en lugar de `Theme.of(context).colorScheme`
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Acceso rápido al TextTheme
  ///
  /// Uso: `context.textTheme` en lugar de `Theme.of(context).textTheme`
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Acceso rápido al MediaQuery
  ///
  /// Uso: `context.mediaQuery` en lugar de `MediaQuery.of(context)`
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Ancho de la pantalla
  ///
  /// Uso: `context.screenWidth`
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Alto de la pantalla
  ///
  /// Uso: `context.screenHeight`
  double get screenHeight => MediaQuery.of(this).size.height;

  // ============================================================================
  // ESTILOS DE TEXTO CENTRALIZADOS
  // ============================================================================
  // Estos métodos proporcionan acceso fácil a los estilos centralizados
  // de AppTextStyles sin necesidad de escribir AppTextStyles.metodo(this)

  /// Estilo para cronómetros grandes y números destacados
  TextStyle? get displayLargeBold => AppTextStyles.displayLargeBold(this);

  /// Estilo para títulos principales de pantalla
  TextStyle? get displaySmallBold => AppTextStyles.displaySmallBold(this);

  /// Estilo para títulos de sección
  TextStyle? get headlineMediumBold => AppTextStyles.headlineMediumBold(this);

  /// Estilo para títulos de cards y contenedores
  TextStyle? get titleLargeBold => AppTextStyles.titleLargeBold(this);

  /// Estilo para subtítulos destacados
  TextStyle? get titleMediumBold => AppTextStyles.titleMediumBold(this);

  /// Estilo para títulos pequeños
  TextStyle? get titleSmallBold => AppTextStyles.titleSmallBold(this);

  /// Texto de cuerpo principal con color onSurface
  TextStyle? get bodyLargeOnSurface => AppTextStyles.bodyLargeOnSurface(this);

  /// Texto de cuerpo secundario con color onSurfaceVariant
  TextStyle? get bodyLargeOnSurfaceVariant =>
      AppTextStyles.bodyLargeOnSurfaceVariant(this);

  /// Texto de cuerpo medio con color onSurface
  TextStyle? get bodyMediumOnSurface => AppTextStyles.bodyMediumOnSurface(this);

  /// Texto de cuerpo medio secundario con color onSurfaceVariant
  TextStyle? get bodyMediumOnSurfaceVariant =>
      AppTextStyles.bodyMediumOnSurfaceVariant(this);

  /// Texto pequeño con color onSurface
  TextStyle? get bodySmallOnSurface => AppTextStyles.bodySmallOnSurface(this);

  /// Texto pequeño secundario con color onSurfaceVariant
  TextStyle? get bodySmallOnSurfaceVariant =>
      AppTextStyles.bodySmallOnSurfaceVariant(this);

  /// Texto pequeño en negrita con color onSurface
  TextStyle? get bodySmallBold => AppTextStyles.bodySmallBold(this);

  /// Texto de error
  TextStyle? get textError => AppTextStyles.error(this);

  /// Texto destacado con color primario
  TextStyle? get textPrimary => AppTextStyles.primary(this);

  /// Texto con color secundario
  TextStyle? get textSecondary => AppTextStyles.secondary(this);

  /// Texto de ayuda/hint
  TextStyle? get textHint => AppTextStyles.hint(this);

  /// Acceso rápido a las traducciones
  ///
  /// Uso: `context.l10n.miString`
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Helper para traducir errores técnicos de Firebase usando l10n.
  /// Mapea la clave técnica retornada por FirebaseErrorMapper
  /// a la propiedad correspondiente en AppLocalizations.
  String translateError(String errorKey) {
    final localizations = l10n;

    switch (errorKey) {
      case 'authErrorInvalidEmail':
        return localizations.authErrorInvalidEmail;
      case 'authErrorUserDisabled':
        return localizations.authErrorUserDisabled;
      case 'authErrorUserNotFound':
        return localizations.authErrorUserNotFound;
      case 'authErrorWrongPassword':
        return localizations.authErrorWrongPassword;
      case 'authErrorEmailAlreadyInUse':
        return localizations.authErrorEmailAlreadyInUse;
      case 'authErrorWeakPassword':
        return localizations.authErrorWeakPassword;
      case 'authErrorTooManyRequests':
        return localizations.authErrorTooManyRequests;
      case 'authErrorOperationNotAllowed':
        return localizations.authErrorOperationNotAllowed;
      case 'authErrorInvalidCredential':
        return localizations.authErrorInvalidCredential;
      case 'errorNetworkRequestFailed':
        return localizations.errorNetworkRequestFailed;
      case 'errorNoInternetConnection':
        return localizations.errorNoInternetConnection;
      case 'errorPermissionDenied':
        return localizations.errorPermissionDenied;
      case 'errorFailedPrecondition':
        return localizations.errorFailedPrecondition;
      case 'errorServiceUnavailable':
        return localizations.errorServiceUnavailable;
      case 'emailInvalidFormat':
        return localizations.emailInvalidFormat;
      case 'passwordMinLength':
        return localizations.passwordMinLength;
      case 'googleSignInError':
        return localizations.googleSignInError;
      default:
        return errorKey;
    }
  }
}

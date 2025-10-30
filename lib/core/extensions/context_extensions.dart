import 'package:flutter/material.dart';

/// Extension methods para BuildContext
///
/// Proporciona acceso rápido y conveniente a Theme, MediaQuery y otras
/// propiedades frecuentemente usadas del BuildContext.
///
/// Sprint 0 - Fase 2: Extension methods implementadas
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
}

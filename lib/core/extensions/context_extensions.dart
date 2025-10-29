import 'package:flutter/material.dart';

/// Extension methods para BuildContext
///
/// Proporciona acceso rápido y conveniente a Theme, MediaQuery y otras
/// propiedades frecuentemente usadas del BuildContext.
///
/// Sprint 0 - Fase 1: Archivo placeholder
/// TODO(Sprint 0 - Fase 2): Implementar extensions para theme y colorScheme

extension BuildContextExtensions on BuildContext {
  /// Acceso rápido al ThemeData
  ///
  /// Uso: `context.theme` en lugar de `Theme.of(context)`
  /// TODO: Implementar
  // ThemeData get theme => Theme.of(this);

  /// Acceso rápido al ColorScheme
  ///
  /// Uso: `context.colorScheme` en lugar de `Theme.of(context).colorScheme`
  /// TODO: Implementar
  // ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Acceso rápido al TextTheme
  ///
  /// Uso: `context.textTheme` en lugar de `Theme.of(context).textTheme`
  /// TODO: Implementar
  // TextTheme get textTheme => Theme.of(this).textTheme;

  /// Acceso rápido al MediaQuery
  ///
  /// Uso: `context.mediaQuery` en lugar de `MediaQuery.of(context)`
  /// TODO: Implementar
  // MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Ancho de la pantalla
  ///
  /// Uso: `context.screenWidth`
  /// TODO: Implementar
  // double get screenWidth => MediaQuery.of(this).size.width;

  /// Alto de la pantalla
  ///
  /// Uso: `context.screenHeight`
  /// TODO: Implementar
  // double get screenHeight => MediaQuery.of(this).size.height;
}

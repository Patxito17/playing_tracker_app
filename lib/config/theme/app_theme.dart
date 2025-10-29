import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

/// Configuración del tema de la aplicación Playing Tracker
///
/// Implementa Material Design 3 completo con tema claro y oscuro.
/// Utiliza ColorScheme.fromSeed para generar una paleta coherente.
///
/// Sprint 0 - Fase 1: Archivo placeholder
/// TODO(Sprint 0 - Fase 2): Implementar ThemeData completo con Material Design 3

class AppTheme {
  /// Color semilla para generar la paleta de colores
  ///
  /// Azul Material: #1E88E5
  static const Color seedColor = Color(0xFF1E88E5);

  /// Tema claro de la aplicación
  ///
  /// TODO: Implementar con ColorScheme.fromSeed, Google Fonts y tokens M3
  static ThemeData get lightTheme {
    // final colorScheme = ColorScheme.fromSeed(
    //   seedColor: seedColor,
    //   brightness: Brightness.light,
    // );
    //
    // return ThemeData(
    //   useMaterial3: true,
    //   colorScheme: colorScheme,
    //   textTheme: GoogleFonts.robotoTextTheme(),
    //   // Configuración adicional de componentes M3
    // );

    return ThemeData.light(); // Placeholder temporal
  }

  /// Tema oscuro de la aplicación
  ///
  /// TODO: Implementar con ColorScheme.fromSeed y brightness dark
  static ThemeData get darkTheme {
    // final colorScheme = ColorScheme.fromSeed(
    //   seedColor: seedColor,
    //   brightness: Brightness.dark,
    // );
    //
    // return ThemeData(
    //   useMaterial3: true,
    //   colorScheme: colorScheme,
    //   textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    //   // Configuración adicional de componentes M3
    // );

    return ThemeData.dark(); // Placeholder temporal
  }
}

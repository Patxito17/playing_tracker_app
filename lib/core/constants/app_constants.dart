import 'package:flutter/material.dart';

/// Constantes globales de la aplicación Playing Tracker
///
/// Este archivo contiene todas las constantes utilizadas en la aplicación
/// para mantener consistencia en el diseño y comportamiento.
///
/// Sprint 0 - Fase 2: Constantes implementadas

/// Constantes de espaciado
///
/// Utilizadas para mantener consistencia en el espaciado vertical y horizontal
/// en toda la aplicación. Siguen la escala estándar de Material Design 3.
class AppSpacing {
  /// Espaciado extra pequeño: 4.0
  static const double xs = 4.0;

  /// Espaciado pequeño: 8.0
  static const double s = 8.0;

  /// Espaciado medio: 16.0
  static const double m = 16.0;

  /// Espaciado grande: 24.0
  static const double l = 24.0;

  /// Espaciado extra grande: 32.0
  static const double xl = 32.0;

  /// Espaciado extra extra grande: 48.0
  static const double xxl = 48.0;
}

/// Constantes de radios de bordes
///
/// Utilizadas para mantener consistencia en el redondeo de bordes
/// en componentes como Cards, Buttons, TextFields, etc.
class AppBorderRadius {
  /// Radio pequeño: 8.0
  static const double small = 8.0;

  /// Radio medio: 12.0
  static const double medium = 12.0;

  /// Radio grande: 16.0
  static const double large = 16.0;

  /// Radio extra grande: 24.0
  static const double xlarge = 24.0;
}

/// Constantes de duraciones de animaciones
///
/// Utilizadas para mantener consistencia en las transiciones y animaciones
/// en toda la aplicación.
class AppDurations {
  /// Duración corta: 200ms
  static const Duration short = Duration(milliseconds: 200);

  /// Duración media: 300ms
  static const Duration medium = Duration(milliseconds: 300);

  /// Duración larga: 500ms
  static const Duration long = Duration(milliseconds: 500);
}

/// Constantes de colores
///
/// Colores principales de la aplicación que se utilizan para generar
/// la paleta completa de Material Design 3 mediante ColorScheme.fromSeed.
///
/// En Material Design 3, se utiliza un color semilla para generar
/// automáticamente toda la paleta de colores coherente y accesible.
class AppColors {
  /// Color semilla para generar la paleta de colores Material Design 3
  ///
  /// Azul Material: #1E88E5
  ///
  /// Este color se utiliza como base para generar toda la paleta de colores
  /// en modo claro y oscuro mediante ColorScheme.fromSeed.
  /// Material Design 3 genera automáticamente colores primarios, secundarios,
  /// de superficie, error, etc., garantizando contraste y accesibilidad.
  static const Color seedColor = Color(0xFF1E88E5);
}

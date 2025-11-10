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

/// Estilos de texto centralizados de la aplicación
///
/// Proporciona métodos estáticos para obtener estilos de texto consistentes
/// en toda la aplicación. Facilita el mantenimiento y garantiza coherencia visual.
///
/// **Ejemplo de uso:**
/// ```dart
/// Text(
///   'Título',
///   style: AppTextStyles.displaySmallBold(context),
/// )
/// ```
///
/// Sprint 0 - Mejora: Centralización de estilos de texto
class AppTextStyles {
  AppTextStyles._(); // Constructor privado para evitar instanciación

  // ============================================================================
  // TÍTULOS
  // ============================================================================

  /// Estilo para cronómetros grandes y números destacados
  ///
  /// Usa `displayLarge` con fontWeight bold y color onSurface
  static TextStyle? displayLargeBold(BuildContext context) =>
      Theme.of(context).textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Estilo para títulos principales de pantalla
  ///
  /// Usa `displaySmall` con fontWeight bold y color onSurface
  static TextStyle? displaySmallBold(BuildContext context) =>
      Theme.of(context).textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Estilo para títulos de sección
  ///
  /// Usa `headlineMedium` con fontWeight bold y color onSurface
  static TextStyle? headlineMediumBold(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Estilo para títulos de cards y contenedores
  ///
  /// Usa `titleLarge` con fontWeight bold y color onSurface
  static TextStyle? titleLargeBold(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Estilo para subtítulos destacados
  ///
  /// Usa `titleMedium` con fontWeight semibold y color onSurface
  static TextStyle? titleMediumBold(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Estilo para títulos pequeños
  ///
  /// Usa `titleSmall` con fontWeight semibold y color onSurface
  static TextStyle? titleSmallBold(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // ============================================================================
  // CUERPO - COLORES PREDETERMINADOS
  // ============================================================================

  /// Texto de cuerpo principal con color onSurface
  ///
  /// Usa `bodyLarge` con color onSurface (texto principal)
  static TextStyle? bodyLargeOnSurface(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Texto de cuerpo secundario con color onSurfaceVariant
  ///
  /// Usa `bodyLarge` con color onSurfaceVariant (texto secundario)
  static TextStyle? bodyLargeOnSurfaceVariant(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  /// Texto de cuerpo medio con color onSurface
  ///
  /// Usa `bodyMedium` con color onSurface
  static TextStyle? bodyMediumOnSurface(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Texto de cuerpo medio secundario con color onSurfaceVariant
  ///
  /// Usa `bodyMedium` con color onSurfaceVariant
  static TextStyle? bodyMediumOnSurfaceVariant(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  /// Texto pequeño con color onSurface
  ///
  /// Usa `bodySmall` con color onSurface
  static TextStyle? bodySmallOnSurface(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Texto pequeño secundario con color onSurfaceVariant
  ///
  /// Usa `bodySmall` con color onSurfaceVariant (más común)
  static TextStyle? bodySmallOnSurfaceVariant(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  /// Texto pequeño en negrita con color onSurface
  ///
  /// Usa `bodySmall` con fontWeight semibold y color onSurface
  static TextStyle? bodySmallBold(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // ============================================================================
  // CUERPO - SIN MODIFICAR COLOR (usa el del tema)
  // ============================================================================

  /// Texto de cuerpo principal sin modificar color
  ///
  /// Usa `bodyLarge` tal como está definido en el tema
  static TextStyle? bodyLarge(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge;

  /// Texto de cuerpo medio sin modificar color
  ///
  /// Usa `bodyMedium` tal como está definido en el tema
  static TextStyle? bodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;

  /// Texto pequeño sin modificar color
  ///
  /// Usa `bodySmall` tal como está definido en el tema
  static TextStyle? bodySmall(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall;

  // ============================================================================
  // ETIQUETAS Y ACCIONES
  // ============================================================================

  /// Etiqueta grande para botones y acciones principales
  ///
  /// Usa `labelLarge` tal como está definido en el tema
  static TextStyle? labelLarge(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge;

  /// Etiqueta mediana
  ///
  /// Usa `labelMedium` tal como está definido en el tema
  static TextStyle? labelMedium(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium;

  /// Etiqueta pequeña
  ///
  /// Usa `labelSmall` tal como está definido en el tema
  static TextStyle? labelSmall(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall;

  // ============================================================================
  // ESTADOS ESPECIALES
  // ============================================================================

  /// Texto de error
  ///
  /// Usa `bodyMedium` con color error
  static TextStyle? error(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error);

  /// Texto destacado con color primario
  ///
  /// Usa `bodyMedium` con color primary
  static TextStyle? primary(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyMedium
      ?.copyWith(color: Theme.of(context).colorScheme.primary);

  /// Texto con color secundario
  ///
  /// Usa `bodyMedium` con color secondary
  static TextStyle? secondary(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyMedium
      ?.copyWith(color: Theme.of(context).colorScheme.secondary);

  /// Texto de ayuda/hint
  ///
  /// Usa `bodySmall` con color onSurfaceVariant (más sutil)
  static TextStyle? hint(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';

/// Configuración del tema de la aplicación Playing Tracker
///
/// Implementa Material Design 3 completo con tema claro y oscuro.
/// Utiliza ColorScheme.fromSeed para generar una paleta coherente.
class AppTheme {
  /// Obtiene los gradientes según el brillo del tema
  static AppGradients _getGradients(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const AppGradients(
        mainBackground: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkGradientStart, AppColors.darkGradientEnd],
        ),
      );
    }
    return const AppGradients(
      mainBackground: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.gradientStart, AppColors.gradientEnd],
      ),
    );
  }

  /// Tema claro de la aplicación
  ///
  /// Implementa Material Design 3 con ColorScheme.fromSeed, Google Fonts
  /// y configuración completa de componentes M3.
  static ThemeData lightTheme([Color? seedColor]) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? AppColors.seedColor,
      brightness: Brightness.light,
    );

    final baseTextTheme = GoogleFonts.lexendTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: baseTextTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [_getGradients(Brightness.light)],

      // Configuración de InputDecoration para TextFields M3
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),

      // Configuración de Cards con elevación sutil usando surfaceTintColor
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        surfaceTintColor: colorScheme.surfaceTint,
      ),

      // Configuración de botones M3
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
        ),
      ),

      // Configuración de AppBar M3
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
      ),

      // Configuración de FloatingActionButton M3
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
      ),
    );
  }

  /// Tema oscuro de la aplicación
  ///
  /// Implementa Material Design 3 con ColorScheme.fromSeed en modo oscuro,
  /// Google Fonts y configuración completa de componentes M3.
  static ThemeData darkTheme([Color? seedColor]) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? AppColors.seedColor,
      brightness: Brightness.dark,
    );

    final baseTextTheme = GoogleFonts.lexendTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: baseTextTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [_getGradients(Brightness.dark)],

      // Configuración de InputDecoration para TextFields M3
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),

      // Configuración de Cards con elevación sutil usando surfaceTintColor
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        surfaceTintColor: colorScheme.surfaceTint,
      ),

      // Configuración de botones M3
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
        ),
      ),

      // Configuración de AppBar M3
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
      ),

      // Configuración de FloatingActionButton M3
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
      ),
    );
  }
}

/// Extensión de tema para gestionar gradientes personalizados
class AppGradients extends ThemeExtension<AppGradients> {
  final LinearGradient mainBackground;

  const AppGradients({required this.mainBackground});

  @override
  ThemeExtension<AppGradients> copyWith({LinearGradient? mainBackground}) {
    return AppGradients(mainBackground: mainBackground ?? this.mainBackground);
  }

  @override
  ThemeExtension<AppGradients> lerp(
    ThemeExtension<AppGradients>? other,
    double t,
  ) {
    if (other is! AppGradients) return this;
    return AppGradients(
      mainBackground: LinearGradient.lerp(
        mainBackground,
        other.mainBackground,
        t,
      )!,
    );
  }
}

/// Extensión para facilitar el acceso a los gradientes desde BuildContext
extension AppThemeX on BuildContext {
  AppGradients get gradients => Theme.of(this).extension<AppGradients>()!;
}

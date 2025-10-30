import 'package:flutter/material.dart';

import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';

/// Punto de entrada de la aplicación Playing Tracker
///
/// Sprint 0 - Fase 4: Integración de GoRouter para navegación
void main() {
  runApp(const PlayingTrackerApp());
}

/// Widget raíz de la aplicación
///
/// Gestiona el tema actual (claro/oscuro) y proporciona el MaterialApp.router
/// configurado con GoRouter y los temas de Material Design 3.
class PlayingTrackerApp extends StatefulWidget {
  const PlayingTrackerApp({super.key});

  @override
  State<PlayingTrackerApp> createState() => _PlayingTrackerAppState();
}

class _PlayingTrackerAppState extends State<PlayingTrackerApp> {
  /// Modo de tema actual (claro u oscuro)
  ///
  /// Por defecto usa el tema del sistema. En futuros sprints se implementará
  /// un sistema de configuración persistente usando SharedPreferences o similar.
  final ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Playing Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

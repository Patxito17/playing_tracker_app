import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'firebase_options.dart';

/// Punto de entrada de la aplicación Playing Tracker
///
/// Fase 1 - Inicialización: Firebase + HydratedBloc
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Inicializar Firebase primero (usar las opciones generadas por FlutterFire)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2) Construir HydratedStorage (usa ruta por defecto si no se pasa directory)
  //    Nota: algunas versiones de hydrated_bloc aceptan una sobrecarga sin parámetros.
  // Construir HydratedStorage usando HydratedStorageDirectory según la API
  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );

  // Asignar storage globalmente y ejecutar la app
  HydratedBloc.storage = storage;
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

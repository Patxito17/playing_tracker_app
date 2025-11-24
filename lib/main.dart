import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'core/config/bloc/app_bloc_observer.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
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
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );

  // Asignar storage globalmente y ejecutar la app
  HydratedBloc.storage = storage;
  Bloc.observer = AppBlocObserver();
  runApp(const PlayingTrackerApp());
}

/// Widget raíz de la aplicación
///
/// Gestiona el tema actual (claro/oscuro) y proporciona el MaterialApp.router
/// configurado con GoRouter y los temas de Material Design 3.
class PlayingTrackerApp extends StatefulWidget {
  const PlayingTrackerApp({
    super.key,
    this.authRepository,
    this.authCubitBuilder,
  });

  /// Permite inyectar un repositorio custom (por ejemplo en tests).
  final AuthRepository? authRepository;

  /// Builder opcional para crear el [AuthCubit] con configuraciones especiales.
  final AuthCubit Function(AuthRepository repository)? authCubitBuilder;

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
    final repository = widget.authRepository ?? AuthRepositoryImpl();

    return RepositoryProvider<AuthRepository>.value(
      value: repository,
      child: BlocProvider(
        create: (_) =>
            widget.authCubitBuilder?.call(repository) ?? AuthCubit(repository),
        child: Builder(
          builder: (context) {
            final authCubit = context.read<AuthCubit>();
            final appRoutes = AppRoutes(authCubit);

            return MaterialApp.router(
              title: 'Playing Tracker',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _themeMode,
              routerConfig: appRoutes.router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}

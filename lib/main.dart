import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:playing_tracker/features/settings/data/services/settings_service.dart';
import 'package:playing_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:playing_tracker/features/settings/presentation/cubit/settings_state.dart';

import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'core/config/bloc/app_bloc_observer.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/classes/data/repositories/class_repository_impl.dart';
import 'features/classes/domain/repositories/class_repository.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

/// Punto de entrada de la aplicación Playing Tracker
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Inicializar Firebase primero
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2) Construir HydratedStorage
  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );

  // 3) Inicializar SettingsService
  final settingsService = await SettingsService.init();

  // Asignar storage globalmente y ejecutar la app
  HydratedBloc.storage = storage;
  Bloc.observer = AppBlocObserver();
  runApp(PlayingTrackerApp(settingsService: settingsService));
}

/// Widget raíz de la aplicación
class PlayingTrackerApp extends StatefulWidget {
  const PlayingTrackerApp({
    super.key,
    required this.settingsService,
    this.authRepository,
    this.authCubitBuilder,
    this.classRepository,
    this.taskRepository,
  });

  final SettingsService settingsService;
  final AuthRepository? authRepository;
  final AuthCubit Function(AuthRepository repository)? authCubitBuilder;
  final ClassRepository? classRepository;
  final TaskRepository? taskRepository;

  @override
  State<PlayingTrackerApp> createState() => _PlayingTrackerAppState();
}

class _PlayingTrackerAppState extends State<PlayingTrackerApp> {
  @override
  Widget build(BuildContext context) {
    final repository = widget.authRepository ?? AuthRepositoryImpl();
    final classRepository = widget.classRepository ?? ClassRepositoryImpl();
    final taskRepository = widget.taskRepository ?? TaskRepositoryImpl();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: repository),
        RepositoryProvider<ClassRepository>.value(value: classRepository),
        RepositoryProvider<TaskRepository>.value(value: taskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                widget.authCubitBuilder?.call(repository) ??
                AuthCubit(repository),
          ),
          BlocProvider(create: (_) => SettingsCubit(widget.settingsService)),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return Builder(
              builder: (context) {
                final authCubit = context.read<AuthCubit>();
                final appRoutes = AppRoutes(authCubit);

                final lightTheme = AppTheme.lightTheme;
                final darkTheme = AppTheme.darkTheme;

                // Si hay color semilla personalizado, regenerar temas
                // Nota: Por simplicidad, AppTheme.lightTheme es estático ahora.
                // Si implementamos color personalizado real, deberíamos hacer AppTheme.fromSeed(color).

                // Aplicar color personalizado si existe
                final effectiveLight = settingsState.seedColor != null
                    ? ThemeData(
                        useMaterial3: true,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: settingsState.seedColor!,
                          brightness: Brightness.light,
                        ),
                      )
                    : lightTheme;

                final effectiveDark = settingsState.seedColor != null
                    ? ThemeData(
                        useMaterial3: true,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: settingsState.seedColor!,
                          brightness: Brightness.dark,
                        ),
                      )
                    : darkTheme;

                return MaterialApp.router(
                  title: 'Playing Tracker',
                  theme: effectiveLight,
                  darkTheme: effectiveDark,
                  themeMode: settingsState.themeMode,
                  locale: settingsState.locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  routerConfig: appRoutes.router,
                  debugShowCheckedModeBanner: false,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

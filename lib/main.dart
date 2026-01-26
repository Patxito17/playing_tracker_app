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
  late final AuthRepository _authRepository;
  late final ClassRepository _classRepository;
  late final TaskRepository _taskRepository;
  late final AuthCubit _authCubit;
  late final SettingsCubit _settingsCubit;
  late final AppRoutes _appRoutes;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? AuthRepositoryImpl();
    _classRepository = widget.classRepository ?? ClassRepositoryImpl();
    _taskRepository = widget.taskRepository ?? TaskRepositoryImpl();

    _authCubit =
        widget.authCubitBuilder?.call(_authRepository) ??
        AuthCubit(_authRepository);
    _settingsCubit = SettingsCubit(widget.settingsService);
    _appRoutes = AppRoutes(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _settingsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _classRepository),
        RepositoryProvider.value(value: _taskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authCubit),
          BlocProvider.value(value: _settingsCubit),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final lightTheme = AppTheme.lightTheme;
            final darkTheme = AppTheme.darkTheme;

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
              routerConfig: _appRoutes.router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}

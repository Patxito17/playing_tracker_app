# Plan: Automatización de Capturas y Subida a Stores

> **Para workers agénticos:** USA superpowers:subagent-driven-development (si hay subagentes disponibles) o superpowers:executing-plans para implementar este plan. Los pasos usan sintaxis de checkbox (`- [ ]`) para seguimiento.

**Objetivo:** Automatizar la generación de screenshots de la app (EN + ES, dos roles) y la subida de metadatos + capturas a App Store Connect y Google Play Console.

**Arquitectura:** Se añade un `ScreenshotApp` (sin Firebase, basado en la `_TestApp` de integration_test existente) que navega por las pantallas clave con datos mock realistas. Un script shell extrae las capturas del simulador/emulador. Fastlane (`deliver` + `supply`) gestiona la subida de metadatos y screenshots a las stores.

**Tech Stack:** Flutter integration_test, Fastlane (Ruby/Bundler), App Store Connect API, Google Play Developer API, xcrun simctl (iOS), adb (Android), path_provider

---

## Identificadores de la app

- **iOS Bundle ID:** `com.gabriom.playingtrackerapp`
- **Android Package:** `com.gabriom.playingtrackerapp`
- **Locales a cubrir:** `en-US` (inglés), `es-ES` (español)
- **Dispositivos objetivo:**
  - iOS: iPhone 15 Pro Max (6.7" → válido para categoría 6.9" en App Store 2024+)
  - Android: Pixel 7 Pro (emulador)

---

## Mapa de archivos

### Nuevos archivos

| Archivo | Responsabilidad |
|---|---|
| `integration_test/screenshots_test.dart` | Test que navega la app (student + teacher) y llama `takeScreenshot()` |
| `integration_test/helpers/screenshot_helper.dart` | Utilidad para capturar y guardar screenshots en el dispositivo |
| `integration_test/helpers/screenshot_mock_data.dart` | Datos mock realistas (nombre, sesiones, tareas, clases) para screenshots |
| `scripts/screenshots_ios.sh` | Ejecuta el test en simulador iOS y extrae los PNGs |
| `scripts/screenshots_android.sh` | Ejecuta el test en emulador Android y extrae los PNGs |
| `fastlane/Gemfile` | Dependencias Ruby (fastlane) |
| `fastlane/Gemfile.lock` | Lock de versiones Ruby |
| `fastlane/Appfile` | Bundle ID + Apple ID + package name Android |
| `fastlane/Fastfile` | Lanes: `ios upload`, `android upload`, `all upload` |
| `fastlane/Deliverfile` | Configuración deliver (iOS) |
| `fastlane/metadata/en-US/name.txt` | Nombre de la app en inglés |
| `fastlane/metadata/en-US/subtitle.txt` | Subtítulo (App Store) en inglés |
| `fastlane/metadata/en-US/description.txt` | Descripción larga en inglés |
| `fastlane/metadata/en-US/keywords.txt` | Keywords para App Store en inglés |
| `fastlane/metadata/en-US/release_notes.txt` | Notas de versión en inglés |
| `fastlane/metadata/en-US/privacy_url.txt` | URL política de privacidad |
| `fastlane/metadata/en-US/support_url.txt` | URL soporte |
| `fastlane/metadata/es-ES/` | Mismo conjunto en español |
| `fastlane/metadata/android/en-US/` | Metadatos Play Store en inglés |
| `fastlane/metadata/android/es-ES/` | Metadatos Play Store en español |
| `docs/STORE_RELEASE.md` | Guía paso a paso de cómo hacer un release completo |

### Archivos modificados

| Archivo | Cambio |
|---|---|
| `.gitignore` | Añadir archivos sensibles de Fastlane y screenshots generadas |
| `Makefile` | Añadir targets: `screenshots-ios`, `screenshots-android`, `store-upload-ios`, `store-upload-android` |
| `pubspec.yaml` | Añadir `path_provider` si no está ya |

### Archivos NO incluidos en git (`.gitignore`)

```
fastlane/.env
fastlane/.env.*
fastlane/AuthKey_*.p8          # App Store Connect API key (privada)
fastlane/gc_keys.json          # Google Play service account (privada)
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/          # Binarios grandes, se regeneran
fastlane/test_output/
```

---

## Tarea 1: Actualizar .gitignore

**Archivos:**
- Modificar: `.gitignore`

- [ ] **Paso 1.1: Leer el .gitignore actual**

```bash
cat .gitignore
```

- [ ] **Paso 1.2: Añadir bloque Fastlane**

Añadir al final del `.gitignore`:

```gitignore
# ==========================================
# Fastlane - Automatización de Stores
# ==========================================

# Claves de API (NUNCA publicar)
fastlane/AuthKey_*.p8
fastlane/gc_keys.json
fastlane/.env
fastlane/.env.*

# Archivos generados por fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/test_output/

# Screenshots generadas (binarios grandes, se regeneran antes de cada subida)
fastlane/screenshots/
```

- [ ] **Paso 1.3: Verificar que el .gitignore es correcto**

```bash
git check-ignore -v fastlane/AuthKey_XXXXXX.p8 fastlane/gc_keys.json
```

Esperado: ambas líneas con `fastlane/.gitignore` o `.gitignore`

- [ ] **Paso 1.4: Commit**

```bash
git add .gitignore
git commit -m "chore: add fastlane sensitive files to .gitignore"
```

---

## Tarea 2: Instalar Fastlane con Bundler

**Archivos:**
- Crear: `fastlane/Gemfile`
- Crear: `fastlane/Gemfile.lock` (generado automáticamente)

**Prerrequisito:** Ruby instalado (`ruby --version`). Si no, instalar con `rbenv install 3.2.0`.

- [ ] **Paso 2.1: Crear `fastlane/Gemfile`**

```ruby
# fastlane/Gemfile
source "https://rubygems.org"

gem "fastlane"
```

- [ ] **Paso 2.2: Instalar dependencias**

```bash
cd fastlane && bundle install && cd ..
```

Esperado: `Bundle complete!` con fastlane instalado.

- [ ] **Paso 2.3: Verificar instalación**

```bash
cd fastlane && bundle exec fastlane --version && cd ..
```

Esperado: `fastlane 2.x.x`

- [ ] **Paso 2.4: Crear `fastlane/Appfile`**

```ruby
# fastlane/Appfile
app_identifier("com.gabriom.playingtrackerapp")
apple_id("TU_APPLE_ID@email.com")  # Reemplazar con el Apple ID real

# Android
json_key_file("fastlane/gc_keys.json")
package_name("com.gabriom.playingtrackerapp")
```

> **ACCIÓN REQUERIDA:** Reemplazar `TU_APPLE_ID@email.com` con el Apple ID real de la cuenta de desarrollador.

- [ ] **Paso 2.5: Commit**

```bash
git add fastlane/Gemfile fastlane/Gemfile.lock fastlane/Appfile
git commit -m "chore: add fastlane with Bundler setup"
```

---

## Tarea 3: Metadatos de la app en inglés

**Archivos:**
- Crear: `fastlane/metadata/en-US/name.txt`
- Crear: `fastlane/metadata/en-US/subtitle.txt`
- Crear: `fastlane/metadata/en-US/description.txt`
- Crear: `fastlane/metadata/en-US/keywords.txt`
- Crear: `fastlane/metadata/en-US/release_notes.txt`
- Crear: `fastlane/metadata/en-US/privacy_url.txt`
- Crear: `fastlane/metadata/en-US/support_url.txt`
- Crear: `fastlane/metadata/android/en-US/title.txt`
- Crear: `fastlane/metadata/android/en-US/short_description.txt`
- Crear: `fastlane/metadata/android/en-US/full_description.txt`

- [ ] **Paso 3.1: Crear estructura de directorios**

```bash
mkdir -p fastlane/metadata/en-US
mkdir -p fastlane/metadata/android/en-US
```

- [ ] **Paso 3.2: `fastlane/metadata/en-US/name.txt`**

```
Playing Tracker
```

- [ ] **Paso 3.3: `fastlane/metadata/en-US/subtitle.txt`** (máx. 30 caracteres)

```
Music practice made simple
```

- [ ] **Paso 3.4: `fastlane/metadata/en-US/description.txt`** (máx. 4000 caracteres)

```
Playing Tracker is the music practice companion for students and teachers.

FOR STUDENTS:
• Log and track your daily practice sessions with ease
• See your weekly progress at a glance with beautiful statistics
• Manage your assigned tasks from your teacher
• Stay motivated with streaks and progress charts

FOR TEACHERS:
• Manage multiple students and classes from one place
• Assign practice tasks and track completion
• Monitor each student's practice hours and progress
• Send feedback and keep students on track

Whether you're a student learning an instrument or a teacher guiding the next generation of musicians, Playing Tracker keeps practice organized and progress visible.

Simple, clean, and built for musicians.
```

- [ ] **Paso 3.5: `fastlane/metadata/en-US/keywords.txt`** (máx. 100 caracteres, separado por comas)

```
music practice,practice tracker,music student,music teacher,instrument practice
```

- [ ] **Paso 3.6: `fastlane/metadata/en-US/release_notes.txt`**

```
• Improved performance and stability
• Bug fixes and UI improvements
```

> **NOTA:** Actualizar este archivo antes de cada release con los cambios reales.

- [ ] **Paso 3.7: `fastlane/metadata/en-US/privacy_url.txt`**

```
https://TU_DOMINIO.com/privacy
```

> **ACCIÓN REQUERIDA:** Reemplazar con la URL real de la política de privacidad.

- [ ] **Paso 3.8: `fastlane/metadata/en-US/support_url.txt`**

```
https://TU_DOMINIO.com/support
```

- [ ] **Paso 3.9: Metadatos Android en inglés**

`fastlane/metadata/android/en-US/title.txt`:
```
Playing Tracker
```

`fastlane/metadata/android/en-US/short_description.txt` (máx. 80 caracteres):
```
Track music practice sessions for students and teachers
```

`fastlane/metadata/android/en-US/full_description.txt` (máx. 4000 caracteres):
```
Playing Tracker is the music practice companion for students and teachers.

FOR STUDENTS:
• Log and track your daily practice sessions with ease
• See your weekly progress at a glance with beautiful statistics
• Manage your assigned tasks from your teacher
• Stay motivated with progress charts

FOR TEACHERS:
• Manage multiple students and classes from one place
• Assign practice tasks and track completion
• Monitor each student's practice hours and progress

Simple, clean, and built for musicians.
```

- [ ] **Paso 3.10: Commit**

```bash
git add fastlane/metadata/
git commit -m "chore: add App Store and Play Store metadata in English"
```

---

## Tarea 4: Metadatos de la app en español

**Archivos:**
- Crear: `fastlane/metadata/es-ES/` (mismo conjunto que en-US)
- Crear: `fastlane/metadata/android/es-ES/`

- [ ] **Paso 4.1: Crear estructura de directorios**

```bash
mkdir -p fastlane/metadata/es-ES
mkdir -p fastlane/metadata/android/es-ES
```

- [ ] **Paso 4.2: `fastlane/metadata/es-ES/name.txt`**

```
Playing Tracker
```

- [ ] **Paso 4.3: `fastlane/metadata/es-ES/subtitle.txt`**

```
Práctica musical al detalle
```

- [ ] **Paso 4.4: `fastlane/metadata/es-ES/description.txt`**

```
Playing Tracker es el compañero de práctica musical para estudiantes y profesores.

PARA ESTUDIANTES:
• Registra y sigue tus sesiones de práctica diaria con facilidad
• Consulta tu progreso semanal de un vistazo con estadísticas visuales
• Gestiona las tareas asignadas por tu profesor
• Mantén la motivación con gráficas de progreso

PARA PROFESORES:
• Gestiona varios estudiantes y clases desde un solo lugar
• Asigna tareas de práctica y controla su cumplimiento
• Supervisa las horas de práctica y el progreso de cada estudiante
• Mantén a tus alumnos encaminados con seguimiento detallado

Tanto si eres un estudiante aprendiendo un instrumento como si eres un profesor guiando a músicos del futuro, Playing Tracker mantiene la práctica organizada y el progreso visible.

Simple, limpio y construido para músicos.
```

- [ ] **Paso 4.5: `fastlane/metadata/es-ES/keywords.txt`**

```
práctica musical,seguimiento música,estudiante música,profesor música,instrumento
```

- [ ] **Paso 4.6: `fastlane/metadata/es-ES/release_notes.txt`**

```
• Mejoras de rendimiento y estabilidad
• Corrección de errores y mejoras de interfaz
```

- [ ] **Paso 4.7: `fastlane/metadata/es-ES/privacy_url.txt` y `support_url.txt`**

Iguales que en en-US (misma URL para ambos idiomas).

- [ ] **Paso 4.8: Metadatos Android en español**

`fastlane/metadata/android/es-ES/title.txt`:
```
Playing Tracker
```

`fastlane/metadata/android/es-ES/short_description.txt`:
```
Registra sesiones de práctica musical para alumnos y profesores
```

`fastlane/metadata/android/es-ES/full_description.txt`:
Igual que la descripción de App Store en español.

- [ ] **Paso 4.9: Commit**

```bash
git add fastlane/metadata/
git commit -m "chore: add App Store and Play Store metadata in Spanish"
```

---

## Tarea 5: Datos mock realistas para screenshots

**Archivos:**
- Crear: `integration_test/helpers/screenshot_mock_data.dart`

Los datos mock existentes en `app_test.dart` usan datos vacíos/mínimos. Para screenshots necesitamos datos realistas que hagan las pantallas parecer vivas.

- [ ] **Paso 5.1: Revisar los modelos disponibles**

```bash
# Ver modelos de sesión, tarea, clase, estadísticas
find lib/features -name "*model*" -type f | head -20
```

- [ ] **Paso 5.2: Revisar `test/helpers/user_test_helpers.dart`**

Leer el archivo para ver los helpers existentes y no duplicar.

- [ ] **Paso 5.3: Crear `integration_test/helpers/screenshot_mock_data.dart`**

Este archivo centraliza datos mock realistas para el test de screenshots. Ejemplo de estructura (adaptar a los modelos reales del proyecto):

```dart
// integration_test/helpers/screenshot_mock_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_assignment_model.dart';

// Importar otros modelos necesarios según el proyecto

/// Datos mock con aspecto realista para screenshots de la App Store.
/// No conectan a Firebase. Solo para uso en integration_test/screenshots_test.dart.
class ScreenshotMockData {
  // Progreso de estudiante con datos realistas
  static StudentProgressModel get studentProgress => const StudentProgressModel(
        studentId: 'student-screenshot',
        studentName: 'Ana García',
        totalDuration: 7200, // 2 horas en segundos
        totalSessions: 12,
        totalTasks: 8,
        completedTasks: 6,
      );

  // Estadísticas semanales con datos realistas
  static WeeklyStatsModel get weeklyStats => WeeklyStatsModel(
        weekStart: Timestamp.fromDate(DateTime(2026, 3, 11)),
        weekEnd: Timestamp.fromDate(DateTime(2026, 3, 17)),
        totalDuration: 5400, // 90 minutos
        totalSessions: 5,
        uniqueTasks: 3,
      );

  // Lista de sesiones recientes
  // NOTA: Adaptar SessionModel según los campos reales del proyecto
  static List<dynamic> get recentSessions => [
        // Añadir instancias de SessionModel cuando se lean los modelos reales
      ];

  // Lista de tareas asignadas
  // NOTA: Adaptar TaskAssignmentModel según los campos reales del proyecto
  static List<dynamic> get assignedTasks => [
        // Añadir instancias de TaskAssignmentModel cuando se lean los modelos reales
      ];
}
```

> **NOTA:** Completar los modelos de sesiones y tareas leyendo los archivos de domain/models antes de implementar. Los modelos con `@freezed` / `@JsonSerializable` tienen constructores específicos.

- [ ] **Paso 5.4: Commit**

```bash
git add integration_test/helpers/screenshot_mock_data.dart
git commit -m "test: add realistic mock data for App Store screenshots"
```

---

## Tarea 6: Helper para captura y guardado de screenshots

**Archivos:**
- Crear: `integration_test/helpers/screenshot_helper.dart`
- Modificar: `pubspec.yaml` (añadir `path_provider` si no está)

- [ ] **Paso 6.1: Verificar si path_provider ya está en pubspec.yaml**

```bash
grep "path_provider" pubspec.yaml
```

Si no está: añadirlo en `dependencies:`:
```yaml
path_provider: ^2.1.0
```
Y ejecutar `flutter pub get`.

- [ ] **Paso 6.2: Crear `integration_test/helpers/screenshot_helper.dart`**

```dart
// integration_test/helpers/screenshot_helper.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Captura un screenshot de la pantalla actual y lo guarda en el directorio
/// de documentos de la app con el nombre [filename].
///
/// Convención de nombres: `NN_nombre_pantalla_locale` (ej: `01_login_en`)
///
/// Los archivos se guardan en:
/// - iOS Simulator: <app_container>/Documents/screenshots/
/// - Android Emulator: <app_files>/screenshots/
///
/// Recuperar después del test con los scripts en scripts/screenshots_*.sh
Future<void> captureScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String filename,
) async {
  // Esperar que la UI esté completamente renderizada
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // Capturar screenshot (devuelve Uint8List con los bytes PNG)
  final bytes = await binding.takeScreenshot(filename);

  // Obtener directorio de almacenamiento accesible
  final docsDir = await getApplicationDocumentsDirectory();
  final screenshotsDir = Directory('${docsDir.path}/screenshots');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync(recursive: true);
  }

  // Guardar archivo PNG
  final file = File('${screenshotsDir.path}/$filename.png');
  await file.writeAsBytes(bytes);

  // ignore: avoid_print
  print('[SCREENSHOT] Guardado: ${file.path}');
}
```

- [ ] **Paso 6.3: Verificar que el helper compila**

```bash
flutter analyze integration_test/helpers/screenshot_helper.dart
```

Esperado: sin errores.

- [ ] **Paso 6.4: Commit**

```bash
git add integration_test/helpers/screenshot_helper.dart pubspec.yaml pubspec.lock
git commit -m "test: add screenshot capture helper for App Store automation"
```

---

## Tarea 7: Test principal de screenshots

**Archivos:**
- Crear: `integration_test/screenshots_test.dart`

Este es el test central. Reutiliza la infraestructura de `_TestApp` de `app_test.dart` pero con datos realistas y llamadas a `captureScreenshot()`. Captura screenshots de ambos roles (student + teacher) y ambos locales (en + es).

- [ ] **Paso 7.1: Leer `integration_test/app_test.dart` y `integration_test/helpers/e2e_test_helpers.dart`**

Para entender exactamente qué mocks necesitan configurarse (ya los conocemos del análisis previo).

- [ ] **Paso 7.2: Crear `integration_test/screenshots_test.dart`**

```dart
// integration_test/screenshots_test.dart
//
// Test de screenshots para App Store y Google Play Store.
//
// Cómo ejecutar:
//   iOS:     flutter test integration_test/screenshots_test.dart -d "iPhone 15 Pro Max"
//   Android: flutter test integration_test/screenshots_test.dart -d emulator-5554
//
// Los screenshots se guardan en el directorio Documents de la app.
// Usar scripts/screenshots_ios.sh o scripts/screenshots_android.sh para extraerlos.
//
// ignore_for_file: avoid_print

import 'dart:ui';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

// Importar las mismas clases que app_test.dart
import 'package:playing_tracker/config/routes/app_routes.dart';
import 'package:playing_tracker/config/theme/app_theme.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';
import 'package:playing_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:playing_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:playing_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';
import 'package:playing_tracker/l10n/l10n.dart';

import '../test/helpers/mock_hydrated_storage.dart';
import '../test/helpers/user_test_helpers.dart';
import 'helpers/screenshot_helper.dart';
import 'helpers/screenshot_mock_data.dart';

// ---------------------------------------------------------------------------
// Mocks (reutilizar los mismos de app_test.dart)
// ---------------------------------------------------------------------------

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}
class _MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}
class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockClassRepository extends Mock implements ClassRepository {}
class _MockTaskRepository extends Mock implements TaskRepository {}
class _MockSessionRepository extends Mock implements SessionRepository {}
class _MockStatisticsRepository extends Mock implements StatisticsRepository {}

// ---------------------------------------------------------------------------
// App de prueba con locale configurable
// ---------------------------------------------------------------------------

class _ScreenshotApp extends StatefulWidget {
  const _ScreenshotApp({
    required this.authCubit,
    required this.settingsCubit,
    required this.authRepository,
    required this.classRepository,
    required this.taskRepository,
    required this.sessionRepository,
    required this.statisticsRepository,
    required this.locale,
  });

  final AuthCubit authCubit;
  final SettingsCubit settingsCubit;
  final AuthRepository authRepository;
  final ClassRepository classRepository;
  final TaskRepository taskRepository;
  final SessionRepository sessionRepository;
  final StatisticsRepository statisticsRepository;
  final Locale locale;

  @override
  State<_ScreenshotApp> createState() => _ScreenshotAppState();
}

class _ScreenshotAppState extends State<_ScreenshotApp> {
  late final AppRoutes _appRoutes;

  @override
  void initState() {
    super.initState();
    _appRoutes = AppRoutes(widget.authCubit);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
        RepositoryProvider<ClassRepository>.value(value: widget.classRepository),
        RepositoryProvider<TaskRepository>.value(value: widget.taskRepository),
        RepositoryProvider<SessionRepository>.value(value: widget.sessionRepository),
        RepositoryProvider<StatisticsRepository>.value(value: widget.statisticsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: widget.authCubit),
          BlocProvider<SettingsCubit>.value(value: widget.settingsCubit),
        ],
        child: MaterialApp.router(
          title: 'Playing Tracker',
          theme: AppTheme.lightTheme(null),
          darkTheme: AppTheme.darkTheme(null),
          themeMode: ThemeMode.light,
          locale: widget.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          routerConfig: _appRoutes.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers para configurar mocks con datos realistas
// ---------------------------------------------------------------------------

void _setupRealisticMocks({
  required _MockSettingsCubit settingsCubit,
  required _MockSessionRepository sessionRepository,
  required _MockTaskRepository taskRepository,
  required _MockStatisticsRepository statisticsRepository,
}) {
  const settingsState = SettingsState(
    themeMode: ThemeMode.light,
    studentTutorialDone: true,
    teacherTutorialDone: true,
  );
  when(() => settingsCubit.state).thenReturn(settingsState);
  when(() => settingsCubit.stream).thenAnswer((_) => const Stream.empty());

  when(
    () => sessionRepository.watchWeeklySessions(
      studentId: any(named: 'studentId'),
      startDate: any(named: 'startDate'),
      endDate: any(named: 'endDate'),
    ),
  ).thenAnswer((_) => Stream.value([])); // TODO: usar ScreenshotMockData.recentSessions

  when(
    () => sessionRepository.watchStudentSessions(
      studentId: any(named: 'studentId'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) => Stream.value([]));

  when(
    () => taskRepository.watchStudentAssignments(any()),
  ).thenAnswer((_) => Stream.value([]));

  when(
    () => statisticsRepository.getStudentProgress(
      studentId: any(named: 'studentId'),
      forceRefresh: any(named: 'forceRefresh'),
    ),
  ).thenAnswer((_) async => ScreenshotMockData.studentProgress);

  when(
    () => statisticsRepository.getStudentStats(
      studentId: any(named: 'studentId'),
      timeFilter: any(named: 'timeFilter'),
      classId: any(named: 'classId'),
      forceRefresh: any(named: 'forceRefresh'),
    ),
  ).thenAnswer((_) async => ScreenshotMockData.weeklyStats);
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Locales a cubrir
  const locales = [Locale('en'), Locale('es')];
  const localeNames = {'en': 'en', 'es': 'es'};

  for (final locale in locales) {
    final localeName = localeNames[locale.languageCode]!;

    group('Screenshots - $localeName', () {
      late _MockAuthCubit mockAuthCubit;
      late _MockSettingsCubit mockSettingsCubit;
      late _MockAuthRepository mockAuthRepository;
      late _MockClassRepository mockClassRepository;
      late _MockTaskRepository mockTaskRepository;
      late _MockSessionRepository mockSessionRepository;
      late _MockStatisticsRepository mockStatisticsRepository;

      setUp(() {
        initHydratedStorage();
        mockAuthCubit = _MockAuthCubit();
        mockSettingsCubit = _MockSettingsCubit();
        mockAuthRepository = _MockAuthRepository();
        mockClassRepository = _MockClassRepository();
        mockTaskRepository = _MockTaskRepository();
        mockSessionRepository = _MockSessionRepository();
        mockStatisticsRepository = _MockStatisticsRepository();

        _setupRealisticMocks(
          settingsCubit: mockSettingsCubit,
          sessionRepository: mockSessionRepository,
          taskRepository: mockTaskRepository,
          statisticsRepository: mockStatisticsRepository,
        );
      });

      // ── STUDENT SCREENSHOTS ──────────────────────────────────────────────

      testWidgets(
        '01_login - Pantalla de bienvenida',
        (tester) async {
          when(() => mockAuthCubit.state).thenReturn(const AuthUnauthenticated());
          when(() => mockAuthCubit.stream)
              .thenAnswer((_) => Stream.value(const AuthUnauthenticated()));

          await tester.pumpWidget(_ScreenshotApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
            locale: locale,
          ));

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          await captureScreenshot(binding, tester, '01_login_$localeName');
          print('[SCREENSHOT] ✅ 01_login_$localeName');
        },
      );

      testWidgets(
        '02_student_home - Dashboard del estudiante',
        (tester) async {
          final student = createMockStudent();
          final state = AuthAuthenticated(user: student);
          when(() => mockAuthCubit.state).thenReturn(state);
          when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.value(state));

          await tester.pumpWidget(_ScreenshotApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
            locale: locale,
          ));

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          await captureScreenshot(binding, tester, '02_student_home_$localeName');
          print('[SCREENSHOT] ✅ 02_student_home_$localeName');
        },
      );

      testWidgets(
        '03_student_statistics - Estadísticas del estudiante',
        (tester) async {
          final student = createMockStudent();
          final state = AuthAuthenticated(user: student);
          when(() => mockAuthCubit.state).thenReturn(state);
          when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.value(state));

          await tester.pumpWidget(_ScreenshotApp(
            authCubit: mockAuthCubit,
            settingsCubit: mockSettingsCubit,
            authRepository: mockAuthRepository,
            classRepository: mockClassRepository,
            taskRepository: mockTaskRepository,
            sessionRepository: mockSessionRepository,
            statisticsRepository: mockStatisticsRepository,
            locale: locale,
          ));

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          // Navegar al tab de Estadísticas
          final statsTabLabel = locale.languageCode == 'es' ? 'Estadísticas' : 'Statistics';
          final statsTab = find.text(statsTabLabel);
          if (statsTab.evaluate().isNotEmpty) {
            await tester.tap(statsTab);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 500));
          }

          await captureScreenshot(binding, tester, '03_student_stats_$localeName');
          print('[SCREENSHOT] ✅ 03_student_stats_$localeName');
        },
      );

      // Añadir más pantallas según sea necesario:
      // 04_teacher_home, 05_session_detail, 06_tasks, 07_settings
      // Seguir el mismo patrón para cada una.
    });
  }
}
```

> **NOTA:** Las etiquetas de los tabs dependen de las traducciones reales en `app_en.arb` y `app_es.arb`. Verificar los strings exactos antes de implementar.

- [ ] **Paso 7.3: Verificar que compila**

```bash
flutter analyze integration_test/screenshots_test.dart
```

Esperado: sin errores (puede haber warnings de imports no usados, corregir).

- [ ] **Paso 7.4: Ejecutar el test en simulador iOS para verificar**

```bash
# Listar simuladores disponibles
xcrun simctl list devices | grep "iPhone 15 Pro Max"

# Arrancar simulador si no está corriendo
open -a Simulator

# Ejecutar test
flutter test integration_test/screenshots_test.dart -d "iPhone 15 Pro Max"
```

Esperado: todos los tests pasan. Los prints `[SCREENSHOT] ✅` confirman que se guardaron.

- [ ] **Paso 7.5: Commit**

```bash
git add integration_test/screenshots_test.dart
git commit -m "test: add screenshots integration test for App Store and Play Store"
```

---

## Tarea 8: Scripts de extracción de screenshots

**Archivos:**
- Crear: `scripts/screenshots_ios.sh`
- Crear: `scripts/screenshots_android.sh`

- [ ] **Paso 8.1: Crear directorio scripts**

```bash
mkdir -p scripts
```

- [ ] **Paso 8.2: Crear `scripts/screenshots_ios.sh`**

```bash
#!/bin/bash
# scripts/screenshots_ios.sh
#
# Genera screenshots en el simulador iOS y los organiza para Fastlane.
#
# Uso:
#   ./scripts/screenshots_ios.sh
#
# Prerequisitos:
#   - Xcode instalado con simuladores iOS
#   - Flutter configurado
#   - Simulador "iPhone 15 Pro Max" disponible

set -e

BUNDLE_ID="com.gabriom.playingtrackerapp"
DEVICE_NAME="iPhone 15 Pro Max"
OUTPUT_DIR="fastlane/screenshots"

echo "📱 Generando screenshots para iOS..."
echo "   Dispositivo: $DEVICE_NAME"
echo "   Bundle ID:   $BUNDLE_ID"

# Arrancar simulador si no está corriendo
BOOTED=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep "Booted" | wc -l)
if [ "$BOOTED" -eq 0 ]; then
  echo "▶️  Arrancando simulador $DEVICE_NAME..."
  DEVICE_UDID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -E "([0-9A-F-]{36})" -o | head -1)
  xcrun simctl boot "$DEVICE_UDID"
  sleep 5
fi

# Ejecutar tests de screenshot
echo "🧪 Ejecutando integration tests..."
flutter test integration_test/screenshots_test.dart -d "$DEVICE_NAME"

echo "📂 Extrayendo screenshots del simulador..."

# Localizar el contenedor de datos de la app en el simulador
APP_CONTAINER=$(xcrun simctl get_app_container booted "$BUNDLE_ID" data 2>/dev/null || echo "")

if [ -z "$APP_CONTAINER" ]; then
  echo "❌ Error: No se encontró el contenedor de la app."
  echo "   Asegúrate de que la app se instaló correctamente durante el test."
  exit 1
fi

SCREENSHOTS_IN_APP="$APP_CONTAINER/Documents/screenshots"

if [ ! -d "$SCREENSHOTS_IN_APP" ]; then
  echo "❌ Error: No se encontró el directorio de screenshots en la app."
  echo "   Ruta buscada: $SCREENSHOTS_IN_APP"
  exit 1
fi

# Organizar screenshots por locale para Fastlane
# Fastlane espera: fastlane/screenshots/<locale>/<device>/<filename>.png

for FILE in "$SCREENSHOTS_IN_APP"/*.png; do
  FILENAME=$(basename "$FILE")

  # Detectar locale del nombre del archivo (termina en _en.png o _es.png)
  if [[ "$FILENAME" == *_en.png ]]; then
    LOCALE="en-US"
  elif [[ "$FILENAME" == *_es.png ]]; then
    LOCALE="es-ES"
  else
    LOCALE="en-US"  # Default
  fi

  DEST_DIR="$OUTPUT_DIR/$LOCALE/$DEVICE_NAME"
  mkdir -p "$DEST_DIR"
  cp "$FILE" "$DEST_DIR/$FILENAME"
  echo "   ✅ $FILENAME → $DEST_DIR/"
done

echo ""
echo "✅ Screenshots guardados en: $OUTPUT_DIR"
echo "   Estructura:"
find "$OUTPUT_DIR" -name "*.png" | sort
```

- [ ] **Paso 8.3: Crear `scripts/screenshots_android.sh`**

```bash
#!/bin/bash
# scripts/screenshots_android.sh
#
# Genera screenshots en el emulador Android y los organiza para Fastlane.
#
# Uso:
#   ./scripts/screenshots_android.sh
#
# Prerequisitos:
#   - Android SDK instalado
#   - Emulador "Pixel_7_Pro_API_34" (o similar) disponible
#   - Flutter configurado

set -e

PACKAGE="com.gabriom.playingtrackerapp"
OUTPUT_DIR="fastlane/screenshots"
DEVICE_NAME="Pixel 7 Pro"

echo "🤖 Generando screenshots para Android..."

# Verificar que hay un emulador corriendo
DEVICE_ID=$(adb devices | grep "emulator" | awk '{print $1}' | head -1)

if [ -z "$DEVICE_ID" ]; then
  echo "❌ No hay emulador Android corriendo."
  echo "   Arranca un emulador con: flutter emulators --launch <emulator_id>"
  echo "   Emuladores disponibles: flutter emulators"
  exit 1
fi

echo "   Emulador: $DEVICE_ID"

# Ejecutar tests
echo "🧪 Ejecutando integration tests..."
flutter test integration_test/screenshots_test.dart -d "$DEVICE_ID"

echo "📂 Extrayendo screenshots del emulador..."

# En Android, path_provider/getApplicationDocumentsDirectory devuelve:
# /data/user/0/<package>/app_flutter/
REMOTE_DIR="/data/user/0/$PACKAGE/app_flutter/screenshots"

# Verificar que existen screenshots
adb -s "$DEVICE_ID" shell ls "$REMOTE_DIR" > /dev/null 2>&1 || {
  echo "❌ No se encontraron screenshots en: $REMOTE_DIR"
  exit 1
}

# Listar archivos
SCREENSHOTS=$(adb -s "$DEVICE_ID" shell ls "$REMOTE_DIR")

for FILENAME in $SCREENSHOTS; do
  # Detectar locale
  if [[ "$FILENAME" == *_en.png ]]; then
    LOCALE="en-US"
  elif [[ "$FILENAME" == *_es.png ]]; then
    LOCALE="es-ES"
  else
    LOCALE="en-US"
  fi

  DEST_DIR="$OUTPUT_DIR/$LOCALE/$DEVICE_NAME"
  mkdir -p "$DEST_DIR"
  adb -s "$DEVICE_ID" pull "$REMOTE_DIR/$FILENAME" "$DEST_DIR/$FILENAME"
  echo "   ✅ $FILENAME → $DEST_DIR/"
done

echo ""
echo "✅ Screenshots guardados en: $OUTPUT_DIR"
```

- [ ] **Paso 8.4: Dar permisos de ejecución**

```bash
chmod +x scripts/screenshots_ios.sh scripts/screenshots_android.sh
```

- [ ] **Paso 8.5: Commit**

```bash
git add scripts/
git commit -m "chore: add screenshot generation scripts for iOS and Android"
```

---

## Tarea 9: Fastfile - Lanes de upload

**Archivos:**
- Crear: `fastlane/Fastfile`
- Crear: `fastlane/Deliverfile`

- [ ] **Paso 9.1: Crear `fastlane/Deliverfile`**

```ruby
# fastlane/Deliverfile
app_identifier "com.gabriom.playingtrackerapp"

# Subir solo metadatos y screenshots (no el binario en esta lane)
skip_binary_upload true

# Forzar subida sin preguntar confirmaciones
force true

# No enviar a revisión automáticamente
submit_for_review false
automatic_release false

# Idiomas soportados
languages ["en-US", "es-ES"]

# Rutas de assets
screenshots_path "./fastlane/screenshots"
metadata_path "./fastlane/metadata"
```

- [ ] **Paso 9.2: Crear `fastlane/Fastfile`**

```ruby
# fastlane/Fastfile
default_platform(:ios)

# ============================================================
# iOS
# ============================================================
platform :ios do

  desc "Genera screenshots en simulador iOS"
  lane :screenshots do
    sh("cd .. && bash scripts/screenshots_ios.sh")
  end

  desc "Sube metadatos y screenshots a App Store Connect (sin binario)"
  lane :upload_metadata do
    deliver(
      skip_binary_upload: true,
      submit_for_review: false,
      automatic_release: false,
      force: true,
      languages: ["en-US", "es-ES"],
      metadata_path: "./fastlane/metadata",
      screenshots_path: "./fastlane/screenshots",
    )
  end

  desc "Pipeline completo iOS: genera screenshots + sube a App Store"
  lane :release_metadata do
    screenshots
    upload_metadata
    UI.success("✅ Metadatos y screenshots de iOS subidos correctamente")
  end

end

# ============================================================
# Android
# ============================================================
platform :android do

  desc "Genera screenshots en emulador Android"
  lane :screenshots do
    sh("cd .. && bash scripts/screenshots_android.sh")
  end

  desc "Sube metadatos y screenshots a Google Play Console (sin AAB)"
  lane :upload_metadata do
    supply(
      track: "production",
      skip_upload_apk: true,
      skip_upload_aab: true,
      skip_upload_metadata: false,
      skip_upload_screenshots: false,
      metadata_path: "./fastlane/metadata/android",
      screenshots_path: "./fastlane/screenshots",
    )
  end

  desc "Pipeline completo Android: genera screenshots + sube a Play Store"
  lane :release_metadata do
    screenshots
    upload_metadata
    UI.success("✅ Metadatos y screenshots de Android subidos correctamente")
  end

end
```

- [ ] **Paso 9.3: Verificar sintaxis del Fastfile**

```bash
cd fastlane && bundle exec fastlane lanes && cd ..
```

Esperado: lista de lanes sin errores de sintaxis Ruby.

- [ ] **Paso 9.4: Commit**

```bash
git add fastlane/Fastfile fastlane/Deliverfile
git commit -m "chore: add Fastlane lanes for iOS and Android metadata upload"
```

---

## Tarea 10: Configuración de credenciales (manual, no en git)

Esta tarea documenta la configuración de credenciales que NO se commitean.

### iOS - App Store Connect API Key

- [ ] **Paso 10.1: Crear API Key en App Store Connect**

1. Ir a [App Store Connect](https://appstoreconnect.apple.com) → Usuarios y acceso → Claves API
2. Crear nueva clave con rol "App Manager"
3. Descargar `AuthKey_XXXXXXXXXX.p8`
4. Guardar en `fastlane/AuthKey_XXXXXXXXXX.p8` (está en .gitignore)

- [ ] **Paso 10.2: Crear `fastlane/.env` para iOS**

```bash
# fastlane/.env  (NO commitear - está en .gitignore)
APP_STORE_CONNECT_API_KEY_KEY_ID=XXXXXXXXXX
APP_STORE_CONNECT_API_KEY_ISSUER_ID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
APP_STORE_CONNECT_API_KEY_KEY_FILEPATH=./fastlane/AuthKey_XXXXXXXXXX.p8
```

- [ ] **Paso 10.3: Actualizar `fastlane/Fastfile` para usar API Key**

Añadir al inicio del `Fastfile`:

```ruby
# Carga la API Key de App Store Connect desde variables de entorno
def app_store_api_key
  app_store_connect_api_key(
    key_id: ENV["APP_STORE_CONNECT_API_KEY_KEY_ID"],
    issuer_id: ENV["APP_STORE_CONNECT_API_KEY_ISSUER_ID"],
    key_filepath: ENV["APP_STORE_CONNECT_API_KEY_KEY_FILEPATH"],
  )
end
```

Y actualizar la lane `upload_metadata` de iOS para usarla:

```ruby
lane :upload_metadata do
  api_key = app_store_api_key
  deliver(
    api_key: api_key,
    # ... resto de parámetros
  )
end
```

### Android - Google Play Service Account

- [ ] **Paso 10.4: Crear Service Account en Google Cloud**

1. Ir a [Google Play Console](https://play.google.com/console) → Configuración → Acceso a la API
2. Crear nuevo proyecto en Google Cloud Console o vincular existente
3. Crear Service Account con rol "Release Manager"
4. Descargar clave JSON → guardar como `fastlane/gc_keys.json` (está en .gitignore)

### Verificación de credenciales

- [ ] **Paso 10.5: Probar conexión iOS (dry run)**

```bash
cd fastlane && bundle exec fastlane ios upload_metadata --env .env && cd ..
```

- [ ] **Paso 10.6: Probar conexión Android (dry run)**

```bash
cd fastlane && bundle exec fastlane android upload_metadata && cd ..
```

---

## Tarea 11: Makefile + documentación de uso

**Archivos:**
- Modificar: `Makefile`
- Crear: `docs/STORE_RELEASE.md`

- [ ] **Paso 11.1: Leer el Makefile actual**

```bash
cat Makefile
```

- [ ] **Paso 11.2: Añadir targets de store al Makefile**

```makefile
# App Store / Play Store
screenshots-ios:        ## Genera screenshots en simulador iOS
	bash scripts/screenshots_ios.sh

screenshots-android:    ## Genera screenshots en emulador Android
	bash scripts/screenshots_android.sh

screenshots:            ## Genera screenshots en iOS y Android
	$(MAKE) screenshots-ios
	$(MAKE) screenshots-android

store-upload-ios:       ## Sube metadatos y screenshots a App Store Connect
	cd fastlane && bundle exec fastlane ios upload_metadata

store-upload-android:   ## Sube metadatos y screenshots a Google Play
	cd fastlane && bundle exec fastlane android upload_metadata

store-release:          ## Pipeline completo: genera screenshots + sube a ambas stores
	cd fastlane && bundle exec fastlane ios release_metadata
	cd fastlane && bundle exec fastlane android release_metadata
```

- [ ] **Paso 11.3: Crear `docs/STORE_RELEASE.md`**

```markdown
# Guía de Release en App Store y Google Play

## Prerequisitos (primera vez)

1. Instalar Fastlane:
   ```bash
   cd fastlane && bundle install && cd ..
   ```

2. Configurar credenciales iOS (ver Tarea 10 del plan de implementación):
   - Descargar `AuthKey_XXXXXXXXXX.p8` de App Store Connect
   - Crear `fastlane/.env` con los valores de la API Key

3. Configurar credenciales Android:
   - Descargar `gc_keys.json` de Google Cloud Console
   - Guardar en `fastlane/gc_keys.json`

## Flujo de release (versiones posteriores)

### Antes de subir

1. Actualizar `fastlane/metadata/en-US/release_notes.txt` con los cambios de esta versión
2. Actualizar `fastlane/metadata/es-ES/release_notes.txt` (en español)

### Generar screenshots (solo cuando cambia la UI)

```bash
# iOS (requiere simulador "iPhone 15 Pro Max")
make screenshots-ios

# Android (requiere emulador corriendo)
make screenshots-android
```

Los screenshots se guardan en `fastlane/screenshots/` (no están en git, se regeneran).

### Subir metadatos y screenshots

```bash
# Solo iOS
make store-upload-ios

# Solo Android
make store-upload-android

# Ambas stores de una vez
make store-release
```

### Subir el binario (build)

El binario se sube por separado usando los comandos de build:

```bash
# iOS - genera IPA
make ipa
# Subir a App Store Connect con Xcode Organizer o Transporter

# Android - genera AAB
make aab
# Subir en Google Play Console → Lanzamientos de producción
```

## Estructura de directorios

```
fastlane/
├── Gemfile                    # Dependencias Ruby
├── Appfile                    # Bundle ID y Apple ID
├── Fastfile                   # Lanes de automatización
├── Deliverfile                # Config entrega iOS
├── .env                       # Credenciales iOS (NO en git)
├── AuthKey_*.p8               # API Key App Store (NO en git)
├── gc_keys.json               # Service Account Android (NO en git)
├── metadata/
│   ├── en-US/                 # Textos App Store en inglés
│   ├── es-ES/                 # Textos App Store en español
│   └── android/
│       ├── en-US/             # Textos Play Store en inglés
│       └── es-ES/             # Textos Play Store en español
└── screenshots/               # Generadas (NO en git)
    ├── en-US/
    │   └── iPhone 15 Pro Max/
    └── es-ES/
        └── iPhone 15 Pro Max/

scripts/
├── screenshots_ios.sh         # Extrae screenshots de simulador iOS
└── screenshots_android.sh     # Extrae screenshots de emulador Android

integration_test/
├── screenshots_test.dart      # Test que navega y captura pantallas
└── helpers/
    ├── screenshot_helper.dart      # Utilidad de captura
    └── screenshot_mock_data.dart   # Datos realistas para screenshots
```

## Solución de problemas

### "No se encontró el contenedor de la app" (iOS)

La app no se instaló durante el test. Verificar que el simulador estaba corriendo y que el bundle ID es correcto.

### "No hay emulador Android corriendo"

Arrancar un emulador con: `flutter emulators --launch <id>`
Ver emuladores disponibles: `flutter emulators`

### Error de autenticación en App Store Connect

Verificar que `fastlane/.env` tiene los valores correctos de la API Key.
Verificar que el archivo `.p8` existe en la ruta indicada.

### Error de autenticación en Google Play

Verificar que `fastlane/gc_keys.json` existe y tiene permisos de "Release Manager".

## Testing manual recomendado (por release)

### Android (rol estudiante)
1. Instalar APK de release en dispositivo físico Android
2. Iniciar sesión como estudiante
3. Verificar que las pantallas principales se ven correctamente

### iOS (rol profesor)
1. Instalar IPA via TestFlight
2. Iniciar sesión como profesor
3. Verificar que las pantallas principales se ven correctamente
```

- [ ] **Paso 11.4: Commit final**

```bash
git add Makefile docs/STORE_RELEASE.md
git commit -m "chore: add Makefile targets and store release guide"
```

---

## Resumen de ejecución

| # | Tarea | Tiempo estimado |
|---|---|---|
| 1 | .gitignore | 10 min |
| 2 | Instalar Fastlane | 20 min |
| 3 | Metadatos inglés | 30 min |
| 4 | Metadatos español | 20 min |
| 5 | Datos mock realistas | 30 min |
| 6 | Screenshot helper | 20 min |
| 7 | Test de screenshots | 45 min |
| 8 | Scripts de extracción | 30 min |
| 9 | Fastfile + Deliverfile | 30 min |
| 10 | Credenciales (manual) | 30 min |
| 11 | Makefile + docs | 20 min |
| **Total** | | **~5 horas** |

## Notas importantes para la implementación

1. **Tarea 5 requiere leer los modelos reales** antes de escribir los datos mock. Ver `lib/features/sessions/domain/models/`, `lib/features/tasks/domain/models/`, etc.

2. **Los textos de los tabs en Tarea 7** dependen de las traducciones en `lib/l10n/app_en.arb` y `app_es.arb`. Verificar antes de hardcodear strings.

3. **`binding.takeScreenshot()`** puede requerir que la app tenga `android.permission.WRITE_EXTERNAL_STORAGE` en el `AndroidManifest.xml` de debug/test. Verificar si falla en Android.

4. **Para iOS**, si `xcrun simctl get_app_container` falla, puede ser necesario registrar el Bundle ID en el portal de desarrollador y firmar la app de test.

5. **Los screenshots NO se commitean** intencionalmente. Se regeneran antes de cada subida a las stores.

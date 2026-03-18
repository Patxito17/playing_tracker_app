// integration_test/helpers/screenshot_helper.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Captura la pantalla actual y la guarda como PNG en el directorio
/// Documents de la app con el nombre [filename].
///
/// Convención de nombres: `NN_descripcion_locale` (ej: `01_login_en`)
///
/// Rutas de guardado:
/// - iOS Simulator: `<app_container>/Documents/screenshots/`
/// - Android Emulator: `<app_files>/screenshots/`
///
/// Extraer con los scripts en scripts/screenshots_ios.sh / screenshots_android.sh
Future<void> captureScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String filename,
) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  final bytes = await binding.takeScreenshot(filename);

  final docsDir = await getApplicationDocumentsDirectory();
  final screenshotsDir = Directory('${docsDir.path}/screenshots');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync(recursive: true);
  }

  final file = File('${screenshotsDir.path}/$filename.png');
  await file.writeAsBytes(bytes);

  // ignore: avoid_print
  print('[SCREENSHOT] Guardado: ${file.path}');
}

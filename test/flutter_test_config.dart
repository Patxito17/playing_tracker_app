import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Configuración global para todos los tests de Flutter en este proyecto.
///
/// Este fichero se ejecuta automáticamente antes de cualquier test en
/// el directorio `test/`. Configura el comparador de goldens para que
/// use rutas relativas al fichero de test que lo invoca, lo que permite
/// organizar los archivos de referencia en subcarpetas por componente.
///
/// Para regenerar las referencias:
///   flutter test --update-goldens test/golden/critical_components_golden_test.dart
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Configurar el comparador de goldens para usar rutas relativas
  // al fichero de test. Esto permite organizar los golden files junto
  // a los tests que los generan (en `test/golden/goldens/`).
  goldenFileComparator = LocalFileComparator(
    Uri.file(
      '${Directory.current.path}/test/golden/critical_components_golden_test.dart',
    ),
  );

  return testMain();
}

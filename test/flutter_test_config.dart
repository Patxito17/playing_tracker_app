import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
/// Comparador personalizado para tests dorados que tolera pequeñas diferencias.
/// Esto es necesario porque GitHub Actions usa Ubuntu (Linux) para generar
/// los tests de Android, pero las referencias visuales (goldens) suelen
/// generarse en local (macOS/Windows).
class TolerantComparator extends LocalFileComparator {
  TolerantComparator(
    super.testFile, {
    this.tolerance = 0.05,
  }); // 5% de tolerancia

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= tolerance) {
      debugPrint(
        'Tolerated Diff: ${(result.diffPercent * 100).toStringAsFixed(2)}% '
        'for $golden (Threshold: ${(tolerance * 100).toStringAsFixed(2)}%)',
      );
      result.dispose();
      return true;
    }

    if (result.passed) {
      result.dispose();
      return true;
    }

    final String error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // En lugar de usar una ruta estática, heredamos el `basedir` del
  // comparador que Flutter pre-configuró automáticamente para el archivo
  // de test actual. Esto garantiza que funcione en subdirectorios y en CI.
  if (goldenFileComparator is LocalFileComparator) {
    var testUrl = (goldenFileComparator as LocalFileComparator).basedir;
    goldenFileComparator = TolerantComparator(
      Uri.parse('${testUrl}foo.dart'),
      tolerance: 0.005, // 0.5% de tolerancia de píxeles
    );
  } else {
    // Respaldo (fallback)
    goldenFileComparator = TolerantComparator(
      Uri.file('${Directory.current.path}/test/foo.dart'),
      tolerance: 0.005,
    );
  }

  return testMain();
}

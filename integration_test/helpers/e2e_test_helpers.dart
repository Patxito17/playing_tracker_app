import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:playing_tracker/main.dart' as app;

/// Inicializa el entorno de tests de integración.
/// Debe llamarse al inicio de cada test E2E.
void setupIntegrationTest() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Genera un email único para evitar colisiones entre ejecuciones de tests.
String uniqueEmail(String prefix) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '$prefix+e2e_$timestamp@playingtracker.test';
}

/// Constantes de contraseña robusta para tests E2E.
const String kTestPassword = 'TestPassword123!';

/// Elimina el usuario actual de Firebase Auth.
/// Se llama en tearDown para limpiar el estado tras cada test.
Future<void> cleanupTestUser() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
    }
  } catch (_) {
    // Ignorar: si el usuario ya fue eliminado o no existe, no es un error.
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}

/// Arranca la app y espera a que la pantalla de Login esté visible.
Future<void> launchApp(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

/// Escribe texto en un campo [TextField] identificado por su posición
/// dentro de la jerarquía de widgets, usando el índice [index]
/// entre todos los [TextField] visibles en pantalla.
Future<void> enterTextAt(WidgetTester tester, int index, String text) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(index), text);
  await tester.pumpAndSettle();
}

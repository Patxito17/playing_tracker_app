// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/e2e_test_helpers.dart';

/// Tests de integración E2E — Flujo Docente
///
/// Cubre el flujo crítico:
///   1. Navegar a la pantalla de Registro
///   2. Registrarse como Docente (el rol 'teacher' es el predeterminado)
///   3. Esperar a que el Custom Claim se propague y la app navegue al Dashboard
///   4. Navegar a 'Crear Clase'
///   5. Crear una clase y verificar el mensaje de éxito
///
/// ⚠️ Prerequisito: la app debe apuntar a Firebase real o al emulador de
///    Firebase configurado localmente. Cada test genera un email único para
///    evitar colisiones y elimina el usuario al finalizar (tearDown).
///
/// Cómo ejecutar:
///   flutter test integration_test/teacher_flow_test.dart -d [device_id]
///
void main() {
  setupIntegrationTest();

  group('Flujo E2E: Docente', () {
    // Email generado en tiempo de compilación del test group para reutilizarlo
    // entre pasos del mismo grupo si fuera necesario.
    late String teacherEmail;

    setUp(() {
      teacherEmail = uniqueEmail('docente');
    });

    tearDown(() async {
      await cleanupTestUser();
    });

    testWidgets('Registro de docente → Dashboard → Crear clase → Éxito', (
      tester,
    ) async {
      await launchApp(tester);

      // ── PASO 1: Navegar desde Login a Registro ────────────────────────────
      print('[E2E] Buscando botón de Registro en LoginScreen...');
      final registerLink = find.byType(TextButton).last;
      await tester.tap(registerLink);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ── PASO 2: Rellenar formulario de Registro como Docente ──────────────
      // El rol 'teacher' está seleccionado por defecto (SegmentedButton).
      // Campos: [0] firstName, [1] lastName, [2] email, [3] password,
      //         [4] confirmPassword
      print('[E2E] Rellenando formulario de registro...');
      await enterTextAt(tester, 0, 'Test');
      await enterTextAt(tester, 1, 'Docente');
      await enterTextAt(tester, 2, teacherEmail);
      await enterTextAt(tester, 3, kTestPassword);
      await enterTextAt(tester, 4, kTestPassword);

      // Aceptar términos y condiciones (Checkbox)
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Pulsar botón de registro
      final registerButton = find.byType(FilledButton).first;
      await tester.tap(registerButton);

      // ── PASO 3: Esperar navegación al Dashboard ───────────────────────────
      // El Custom Claim puede tardar hasta ~15s. Esperamos con timeout amplio.
      print('[E2E] Esperando navegación al Dashboard docente...');
      await tester.pumpAndSettle(const Duration(seconds: 20));

      // Verificar que estamos en el Dashboard (BottomNavigationBar visible)
      expect(
        find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
            find.byType(NavigationBar).evaluate().isNotEmpty,
        isTrue,
        reason: 'Se esperaba ver la barra de navegación del Dashboard',
      );

      // ── PASO 4: Navegar a "Crear Clase" ───────────────────────────────────
      // El FAB o botón de "Crear Clase" está en TeacherClassesListScreen.
      // Primero navegamos a la pestaña de Clases (índice 1 en el ShellRoute).
      print('[E2E] Navegando a la pestaña de Clases...');
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length > 1) {
        await tester.tap(navItems.at(1));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Buscar el FAB o botón para crear clase
      final createButton = find.byIcon(Icons.add).first;
      await tester.tap(createButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ── PASO 5: Rellenar formulario de Crear Clase ────────────────────────
      print('[E2E] Rellenando formulario de creación de clase...');
      // Campo nombre de clase (primer TextField visible)
      await enterTextAt(tester, 0, 'Clase de Test E2E');
      // Campo descripción (segundo TextField visible)
      await enterTextAt(tester, 1, 'Clase creada por test automatizado');

      // Pulsar el botón de crear (FilledButton con label "Crear clase")
      final createClassBtn = find.byType(FilledButton).first;
      await tester.tap(createClassBtn);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ── PASO 6: Verificar mensaje de éxito ────────────────────────────────
      // La pantalla muestra un banner de éxito antes de redirigir.
      print('[E2E] Verificando mensaje de éxito...');
      expect(
        find.byIcon(Icons.check_circle).evaluate().isNotEmpty,
        isTrue,
        reason: 'Se esperaba ver el icono de éxito tras crear la clase',
      );

      print('[E2E] ✅ Flujo Docente completado con éxito');
    });
  });
}

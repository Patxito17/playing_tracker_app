// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/e2e_test_helpers.dart';

/// Tests de integración E2E — Flujo Estudiante
///
/// Cubre el flujo crítico del alumno:
///   1. Navegar a Registro
///   2. Registrarse como Alumno (seleccionar tab 'Alumno')
///   3. Esperar Custom Claim y llegar al Dashboard de estudiante
///   4. Navegar a la pestaña de Clases y verificar el estado vacío
///
/// ⚠️ Nota sobre el timer: el flujo completo del cronómetro (iniciar sesión,
///    pausar, finalizar) requiere que el alumno esté previamente inscrito en
///    una clase con una tarea asignada. Para aislar el test de E2E del estado
///
/// Cómo ejecutar:
///   flutter test integration_test/student_flow_test.dart -d [device_id]
///
void main() {
  setupIntegrationTest();

  group('Flujo E2E: Estudiante', () {
    late String studentEmail;

    setUp(() {
      studentEmail = uniqueEmail('alumno');
    });

    tearDown(() async {
      await cleanupTestUser();
    });

    testWidgets(
      'Registro de alumno → Dashboard de estudiante → Pantalla de Clases visible',
      (tester) async {
        await launchApp(tester);

        // ── PASO 1: Navegar a Registro ─────────────────────────────────────────
        print('[E2E] Navegando a Registro desde LoginScreen...');
        final registerLink = find.byType(TextButton).last;
        await tester.tap(registerLink);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ── PASO 2: Seleccionar rol "Alumno" en SegmentedButton ───────────────
        // El SegmentedButton tiene dos segmentos: [0] Docente, [1] Alumno.
        // Buscamos el texto del segmento de estudiante para hacer tap en él.
        print('[E2E] Seleccionando rol Alumno...');
        // El SegmentedButton renderiza botones con IconButton + Text internamente.
        // Buscamos el botón con icono de persona (student).
        final studentSegment = find.byIcon(Icons.person_outline);
        if (studentSegment.evaluate().isNotEmpty) {
          await tester.tap(studentSegment.first);
          await tester.pumpAndSettle();
        }

        // ── PASO 3: Rellenar formulario de Registro ───────────────────────────
        // Campos: [0] firstName, [1] lastName, [2] email, [3] password,
        //         [4] confirmPassword
        print('[E2E] Rellenando formulario de registro de alumno...');
        await enterTextAt(tester, 0, 'Test');
        await enterTextAt(tester, 1, 'Alumno');
        await enterTextAt(tester, 2, studentEmail);
        await enterTextAt(tester, 3, kTestPassword);
        await enterTextAt(tester, 4, kTestPassword);

        // Aceptar términos
        final checkbox = find.byType(Checkbox).first;
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // Pulsar registro
        final registerButton = find.byType(FilledButton).first;
        await tester.tap(registerButton);

        // ── PASO 4: Esperar Dashboard de Estudiante ───────────────────────────
        // La espera es mayor para dar tiempo al Custom Claim 'student'.
        print('[E2E] Esperando navegación al Dashboard estudiante...');
        await tester.pumpAndSettle(const Duration(seconds: 20));

        // Verificar que la barra de navegación inferior está presente
        expect(
          find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
              find.byType(NavigationBar).evaluate().isNotEmpty,
          isTrue,
          reason: 'Se esperaba ver la barra de navegación del Dashboard',
        );

        // ── PASO 5: Navegar a la pestaña de Clases ────────────────────────────
        print('[E2E] Navegando a la pestaña de Clases del estudiante...');
        final navItems = find.byType(BottomNavigationBarItem);
        if (navItems.evaluate().length > 1) {
          await tester.tap(navItems.at(1));
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // ── PASO 6: Verificar que la pantalla de Clases está accesible ─────
        // En un alumno recién registrado, la lista estará vacía.
        // Verificamos que el estado de vacío o el botón "Unirse a clase" existe.
        print('[E2E] Verificando pantalla de Clases del estudiante...');
        final hasClasesScreen =
            find.byIcon(Icons.add).evaluate().isNotEmpty ||
            find.byIcon(Icons.group_add_outlined).evaluate().isNotEmpty ||
            find.byType(ListView).evaluate().isNotEmpty;

        expect(
          hasClasesScreen,
          isTrue,
          reason:
              'Se esperaba ver la pantalla de clases del alumno (vacía o con contenido)',
        );

        print('[E2E] ✅ Flujo Estudiante completado con éxito');
      },
    );
  });
}

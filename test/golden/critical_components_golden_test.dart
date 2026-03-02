import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:playing_tracker/shared/widgets/custom_button.dart';
import 'package:playing_tracker/shared/widgets/custom_card.dart';
import 'package:playing_tracker/shared/widgets/custom_text_field.dart';
import 'package:playing_tracker/shared/widgets/loading_overlay.dart';

/// Golden Tests para componentes visuales críticos de Playing Tracker.
///
/// Utiliza la API nativa de Flutter `matchesGoldenFile` sin dependencias
/// externas. Las referencias se generan con:
///   flutter test --update-goldens test/golden/critical_components_golden_test.dart
///
/// Las comparaciones se ejecutan simplemente con:
///   flutter test test/golden/critical_components_golden_test.dart
///
/// Componentes cubiertos (5 componentes críticos):
///   1. CustomButton — variantes: filled, outlined, text + loading
///   2. CustomCard   — con y sin header/acciones
///   3. CustomTextField — normal y con error
///   4. LoadingOverlay — con y sin mensaje
void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Utilidades de scaffolding para tests
  // ──────────────────────────────────────────────────────────────────────────

  /// Envuelve un widget en el contexto mínimo necesario para renderizarlo.
  /// Usamos MaterialApp para obtener tema, dirección del texto y localización.
  Widget wrapWidget(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. CustomButton
  // ──────────────────────────────────────────────────────────────────────────
  group('Golden: CustomButton', () {
    testWidgets('filled — estado activo', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          CustomButton(
            label: 'Iniciar sesión',
            variant: CustomButtonVariant.filled,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/custom_button_filled.png'),
      );
    });

    testWidgets('outlined — estado activo', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          CustomButton(
            label: 'Cancelar',
            variant: CustomButtonVariant.outlined,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/custom_button_outlined.png'),
      );
    });

    testWidgets('filled — estado loading', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          CustomButton(
            label: 'Cargando...',
            variant: CustomButtonVariant.filled,
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );
      // No pumpAndSettle para no dejar que el spinner se anime.
      await tester.pump();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/custom_button_loading.png'),
      );
    });

    testWidgets('filled con icono', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          CustomButton(
            label: 'Crear clase',
            variant: CustomButtonVariant.filled,
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/custom_button_with_icon.png'),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 2. CustomCard
  // ──────────────────────────────────────────────────────────────────────────
  group('Golden: CustomCard', () {
    testWidgets('solo contenido sin header', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const CustomCard(
            margin: EdgeInsets.zero,
            child: Text('Contenido del card sin header'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/custom_card_simple.png'),
      );
    });

    testWidgets('con título y subtítulo', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const CustomCard(
            margin: EdgeInsets.zero,
            title: 'Matemáticas 3°A',
            subtitle: 'Código: XY4521',
            child: Text('Descripción de la clase.'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/custom_card_with_header.png'),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 3. CustomTextField
  // ──────────────────────────────────────────────────────────────────────────
  group('Golden: CustomTextField', () {
    testWidgets('estado normal vacío', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        wrapWidget(
          CustomTextField(
            controller: controller,
            label: 'Correo electrónico',
            hint: 'ejemplo@correo.com',
            prefix: const Icon(Icons.email_outlined),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/custom_text_field_normal.png'),
      );
    });

    testWidgets('con mensaje de error', (tester) async {
      final controller = TextEditingController(text: 'texto-invalido');
      await tester.pumpWidget(
        wrapWidget(
          CustomTextField(
            controller: controller,
            label: 'Correo electrónico',
            hint: 'ejemplo@correo.com',
            prefix: const Icon(Icons.email_outlined),
            errorText: 'El formato del email no es válido',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/custom_text_field_error.png'),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 4. LoadingOverlay
  // ──────────────────────────────────────────────────────────────────────────
  group('Golden: LoadingOverlay', () {
    testWidgets('sin mensaje', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const SizedBox(width: 300, height: 300, child: LoadingOverlay()),
        ),
      );
      // Solo un frame: el spinner en su estado inicial es determinista.
      await tester.pump();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/loading_overlay_no_message.png'),
      );
    });

    testWidgets('con mensaje de carga', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const SizedBox(
            width: 300,
            height: 300,
            child: LoadingOverlay(message: 'Guardando clase...'),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/loading_overlay_with_message.png'),
      );
    });
  });
}

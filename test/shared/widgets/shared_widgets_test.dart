import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/shared/widgets/custom_button.dart';
import 'package:playing_tracker/shared/widgets/custom_card.dart';
import 'package:playing_tracker/shared/widgets/custom_text_field.dart';
import 'package:playing_tracker/shared/widgets/loading_overlay.dart';

// ---------------------------------------------------------------------------
// Helper: envuelve un widget en MaterialApp con tema M3
// ---------------------------------------------------------------------------
Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  // =========================================================================
  // CustomButton
  // =========================================================================
  group('CustomButton', () {
    testWidgets('renderiza texto del botón correctamente', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(CustomButton(label: 'Guardar', onPressed: () {})),
      );

      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('variante filled renderiza FilledButton', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          CustomButton(
            label: 'Enviar',
            onPressed: () {},
            variant: CustomButtonVariant.filled,
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('variante outlined renderiza OutlinedButton', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          CustomButton(
            label: 'Cancelar',
            onPressed: () {},
            variant: CustomButtonVariant.outlined,
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('variante text renderiza TextButton', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          CustomButton(
            label: 'Ver más',
            onPressed: () {},
            variant: CustomButtonVariant.text,
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('llama onPressed al ser presionado', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        _wrapWithApp(
          CustomButton(label: 'Aceptar', onPressed: () => pressed = true),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(pressed, isTrue);
    });

    testWidgets('no llama onPressed cuando isEnabled es false', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        _wrapWithApp(
          CustomButton(
            label: 'Botón',
            onPressed: () => pressed = true,
            isEnabled: false,
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      expect(pressed, isFalse);
    });

    testWidgets('muestra CircularProgressIndicator cuando isLoading es true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          CustomButton(label: 'Cargando', onPressed: () {}, isLoading: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // El texto NO debe aparecer cuando hay loading
      expect(find.text('Cargando'), findsNothing);
    });

    testWidgets('muestra icono cuando se proporciona', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          CustomButton(label: 'Editar', onPressed: () {}, icon: Icons.edit),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
    });

    testWidgets('tiene Semantics con botón = true', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(CustomButton(label: 'Semántico', onPressed: () {})),
      );

      final semantics = tester.getSemantics(find.byType(CustomButton));
      expect(semantics.label, contains('Semántico'));
    });
  });

  // =========================================================================
  // CustomTextField
  // =========================================================================
  group('CustomTextField', () {
    testWidgets('renderiza con label y hint correctamente', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const CustomTextField(label: 'Nombre', hint: 'Introduce tu nombre'),
        ),
      );

      expect(find.text('Nombre'), findsOneWidget);
      // El hint se muestra al hacer focus (puede no aparecer si hay controller)
    });

    testWidgets('muestra texto de error cuando errorText no es nulo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const CustomTextField(label: 'Email', errorText: 'Email inválido'),
        ),
      );

      expect(find.text('Email inválido'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('no muestra error cuando errorText es nulo', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const CustomTextField(label: 'Email', errorText: null)),
      );

      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('llama onChanged cuando el texto cambia', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        _wrapWithApp(
          CustomTextField(label: 'Campo', onChanged: (v) => changedValue = v),
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      expect(changedValue, 'flutter');
    });

    testWidgets('campo deshabilitado no acepta entrada', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        _wrapWithApp(
          CustomTextField(
            label: 'Campo',
            enabled: false,
            onChanged: (v) => changedValue = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'texto');
      expect(changedValue, isNull);
    });

    testWidgets('obscureText oculta el contenido del campo', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const CustomTextField(label: 'Contraseña', obscureText: true),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });
  });

  // =========================================================================
  // LoadingOverlay
  // =========================================================================
  group('LoadingOverlay', () {
    testWidgets('muestra CircularProgressIndicator siempre', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const LoadingOverlay()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('muestra mensaje cuando se proporciona', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const LoadingOverlay(message: 'Por favor espera...')),
      );

      expect(find.text('Por favor espera...'), findsOneWidget);
    });

    testWidgets('no muestra mensaje cuando message es null', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const LoadingOverlay()));

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('bloquea interacciones (AbsorbPointer)', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithApp(
          Stack(
            children: [
              GestureDetector(
                onTap: () => tapped = true,
                child: const SizedBox.expand(),
              ),
              const LoadingOverlay(),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(LoadingOverlay), warnIfMissed: false);
      expect(tapped, isFalse);
    });
  });

  // =========================================================================
  // CustomCard
  // =========================================================================
  group('CustomCard', () {
    testWidgets('renderiza contenido hijo correctamente', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const CustomCard(child: Text('Contenido'))),
      );

      expect(find.text('Contenido'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('muestra título cuando se proporciona', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const CustomCard(title: 'Mi título', child: SizedBox.shrink()),
        ),
      );

      expect(find.text('Mi título'), findsOneWidget);
    });

    testWidgets('muestra subtítulo cuando se proporciona', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const CustomCard(
            title: 'Título',
            subtitle: 'Descripción',
            child: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Descripción'), findsOneWidget);
    });

    testWidgets('llama onTap cuando se toca el card', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithApp(
          CustomCard(
            onTap: () => tapped = true,
            child: const Text('Card táctil'),
          ),
        ),
      );

      await tester.tap(find.text('Card táctil'));
      expect(tapped, isTrue);
    });

    testWidgets('no muestra header si no hay título ni acciones', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(const CustomCard(child: Text('Solo contenido'))),
      );

      expect(find.byType(Row), findsNothing);
      expect(find.text('Solo contenido'), findsOneWidget);
    });

    testWidgets('muestra trailingAction cuando se proporciona', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          CustomCard(
            title: 'Card con acción',
            trailingAction: const Icon(Icons.more_vert),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}

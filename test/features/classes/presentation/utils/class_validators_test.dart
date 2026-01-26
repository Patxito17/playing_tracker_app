import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/classes/presentation/utils/class_validators.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';

void main() {
  group('normalizeAccessCode', () {
    test('elimina espacios y convierte a mayúsculas', () {
      expect(normalizeAccessCode('  abC123  '), equals('ABC123'));
    });
  });

  group('validateAccessCodeField', () {
    Widget createLocalizedContext(void Function(BuildContext) callback) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        home: Builder(
          builder: (context) {
            callback(context);
            return const SizedBox();
          },
        ),
      );
    }

    testWidgets('retorna error cuando el campo está vacío', (
      WidgetTester tester,
    ) async {
      String? result;
      await tester.pumpWidget(
        createLocalizedContext((context) {
          result = validateAccessCodeField(context, '');
        }),
      );
      await tester.pumpAndSettle();

      expect(result, equals('Código de acceso es requerido'));
    });

    testWidgets('retorna error cuando el formato es inválido', (
      WidgetTester tester,
    ) async {
      String? result;
      await tester.pumpWidget(
        createLocalizedContext((context) {
          result = validateAccessCodeField(context, 'A1B');
        }),
      );
      await tester.pumpAndSettle();

      expect(result, equals('El código debe tener 6 caracteres válidos'));
    });

    testWidgets('retorna null cuando el formato es válido', (
      WidgetTester tester,
    ) async {
      String? result;
      await tester.pumpWidget(
        createLocalizedContext((context) {
          result = validateAccessCodeField(context, 'ABC234');
        }),
      );
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}

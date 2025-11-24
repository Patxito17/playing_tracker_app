import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/classes/presentation/utils/class_validators.dart';

void main() {
  group('normalizeAccessCode', () {
    test('elimina espacios y convierte a mayúsculas', () {
      expect(normalizeAccessCode('  abC123  '), equals('ABC123'));
    });
  });

  group('validateAccessCodeField', () {
    test('retorna error cuando el campo está vacío', () {
      expect(
        validateAccessCodeField(''),
        equals(ValidationStrings.required(ClassesStrings.accessCodeLabel)),
      );
    });

    test('retorna error cuando el formato es inválido', () {
      expect(
        validateAccessCodeField('A1B'),
        equals(ClassesStrings.accessCodeInvalidFormat),
      );
    });

    test('retorna null cuando el formato es válido', () {
      expect(validateAccessCodeField('ABC234'), isNull);
    });
  });
}

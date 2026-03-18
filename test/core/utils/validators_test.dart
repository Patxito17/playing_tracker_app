// Tests de los validadores de formulario en Validators.
//
// Mecanismo: invocación directa de métodos estáticos de la clase Validators;
//            sin mocks ni Firebase.
// Convención: retornar null = válido, retornar String = mensaje de error.

import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/core/utils/validators.dart';

void main() {
  // ---------------------------------------------------------------------------
  group('Validators.required', () {
    // Entradas: valor vacío / null.
    // Salida esperada: mensaje de error.
    test('retorna mensaje cuando el valor es null', () {
      expect(Validators.required(null, 'Campo requerido'), 'Campo requerido');
    });

    test('retorna mensaje cuando el valor es cadena vacía', () {
      expect(Validators.required('', 'Campo requerido'), 'Campo requerido');
    });

    test('retorna mensaje cuando el valor es solo espacios', () {
      expect(Validators.required('   ', 'Campo requerido'), 'Campo requerido');
    });

    // Entradas: valor con contenido.
    // Salida esperada: null (válido).
    test('retorna null cuando el valor tiene contenido', () {
      expect(Validators.required('hola', 'Error'), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.email', () {
    const reqMsg = 'Email requerido';
    const invMsg = 'Email inválido';

    // Entradas: campo vacío.
    // Salida esperada: mensaje de "requerido".
    test('retorna requiredMsg cuando está vacío', () {
      expect(
        Validators.email('', requiredMsg: reqMsg, invalidMsg: invMsg),
        reqMsg,
      );
    });

    // Entradas: formato incorrecto (sin @).
    // Salida esperada: mensaje de formato inválido.
    test('retorna invalidMsg cuando el formato es incorrecto', () {
      expect(
        Validators.email('noesun.email', requiredMsg: reqMsg, invalidMsg: invMsg),
        invMsg,
      );
    });

    // Entradas: email demasiado largo (>100 chars).
    //           Se construyen 95 'a' + '@test.com' = 104 caracteres.
    // Salida esperada: mensaje de formato inválido.
    test('retorna invalidMsg cuando el email supera 100 caracteres', () {
      final longEmail = '${'a' * 95}@test.com';
      expect(longEmail.length, greaterThan(100)); // verificación de precondición
      expect(
        Validators.email(longEmail, requiredMsg: reqMsg, invalidMsg: invMsg),
        invMsg,
      );
    });

    // Entradas: email válido estándar.
    // Salida esperada: null.
    test('retorna null para un email válido', () {
      expect(
        Validators.email(
          'usuario@ejemplo.com',
          requiredMsg: reqMsg,
          invalidMsg: invMsg,
        ),
        isNull,
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.password', () {
    const reqMsg = 'Contraseña requerida';
    const minMsg = 'Muy corta';

    // Entradas: campo vacío.
    // Salida esperada: requiredMsg.
    test('retorna requiredMsg cuando está vacía', () {
      expect(
        Validators.password('', requiredMsg: reqMsg, minLengthMsg: minMsg),
        reqMsg,
      );
    });

    // Entradas: contraseña de 5 caracteres (menor que el mínimo de 6).
    // Salida esperada: minLengthMsg.
    test('retorna minLengthMsg cuando tiene menos de 6 caracteres', () {
      expect(
        Validators.password('12345', requiredMsg: reqMsg, minLengthMsg: minMsg),
        minMsg,
      );
    });

    // Entradas: contraseña de exactamente 6 caracteres.
    // Salida esperada: null.
    test('retorna null con exactamente 6 caracteres', () {
      expect(
        Validators.password(
          '123456',
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
        ),
        isNull,
      );
    });

    // Entradas: contraseña larga.
    // Salida esperada: null.
    test('retorna null con una contraseña larga', () {
      expect(
        Validators.password(
          'MiContraseñaSegura123!',
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
        ),
        isNull,
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.name', () {
    const reqMsg = 'Nombre requerido';
    const minMsg = 'Muy corto';
    const maxMsg = 'Muy largo';
    const invalidMsg = 'Caracteres inválidos';

    // Entradas: nombre vacío.
    // Salida esperada: requiredMsg.
    test('retorna requiredMsg cuando está vacío', () {
      expect(
        Validators.name(
          '',
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
          maxLengthMsg: maxMsg,
          invalidCharactersMsg: invalidMsg,
        ),
        reqMsg,
      );
    });

    // Entradas: nombre de 1 carácter.
    // Salida esperada: minLengthMsg.
    test('retorna minLengthMsg con solo 1 carácter', () {
      expect(
        Validators.name(
          'A',
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
          maxLengthMsg: maxMsg,
          invalidCharactersMsg: invalidMsg,
        ),
        minMsg,
      );
    });

    // Entradas: nombre con 61 caracteres (supera el máximo de 60).
    // Salida esperada: maxLengthMsg.
    test('retorna maxLengthMsg cuando supera 60 caracteres', () {
      expect(
        Validators.name(
          'A' * 61,
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
          maxLengthMsg: maxMsg,
          invalidCharactersMsg: invalidMsg,
        ),
        maxMsg,
      );
    });

    // Entradas: nombre con caracteres numéricos.
    // Salida esperada: invalidCharactersMsg.
    test('retorna invalidCharactersMsg con dígitos en el nombre', () {
      expect(
        Validators.name(
          'Juan123',
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
          maxLengthMsg: maxMsg,
          invalidCharactersMsg: invalidMsg,
        ),
        invalidMsg,
      );
    });

    // Entradas: nombre válido con acentos y ñ.
    // Salida esperada: null.
    test('retorna null para un nombre válido con caracteres especiales', () {
      expect(
        Validators.name(
          'María Ñoño',
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
          maxLengthMsg: maxMsg,
          invalidCharactersMsg: invalidMsg,
        ),
        isNull,
      );
    });

    // Mecanismo: la normalización de espacios dobles debe producir nombre válido.
    // Entradas: "Juan  García" (dos espacios).
    // Salida esperada: null (normaliza a "Juan García").
    test('normaliza espacios múltiples y valida correctamente', () {
      expect(
        Validators.name(
          'Juan  García',
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
          maxLengthMsg: maxMsg,
          invalidCharactersMsg: invalidMsg,
        ),
        isNull,
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.title', () {
    const reqMsg = 'Título requerido';
    const minMsg = 'Muy corto';
    const maxMsg = 'Muy largo';

    // Entradas: título vacío.
    // Salida esperada: requiredMsg.
    test('retorna requiredMsg cuando está vacío', () {
      expect(
        Validators.title('', requiredMsg: reqMsg, minLengthMsg: minMsg, maxLengthMsg: maxMsg),
        reqMsg,
      );
    });

    // Entradas: título de 1 carácter.
    // Salida esperada: minLengthMsg.
    test('retorna minLengthMsg con solo 1 carácter', () {
      expect(
        Validators.title('A', requiredMsg: reqMsg, minLengthMsg: minMsg, maxLengthMsg: maxMsg),
        minMsg,
      );
    });

    // Entradas: título de 101 caracteres (supera el límite de 100).
    // Salida esperada: maxLengthMsg.
    test('retorna maxLengthMsg cuando supera 100 caracteres', () {
      expect(
        Validators.title(
          'A' * 101,
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
          maxLengthMsg: maxMsg,
        ),
        maxMsg,
      );
    });

    // Entradas: título válido.
    // Salida esperada: null.
    test('retorna null para un título válido', () {
      expect(
        Validators.title(
          'Escala de Do mayor',
          requiredMsg: reqMsg,
          minLengthMsg: minMsg,
          maxLengthMsg: maxMsg,
        ),
        isNull,
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.confirmPassword', () {
    const reqMsg = 'Confirmación requerida';
    const matchMsg = 'Las contraseñas no coinciden';

    // Entradas: confirmación vacía.
    // Salida esperada: requiredMsg.
    test('retorna requiredMsg cuando la confirmación está vacía', () {
      expect(
        Validators.confirmPassword(
          'password123',
          '',
          requiredMsg: reqMsg,
          matchMsg: matchMsg,
        ),
        reqMsg,
      );
    });

    // Entradas: contraseñas distintas.
    // Salida esperada: matchMsg.
    test('retorna matchMsg cuando las contraseñas no coinciden', () {
      expect(
        Validators.confirmPassword(
          'password123',
          'diferente',
          requiredMsg: reqMsg,
          matchMsg: matchMsg,
        ),
        matchMsg,
      );
    });

    // Entradas: contraseñas iguales.
    // Salida esperada: null.
    test('retorna null cuando las contraseñas coinciden', () {
      expect(
        Validators.confirmPassword(
          'password123',
          'password123',
          requiredMsg: reqMsg,
          matchMsg: matchMsg,
        ),
        isNull,
      );
    });
  });
}

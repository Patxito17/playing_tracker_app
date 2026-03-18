// Tests del FirebaseErrorMapper.
//
// Mecanismo: se instancian errores de Firebase (FirebaseAuthException,
//            FirebaseException) y se verifica que el mapper devuelve la clave
//            de localización esperada.
// Sin mocks ni Firebase real: se construyen los objetos de excepción
// directamente con los códigos de error conocidos.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';

void main() {
  group('FirebaseErrorMapper — errores de autenticación', () {
    // Helper para crear FirebaseAuthException con un código dado.
    FirebaseAuthException authError(String code) =>
        FirebaseAuthException(code: code);

    // Entradas: code == 'invalid-email'.
    // Salida esperada: 'authErrorInvalidEmail'.
    test("mapea 'invalid-email' a 'authErrorInvalidEmail'", () {
      expect(
        FirebaseErrorMapper.map(authError('invalid-email')),
        'authErrorInvalidEmail',
      );
    });

    // Entradas: code == 'user-disabled'.
    // Salida esperada: 'authErrorUserDisabled'.
    test("mapea 'user-disabled' a 'authErrorUserDisabled'", () {
      expect(
        FirebaseErrorMapper.map(authError('user-disabled')),
        'authErrorUserDisabled',
      );
    });

    // Entradas: code == 'user-not-found'.
    // Salida esperada: 'authErrorUserNotFound'.
    test("mapea 'user-not-found' a 'authErrorUserNotFound'", () {
      expect(
        FirebaseErrorMapper.map(authError('user-not-found')),
        'authErrorUserNotFound',
      );
    });

    // Entradas: code == 'wrong-password'.
    // Salida esperada: 'authErrorWrongPassword'.
    test("mapea 'wrong-password' a 'authErrorWrongPassword'", () {
      expect(
        FirebaseErrorMapper.map(authError('wrong-password')),
        'authErrorWrongPassword',
      );
    });

    // Entradas: code == 'email-already-in-use'.
    // Salida esperada: 'authErrorEmailAlreadyInUse'.
    test("mapea 'email-already-in-use' a 'authErrorEmailAlreadyInUse'", () {
      expect(
        FirebaseErrorMapper.map(authError('email-already-in-use')),
        'authErrorEmailAlreadyInUse',
      );
    });

    // Entradas: code == 'weak-password'.
    // Salida esperada: 'authErrorWeakPassword'.
    test("mapea 'weak-password' a 'authErrorWeakPassword'", () {
      expect(
        FirebaseErrorMapper.map(authError('weak-password')),
        'authErrorWeakPassword',
      );
    });

    // Entradas: code == 'too-many-requests'.
    // Salida esperada: 'authErrorTooManyRequests'.
    test("mapea 'too-many-requests' a 'authErrorTooManyRequests'", () {
      expect(
        FirebaseErrorMapper.map(authError('too-many-requests')),
        'authErrorTooManyRequests',
      );
    });

    // Entradas: code == 'operation-not-allowed'.
    // Salida esperada: 'authErrorOperationNotAllowed'.
    test("mapea 'operation-not-allowed' a 'authErrorOperationNotAllowed'", () {
      expect(
        FirebaseErrorMapper.map(authError('operation-not-allowed')),
        'authErrorOperationNotAllowed',
      );
    });

    // Entradas: code == 'invalid-credential'.
    // Salida esperada: 'authErrorInvalidCredential'.
    test("mapea 'invalid-credential' a 'authErrorInvalidCredential'", () {
      expect(
        FirebaseErrorMapper.map(authError('invalid-credential')),
        'authErrorInvalidCredential',
      );
    });

    // Entradas: code == 'network-request-failed'.
    // Salida esperada: 'errorNetworkRequestFailed'.
    test("mapea 'network-request-failed' a 'errorNetworkRequestFailed'", () {
      expect(
        FirebaseErrorMapper.map(authError('network-request-failed')),
        'errorNetworkRequestFailed',
      );
    });

    // Entradas: código desconocido en FirebaseAuthException.
    // Salida esperada: 'errorGeneric'.
    test('mapea código de auth desconocido a errorGeneric', () {
      expect(
        FirebaseErrorMapper.map(authError('unknown-code-xyz')),
        'errorGeneric',
      );
    });
  });

  group('FirebaseErrorMapper — errores genéricos de Firebase', () {
    // Helper para crear un FirebaseException de Firestore con un código dado.
    FirebaseException firestoreError(String code) =>
        FirebaseException(plugin: 'cloud_firestore', code: code);

    // Entradas: code == 'permission-denied'.
    // Salida esperada: 'errorPermissionDenied'.
    test("mapea 'permission-denied' a 'errorPermissionDenied'", () {
      expect(
        FirebaseErrorMapper.map(firestoreError('permission-denied')),
        'errorPermissionDenied',
      );
    });

    // Entradas: code == 'failed-precondition'.
    // Salida esperada: 'errorFailedPrecondition'.
    test("mapea 'failed-precondition' a 'errorFailedPrecondition'", () {
      expect(
        FirebaseErrorMapper.map(firestoreError('failed-precondition')),
        'errorFailedPrecondition',
      );
    });

    // Entradas: code == 'unavailable'.
    // Salida esperada: 'errorServiceUnavailable'.
    test("mapea 'unavailable' a 'errorServiceUnavailable'", () {
      expect(
        FirebaseErrorMapper.map(firestoreError('unavailable')),
        'errorServiceUnavailable',
      );
    });

    // Entradas: código de Firestore desconocido.
    // Salida esperada: 'errorGeneric'.
    test('mapea código Firestore desconocido a errorGeneric', () {
      expect(
        FirebaseErrorMapper.map(firestoreError('not-found')),
        'errorGeneric',
      );
    });
  });

  group('FirebaseErrorMapper — otros tipos de error', () {
    // Entradas: un String (ya es clave l10n).
    // Salida esperada: se devuelve el mismo String.
    test('devuelve el String directamente cuando el error es un String', () {
      expect(
        FirebaseErrorMapper.map('authErrorInvalidEmail'),
        'authErrorInvalidEmail',
      );
    });

    // Entradas: excepción Dart genérica (no Firebase).
    // Salida esperada: 'errorGeneric'.
    test('mapea Exception genérica a errorGeneric', () {
      expect(
        FirebaseErrorMapper.map(Exception('Error desconocido')),
        'errorGeneric',
      );
    });
  });

  group('FirebaseErrorMapperException', () {
    // Mecanismo: toString() debe incluir el mensaje.
    // Entradas: mensaje 'test error'.
    // Salida esperada: String con 'test error'.
    test('toString incluye el mensaje de error', () {
      final exception = FirebaseErrorMapperException('test error');
      expect(exception.toString(), contains('test error'));
    });
  });
}

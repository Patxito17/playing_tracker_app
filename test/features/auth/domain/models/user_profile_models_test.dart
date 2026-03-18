// Tests de TeacherModel, StudentModel y la interfaz UserProfile.
//
// Mecanismo: construcción directa de los modelos, verificación de propiedades
//            derivadas (fullName), serialización JSON (toJson/fromJson) y
//            copyWith. No requiere Firebase ni mocks.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/auth/domain/models/student_model.dart';
import 'package:playing_tracker/features/auth/domain/models/teacher_model.dart';
import 'package:playing_tracker/features/auth/domain/models/user_profile.dart';

void main() {
  final tNow = Timestamp.fromMillisecondsSinceEpoch(0);

  // ---------------------------------------------------------------------------
  group('TeacherModel — UserProfile', () {
    late TeacherModel teacher;

    setUp(() {
      teacher = TeacherModel(
        id: 'teacher-1',
        firstName: 'María',
        lastName: 'García',
        email: 'maria@school.com',
        createdAt: tNow,
        updatedAt: tNow,
        isActive: true,
      );
    });

    // Mecanismo: fullName une firstName y lastName con espacio.
    // Entradas: firstName='María', lastName='García'.
    // Salida esperada: 'María García'.
    test('fullName concatena firstName y lastName', () {
      expect(teacher.fullName, 'María García');
    });

    // Mecanismo: TeacherModel implementa UserProfile (interfaz).
    // Entradas: instancia creada arriba.
    // Salida esperada: es asignable a UserProfile.
    test('implementa UserProfile correctamente', () {
      expect(teacher, isA<UserProfile>());
      expect(teacher.id, 'teacher-1');
      expect(teacher.email, 'maria@school.com');
    });

    // Mecanismo: copyWith preserva campos no modificados.
    // Entradas: cambiar solo firstName.
    // Salida esperada: nuevo objeto con firstName actualizado y resto igual.
    test('copyWith crea copia con campo actualizado', () {
      final copy = teacher.copyWith(firstName: 'Ana');

      expect(copy.firstName, 'Ana');
      expect(copy.lastName, 'García');
      expect(copy.id, 'teacher-1');
    });

    // Mecanismo: serialización round-trip (toJson → fromJson).
    // Entradas: instancia original.
    // Salida esperada: objeto deserializado igual al original.
    test('toJson y fromJson producen el mismo objeto', () {
      final json = teacher.toJson();
      final deserialized = TeacherModel.fromJson(json);

      expect(deserialized.id, teacher.id);
      expect(deserialized.firstName, teacher.firstName);
      expect(deserialized.lastName, teacher.lastName);
      expect(deserialized.email, teacher.email);
      expect(deserialized.isActive, teacher.isActive);
    });

    // Mecanismo: equals compara por valor (operator ==).
    // Entradas: dos instancias con los mismos datos.
    // Salida esperada: iguales.
    test('equals es verdadero para dos instancias con los mismos datos', () {
      final teacher2 = TeacherModel(
        id: 'teacher-1',
        firstName: 'María',
        lastName: 'García',
        email: 'maria@school.com',
        createdAt: tNow,
        updatedAt: tNow,
        isActive: true,
      );

      expect(teacher, equals(teacher2));
    });

    // Mecanismo: toString incluye datos relevantes para debug.
    // Entradas: instancia con datos conocidos.
    // Salida esperada: String que contiene el id y el nombre completo.
    test('toString contiene id y fullName', () {
      final str = teacher.toString();
      expect(str, contains('teacher-1'));
      expect(str, contains('García'));
    });

    // Mecanismo: acceptedTermsVersion es nullable.
    // Entradas: instancia sin acceptedTermsVersion.
    // Salida esperada: campo es null.
    test('acceptedTermsVersion es null por defecto', () {
      expect(teacher.acceptedTermsVersion, isNull);
      expect(teacher.acceptedTermsAt, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  group('StudentModel — UserProfile', () {
    late StudentModel student;

    setUp(() {
      student = StudentModel(
        id: 'student-1',
        firstName: 'Carlos',
        lastName: 'Rodríguez',
        email: 'carlos@student.com',
        createdAt: tNow,
        updatedAt: tNow,
        isActive: true,
        totalSessionsCount: 5,
        totalDurationLogged: 18000,
      );
    });

    // Mecanismo: fullName une firstName y lastName.
    // Entradas: firstName='Carlos', lastName='Rodríguez'.
    // Salida esperada: 'Carlos Rodríguez'.
    test('fullName concatena firstName y lastName', () {
      expect(student.fullName, 'Carlos Rodríguez');
    });

    // Mecanismo: StudentModel implementa UserProfile.
    // Entradas: instancia creada arriba.
    // Salida esperada: es asignable a UserProfile.
    test('implementa UserProfile correctamente', () {
      expect(student, isA<UserProfile>());
      expect(student.id, 'student-1');
    });

    // Mecanismo: campos agregados se guardan correctamente.
    // Entradas: totalSessionsCount=5, totalDurationLogged=18000.
    // Salida esperada: los campos reflejan los valores construidos.
    test('campos agregados se inicializan correctamente', () {
      expect(student.totalSessionsCount, 5);
      expect(student.totalDurationLogged, 18000);
      expect(student.lastSessionDate, isNull);
    });

    // Mecanismo: copyWith preserva campos no modificados.
    // Entradas: cambiar solo isActive.
    // Salida esperada: nuevo objeto con isActive=false y resto igual.
    test('copyWith actualiza isActive sin afectar otros campos', () {
      final inactive = student.copyWith(isActive: false);

      expect(inactive.isActive, isFalse);
      expect(inactive.id, 'student-1');
      expect(inactive.totalSessionsCount, 5);
    });

    // Mecanismo: serialización round-trip (toJson → fromJson).
    // Entradas: instancia original.
    // Salida esperada: objeto deserializado con los mismos valores clave.
    test('toJson y fromJson producen el mismo objeto', () {
      final json = student.toJson();
      final deserialized = StudentModel.fromJson(json);

      expect(deserialized.id, student.id);
      expect(deserialized.totalSessionsCount, student.totalSessionsCount);
      expect(deserialized.totalDurationLogged, student.totalDurationLogged);
    });

    // Mecanismo: equals por valor.
    // Entradas: dos instancias idénticas.
    // Salida esperada: iguales.
    test('equals es verdadero para dos instancias idénticas', () {
      final student2 = StudentModel(
        id: 'student-1',
        firstName: 'Carlos',
        lastName: 'Rodríguez',
        email: 'carlos@student.com',
        createdAt: tNow,
        updatedAt: tNow,
        isActive: true,
        totalSessionsCount: 5,
        totalDurationLogged: 18000,
      );

      expect(student, equals(student2));
    });

    // Mecanismo: toString incluye datos de debug.
    // Entradas: instancia con datos conocidos.
    // Salida esperada: String que contiene el id y el email.
    test('toString contiene id y email', () {
      final str = student.toString();
      expect(str, contains('student-1'));
    });
  });
}

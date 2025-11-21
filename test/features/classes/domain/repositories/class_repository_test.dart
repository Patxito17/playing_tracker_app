import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/create_class_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';

/// Mock utilizado para definir expectativas sin tocar Firestore.
class MockClassRepository extends Mock implements ClassRepository {}

void main() {
  setUp(() {
    // TODO(sprint3-phase4): Inicializar repositorio real cuando exista implementación.
  });

  group('createClass', () {
    test(
      'debe validar input y retornar ClassModel persistido',
      () {
        final input = (
          name: 'Nueva clase',
          description: 'Descripción opcional',
          ownerId: 'teacher-123',
        );
        expect(() => validateCreateClassInput(input), returnsNormally);
        // TODO(sprint3-phase4): Implementar usando fake_cloud_firestore.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación (Fase 4 - servicios/repositorio)',
    );
  });

  group('watchTeacherClasses', () {
    test(
      'debe emitir lotes paginados de hasta 20 clases por docente',
      () {
        // TODO(sprint3-phase4): Simular snapshots en memoria para validar paginación.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación (hook stream Firestore)',
    );
  });

  group('getClassById', () {
    test(
      'debe retornar null cuando la clase no existe',
      () {
        // TODO(sprint3-phase4): Mockear repositorio y asegurar null-handling.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación',
    );
  });

  group('inviteStudent', () {
    test(
      'debe lanzar DuplicateAccessCodeException cuando la membresía ya existe',
      () {
        final input = (
          classId: 'class-id',
          studentId: 'student-id',
          teacherId: 'teacher-id',
          className: 'Clase Demo',
        );

        expect(() => validateInviteStudentInput(input), returnsNormally);
        // TODO(sprint3-phase5): Cubrir interacción con MembershipService.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación',
    );
  });

  group('joinClassWithCode', () {
    test(
      'debe lanzar InvalidAccessCodeException cuando el código no existe',
      () {
        final input = (studentId: 'student-1', accessCode: 'ABC123');
        expect(() => validateJoinClassInput(input), returnsNormally);
        // TODO(sprint3-phase6): Validar flujo completo con código inexistente.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación',
    );
  });

  group('updateClassStatus', () {
    test(
      'debe permitir archivar y reactivar clases',
      () {
        final model = ClassModel(
          id: 'class-1',
          name: 'Clase demo',
          ownerTeacherId: 'teacher-1',
          accessCode: 'ABC123',
          createdAt: Timestamp(0, 0),
          updatedAt: Timestamp(0, 0),
          isActive: true,
        );

        expect(model.canJoin, isTrue);
        // TODO(sprint3-phase4): Verificar calls al servicio con retries.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación',
    );
  });

  group('removeStudentFromClass', () {
    test(
      'debe remover alumno y emitir MembershipNotFoundException si no existe',
      () {
        // TODO(sprint3-phase7): Simular borrado lógico con mocktail.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación',
    );
  });

  group('regenerateAccessCode', () {
    test(
      'debe generar código único y actualizar la clase',
      () {
        // TODO(sprint3-phase7): Validar integración con AccessCodeGenerator.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación',
    );
  });

  group('fanOutTask', () {
    test(
      'debe delegar en FanOutHelper y registrar TODO para Sprint 4',
      () {
        // TODO(sprint4): Integrar con helper fan-out y assignments.
        fail('Not implemented yet');
      },
      skip: 'Pendiente de implementación',
    );
  });
}

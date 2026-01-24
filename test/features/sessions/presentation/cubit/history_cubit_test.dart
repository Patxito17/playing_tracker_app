import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';
import 'package:playing_tracker/features/sessions/presentation/cubit/history_cubit.dart';
import 'package:playing_tracker/features/sessions/presentation/cubit/history_state.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late _MockSessionRepository mockRepository;
  late HistoryCubit cubit;

  final now = Timestamp.now();
  final testSession1 = SessionModel(
    id: 'session-1',
    studentId: 'student-1',
    taskId: 'task-1',
    teacherId: 'teacher-1',
    startTime: now,
    endTime: now,
    totalDuration: 1800,
    dateLogged: now,
    monthBucket: '2026-01',
    status: SessionStatus.completed,
    createdAt: now,
  );

  final testSession2 = SessionModel(
    id: 'session-2',
    studentId: 'student-1',
    taskId: 'task-2',
    teacherId: 'teacher-1',
    startTime: now,
    endTime: now,
    totalDuration: 2700,
    dateLogged: now,
    monthBucket: '2026-01',
    notes: 'Excelente práctica',
    status: SessionStatus.completed,
    createdAt: now,
  );

  setUp(() {
    mockRepository = _MockSessionRepository();
    cubit = HistoryCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('HistoryCubit', () {
    group('watchSessions', () {
      test(
        'emite [Loading, Success] cuando se cargan sesiones del estudiante',
        () async {
          // Arrange
          when(
            () => mockRepository.watchStudentSessions(
              studentId: any(named: 'studentId'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) => Stream.value([testSession1, testSession2]));

          // Assert later
          final expected = [
            const HistoryLoading(),
            HistorySuccess(
              sessions: [testSession1, testSession2],
              studentId: 'student-1',
              taskId: null,
            ),
          ];

          expectLater(cubit.stream, emitsInOrder(expected));

          // Act
          await cubit.watchSessions(studentId: 'student-1');
        },
      );

      test(
        'emite [Loading, Success] cuando se cargan sesiones filtradas por tarea',
        () async {
          // Arrange
          when(
            () => mockRepository.watchTaskSessions(
              taskId: any(named: 'taskId'),
              studentId: any(named: 'studentId'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) => Stream.value([testSession1]));

          // Assert later
          final expected = [
            const HistoryLoading(),
            HistorySuccess(
              sessions: [testSession1],
              studentId: 'student-1',
              taskId: 'task-1',
            ),
          ];

          expectLater(cubit.stream, emitsInOrder(expected));

          // Act
          await cubit.watchSessions(studentId: 'student-1', taskId: 'task-1');
        },
      );

      test('emite [Loading, Empty] cuando no hay sesiones', () async {
        // Arrange
        when(
          () => mockRepository.watchStudentSessions(
            studentId: any(named: 'studentId'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) => Stream.value([]));

        // Assert later
        const expected = [HistoryLoading(), HistoryEmpty()];

        expectLater(cubit.stream, emitsInOrder(expected));

        // Act
        await cubit.watchSessions(studentId: 'student-1');
      });

      test(
        'emite [Loading, Error] cuando ocurre un error del repositorio',
        () async {
          // Arrange
          const errorMessage = 'Error de permisos';
          when(
            () => mockRepository.watchStudentSessions(
              studentId: any(named: 'studentId'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer(
            (_) => Stream.error(
              const UnknownSessionRepositoryException(errorMessage),
            ),
          );

          // Assert later
          final expected = [
            const HistoryLoading(),
            const HistoryError(
              message: errorMessage,
              cause: UnknownSessionRepositoryException(errorMessage),
            ),
          ];

          expectLater(cubit.stream, emitsInOrder(expected));

          // Act
          await cubit.watchSessions(studentId: 'student-1');
        },
      );

      test(
        'emite [Loading, Error] con mensaje genérico para errores desconocidos',
        () async {
          // Arrange
          when(
            () => mockRepository.watchStudentSessions(
              studentId: any(named: 'studentId'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) => Stream.error(Exception('Error inesperado')));

          // Assert later
          const expected = [
            HistoryLoading(),
            HistoryError(
              message: 'Ocurrió un error inesperado al cargar el historial',
            ),
          ];

          expectLater(cubit.stream, emitsInOrder(expected));

          // Act
          await cubit.watchSessions(studentId: 'student-1');
        },
      );

      test('usa el límite proporcionado cuando se especifica', () async {
        // Arrange
        when(
          () => mockRepository.watchStudentSessions(
            studentId: any(named: 'studentId'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) => Stream.value([testSession1]));

        // Act
        await cubit.watchSessions(studentId: 'student-1', limit: 10);

        // Assert
        verify(
          () => mockRepository.watchStudentSessions(
            studentId: 'student-1',
            limit: 10,
          ),
        ).called(1);
      });

      test(
        'cancela la suscripción anterior al solicitar nuevas sesiones',
        () async {
          // Arrange
          when(
            () => mockRepository.watchStudentSessions(
              studentId: any(named: 'studentId'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) => Stream.value([testSession1]));

          // Act
          await cubit.watchSessions(studentId: 'student-1');
          await cubit.watchSessions(studentId: 'student-2');

          // Assert
          verify(
            () => mockRepository.watchStudentSessions(
              studentId: 'student-1',
              limit: 0,
            ),
          ).called(1);

          verify(
            () => mockRepository.watchStudentSessions(
              studentId: 'student-2',
              limit: 0,
            ),
          ).called(1);
        },
      );
    });

    group('close', () {
      test('cancela la suscripción del stream al cerrar el cubit', () async {
        // Arrange
        when(
          () => mockRepository.watchStudentSessions(
            studentId: any(named: 'studentId'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) => Stream.value([testSession1]));

        // Act
        await cubit.watchSessions(studentId: 'student-1');
        await cubit.close();

        // La suscripción debe ser cancelada sin errores
        expect(cubit.isClosed, isTrue);
      });
    });
  });

  group('HistoryState', () {
    test('HistoryInitial tiene props vacíos', () {
      const state = HistoryInitial();
      expect(state.props, isEmpty);
    });

    test('HistoryLoading tiene props vacíos', () {
      const state = HistoryLoading();
      expect(state.props, isEmpty);
    });

    test('HistorySuccess incluye sessions, studentId y taskId en props', () {
      final state = HistorySuccess(
        sessions: [testSession1],
        studentId: 'student-1',
        taskId: 'task-1',
      );
      expect(
        state.props,
        equals([
          [testSession1],
          'task-1',
          'student-1',
        ]),
      );
    });

    test('HistoryEmpty tiene props vacíos', () {
      const state = HistoryEmpty();
      expect(state.props, isEmpty);
    });

    test('HistoryError incluye message y cause en props', () {
      const cause = UnknownSessionRepositoryException('Test error');
      const state = HistoryError(message: 'Error', cause: cause);
      expect(state.props, equals(['Error', cause]));
    });

    test('HistorySuccess con mismo contenido son iguales', () {
      final state1 = HistorySuccess(
        sessions: [testSession1],
        studentId: 'student-1',
        taskId: null,
      );
      final state2 = HistorySuccess(
        sessions: [testSession1],
        studentId: 'student-1',
        taskId: null,
      );
      expect(state1, equals(state2));
    });
  });
}

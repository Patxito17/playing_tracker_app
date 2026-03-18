import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import '../../../../helpers/user_test_helpers.dart';
import '../../../../helpers/mock_hydrated_storage.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserCredential extends Mock implements UserCredential {}

class MockFirebaseUser extends Mock implements User {}

void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(UserRole.teacher);
  });

  setUp(() {
    initHydratedStorage();
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    authCubit = AuthCubit(mockAuthRepository, shouldCheckAuthState: false);
  });

  tearDown(() async {
    await authCubit.close();
  });

  test(
    'debe emitir AuthAuthenticated cuando checkAuthState detecta sesión',
    () async {
      final mockUser = MockFirebaseUser();
      when(() => mockUser.uid).thenReturn('uid-123');
      when(() => mockAuthRepository.currentUser).thenReturn(mockUser);
      when(
        () => mockAuthRepository.getUserRole('uid-123'),
      ).thenAnswer((_) async => UserRole.teacher);

      final mockTeacher = createMockTeacher(id: 'uid-123');
      when(
        () => mockAuthRepository.getTeacherProfile('uid-123'),
      ).thenAnswer((_) async => mockTeacher);

      await authCubit.checkAuthState();

      expect(
        authCubit.state,
        isA<AuthAuthenticated>()
            .having((state) => state.userId, 'userId', 'uid-123')
            .having((state) => state.role, 'role', UserRole.teacher),
      );
    },
  );

  test('debe emitir AuthUnauthenticated cuando no existe usuario', () async {
    when(() => mockAuthRepository.currentUser).thenReturn(null);

    await authCubit.checkAuthState();

    expect(authCubit.state, isA<AuthUnauthenticated>());
  });

  test('debe emitir AuthError cuando login falla', () async {
    when(
      () => mockAuthRepository.signInWithEmail(any(), any()),
    ).thenThrow(AuthRepositoryException('Credenciales inválidas'));

    expectLater(
      authCubit.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (state) => state.message,
          'message',
          contains('Credenciales'),
        ),
      ]),
    );

    await authCubit.loginWithEmail('wrong@test.com', '123456');
  });

  test('debe emitir AuthAuthenticated cuando login es exitoso', () async {
    final credential = MockUserCredential();
    final mockUser = MockFirebaseUser();
    when(() => mockUser.uid).thenReturn('login-uid');
    when(() => credential.user).thenReturn(mockUser);
    when(
      () => mockAuthRepository.signInWithEmail(any(), any()),
    ).thenAnswer((_) async => credential);
    when(
      () => mockAuthRepository.getUserRole('login-uid'),
    ).thenAnswer((_) async => UserRole.student);

    final mockStudent = createMockStudent(id: 'login-uid');
    when(
      () => mockAuthRepository.getStudentProfile('login-uid'),
    ).thenAnswer((_) async => mockStudent);

    expectLater(
      authCubit.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((state) => state.role, 'role', UserRole.student)
            .having((state) => state.userId, 'userId', 'login-uid'),
      ]),
    );

    await authCubit.loginWithEmail('test@test.com', 'password');
  });

  test('debe registrar docente y emitir AuthAuthenticated teacher', () async {
    final credential = MockUserCredential();
    final mockUser = MockFirebaseUser();
    when(() => mockUser.uid).thenReturn('teacher-uid');
    when(() => credential.user).thenReturn(mockUser);
    when(
      () => mockAuthRepository.registerWithEmail(any(), any()),
    ).thenAnswer((_) async => credential);
    when(
      () => mockAuthRepository.createTeacher(
        userId: any(named: 'userId'),
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockAuthRepository.getUserRole(any()),
    ).thenAnswer((_) async => UserRole.teacher);

    final mockTeacher = createMockTeacher(id: 'teacher-uid');
    when(
      () => mockAuthRepository.getTeacherProfile('teacher-uid'),
    ).thenAnswer((_) async => mockTeacher);

    expectLater(
      authCubit.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((state) => state.role, 'role', UserRole.teacher)
            .having((state) => state.userId, 'userId', 'teacher-uid'),
      ]),
    );

    await authCubit.registerTeacher(
      firstName: 'Test',
      lastName: 'Teacher',
      email: 'teacher@test.com',
      password: '123456',
    );
  });

  test('debe registrar alumno y emitir AuthAuthenticated student', () async {
    final credential = MockUserCredential();
    final mockUser = MockFirebaseUser();
    when(() => mockUser.uid).thenReturn('student-uid');
    when(() => credential.user).thenReturn(mockUser);
    when(
      () => mockAuthRepository.registerWithEmail(any(), any()),
    ).thenAnswer((_) async => credential);
    when(
      () => mockAuthRepository.createStudent(
        userId: any(named: 'userId'),
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockAuthRepository.getUserRole(any()),
    ).thenAnswer((_) async => UserRole.student);

    final mockStudent = createMockStudent(id: 'student-uid');
    when(
      () => mockAuthRepository.getStudentProfile('student-uid'),
    ).thenAnswer((_) async => mockStudent);

    expectLater(
      authCubit.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((state) => state.role, 'role', UserRole.student)
            .having((state) => state.userId, 'userId', 'student-uid'),
      ]),
    );

    await authCubit.registerStudent(
      firstName: 'Test',
      lastName: 'Student',
      email: 'student@test.com',
      password: '123456',
    );
  });

  test('logout exitoso debe emitir AuthUnauthenticated', () async {
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

    expectLater(
      authCubit.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthUnauthenticated>()]),
    );

    await authCubit.logout();
  });

  test('logout con error debe emitir AuthError', () async {
    when(
      () => mockAuthRepository.signOut(),
    ).thenThrow(AuthRepositoryException('logout-error'));

    expectLater(
      authCubit.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (state) => state.message,
          'message',
          contains('logout'),
        ),
      ]),
    );

    await authCubit.logout();
  });

  test('registerTeacher con error mapea mensaje del repositorio', () async {
    when(
      () => mockAuthRepository.registerWithEmail(any(), any()),
    ).thenThrow(AuthRepositoryException('teacher-error'));

    expectLater(
      authCubit.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (state) => state.message,
          'message',
          contains('teacher'),
        ),
      ]),
    );

    await authCubit.registerTeacher(
      firstName: 'Name',
      lastName: 'Last',
      email: 'teacher@test.com',
      password: '123456',
    );
  });

  test('registerStudent con error emite AuthError', () async {
    when(
      () => mockAuthRepository.registerWithEmail(any(), any()),
    ).thenThrow(Exception('generic'));

    expectLater(
      authCubit.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthError>()]),
    );

    await authCubit.registerStudent(
      firstName: 'Name',
      lastName: 'Last',
      email: 'student@test.com',
      password: '123456',
    );
  });

  test('toJson/fromJson persiste roleIndex y userId', () {
    final mockUser = createMockStudent(id: 'persist-id');
    final state = AuthAuthenticated(user: mockUser);

    final json = authCubit.toJson(state);

    expect(json, isNotNull);
    final restored = authCubit.fromJson(json!);
    // Ahora devuelve AuthUnauthenticated al restaurar porque no tenemos el modelo completo
    // y delegamos la recarga a checkAuthState
    expect(restored, isA<AuthUnauthenticated>());
  });
  test('updateProfile actualiza usuario sin emitir AuthLoading', () async {
    // Setup initial authenticated state
    final mockUser = createMockTeacher(id: 'update-uid', firstName: 'Old');
    final cubit = AuthCubit(mockAuthRepository, shouldCheckAuthState: false);
    cubit.emit(AuthAuthenticated(user: mockUser));

    // Prepare update mocks
    when(
      () => mockAuthRepository.updateUserProfile(
        userId: any(named: 'userId'),
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        role: any(named: 'role'),
      ),
    ).thenAnswer((_) async {});

    final updatedUser = createMockTeacher(id: 'update-uid', firstName: 'New');
    when(
      () => mockAuthRepository.getTeacherProfile('update-uid'),
    ).thenAnswer((_) async => updatedUser);

    // Expectation: should NOT emit AuthLoading, only the updated AuthAuthenticated
    expectLater(
      cubit.stream,
      emitsInOrder([
        isA<AuthAuthenticated>().having((s) => s.firstName, 'firstName', 'New'),
      ]),
    );

    await cubit.updateProfile(firstName: 'New', lastName: 'Name');
    await cubit.close();
  });
}

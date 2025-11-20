import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';

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

      await authCubit.checkAuthState();

      expect(
        authCubit.state,
        isA<AuthAuthenticated>()
            .having((state) => state.userId, 'userId', 'uid-123')
            .having((state) => state.role, 'role', UserRole.teacher),
      );
    },
  );

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

  test('logout exitoso debe emitir AuthUnauthenticated', () async {
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

    expectLater(
      authCubit.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthUnauthenticated>()]),
    );

    await authCubit.logout();
  });

  test('toJson/fromJson solo persiste AuthAuthenticated', () {
    final state = AuthAuthenticated(
      role: UserRole.student,
      userId: 'persist-id',
    );

    final json = authCubit.toJson(state);

    expect(json, isNotNull);
    final restored = authCubit.fromJson(json!);
    expect(
      restored,
      isA<AuthAuthenticated>()
          .having((s) => s.userId, 'userId', 'persist-id')
          .having((s) => s.role, 'role', UserRole.student),
    );
  });
}

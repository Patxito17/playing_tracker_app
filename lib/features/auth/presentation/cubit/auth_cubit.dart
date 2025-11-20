import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';

/// Cubit responsable de manejar el estado de autenticación de la app.
///
/// Utiliza [HydratedCubit] para persistir el rol y el `userId` entre reinicios,
/// evitando mostrar pantallas de login innecesarias cuando la sesión sigue
/// vigente.
class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit(this._authRepository, {bool shouldCheckAuthState = true})
    : _shouldCheckAuthState = shouldCheckAuthState,
      super(const AuthInitial()) {
    if (_shouldCheckAuthState) {
      // Verificamos el estado de autenticación al inicializar el cubit.
      unawaited(_initialize());
    }
  }

  final AuthRepository _authRepository;
  final bool _shouldCheckAuthState;

  Future<void> _initialize() async {
    // Si ya existe un estado autenticado restaurado por HydratedBloc,
    // de cualquier forma validamos contra Firebase para garantizar consistencia.
    await checkAuthState();
  }

  /// Verifica si existe una sesión activa en Firebase Auth.
  Future<void> checkAuthState() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final role = await _authRepository.getUserRole(currentUser.uid);
      emit(AuthAuthenticated(role: role, userId: currentUser.uid));
    } catch (error) {
      emit(AuthError(_mapError(error)));
    }
  }

  /// Inicia sesión con email y contraseña.
  Future<void> loginWithEmail(String email, String password) async {
    emit(const AuthLoading());
    try {
      final credential = await _authRepository.signInWithEmail(email, password);
      final userId = credential.user?.uid;
      if (userId == null) {
        emit(const AuthError('No se pudo obtener el usuario autenticado.'));
        return;
      }
      final role = await _authRepository.getUserRole(userId);
      emit(AuthAuthenticated(role: role, userId: userId));
    } catch (error) {
      emit(AuthError(_mapError(error)));
    }
  }

  /// Registra un docente y crea su documento en Firestore.
  Future<void> registerTeacher({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final credential = await _authRepository.registerWithEmail(
        email,
        password,
      );
      final userId = credential.user?.uid;
      if (userId == null) {
        emit(const AuthError('No se pudo crear el usuario docente.'));
        return;
      }

      await _authRepository.createTeacher(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      emit(AuthAuthenticated(role: UserRole.teacher, userId: userId));
    } catch (error) {
      emit(AuthError(_mapError(error)));
    }
  }

  /// Registra un alumno y crea su documento en Firestore.
  Future<void> registerStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final credential = await _authRepository.registerWithEmail(
        email,
        password,
      );
      final userId = credential.user?.uid;
      if (userId == null) {
        emit(const AuthError('No se pudo crear el usuario alumno.'));
        return;
      }

      await _authRepository.createStudent(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      emit(AuthAuthenticated(role: UserRole.student, userId: userId));
    } catch (error) {
      emit(AuthError(_mapError(error)));
    }
  }

  /// Cierra la sesión actual.
  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(AuthError(_mapError(error)));
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String?;
      if (type != 'authenticated') {
        return const AuthUnauthenticated();
      }

      final roleIndex = json['roleIndex'] as int;
      final userId = json['userId'] as String?;
      if (userId == null) {
        return const AuthUnauthenticated();
      }

      return AuthAuthenticated(
        role: UserRole.values[roleIndex],
        userId: userId,
      );
    } catch (_) {
      return const AuthUnauthenticated();
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is! AuthAuthenticated) {
      return null;
    }

    return {
      'type': 'authenticated',
      'roleIndex': state.role.index,
      'userId': state.userId,
    };
  }

  String _mapError(Object error) {
    if (error is AuthRepositoryException) {
      return error.message;
    }
    return FirebaseErrorMapper.map(error);
  }
}

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

      // Cargar el modelo completo del usuario
      dynamic userModel;
      if (role == UserRole.teacher) {
        userModel = await _authRepository.getTeacherProfile(currentUser.uid);
      } else {
        userModel = await _authRepository.getStudentProfile(currentUser.uid);
      }

      if (userModel == null) {
        emit(const AuthError('No se pudo cargar el perfil del usuario.'));
        return;
      }

      emit(AuthAuthenticated(user: userModel));
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

      // Cargar el modelo completo del usuario
      dynamic userModel;
      if (role == UserRole.teacher) {
        userModel = await _authRepository.getTeacherProfile(userId);
      } else {
        userModel = await _authRepository.getStudentProfile(userId);
      }

      if (userModel == null) {
        emit(const AuthError('No se pudo cargar el perfil del usuario.'));
        return;
      }

      emit(AuthAuthenticated(user: userModel));
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
    String? acceptedTermsVersion,
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
        acceptedTermsVersion: acceptedTermsVersion,
      );

      // Esperar a que el Custom Claim 'teacher' esté activo en el token.
      // getUserRole implementa reintentos para dar tiempo a la Cloud Function.
      await _authRepository.getUserRole(userId);

      // Cargar el modelo recién creado
      final teacherModel = await _authRepository.getTeacherProfile(userId);
      if (teacherModel == null) {
        emit(const AuthError('No se pudo cargar el perfil del docente.'));
        return;
      }

      emit(AuthAuthenticated(user: teacherModel));
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
    String? acceptedTermsVersion,
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
        acceptedTermsVersion: acceptedTermsVersion,
      );

      // Esperar a que el Custom Claim 'student' esté activo en el token.
      await _authRepository.getUserRole(userId);

      // Cargar el modelo recién creado
      final studentModel = await _authRepository.getStudentProfile(userId);
      if (studentModel == null) {
        emit(const AuthError('No se pudo cargar el perfil del alumno.'));
        return;
      }

      emit(AuthAuthenticated(user: studentModel));
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

  /// Inicia sesión con Google Sign-In.
  ///
  /// Si el usuario ya tiene perfil en Firestore, emite [AuthAuthenticated].
  /// Si es un usuario nuevo, emite [AuthProfileIncomplete] para que el router
  /// redirija a `CompleteProfileScreen`.
  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final credential = await _authRepository.signInWithGoogle();
      final userId = credential.user?.uid;
      if (userId == null) {
        emit(const AuthError('No se pudo obtener el usuario autenticado.'));
        return;
      }

      final role = await _authRepository.getUserRole(userId);

      dynamic userModel;
      if (role == UserRole.teacher) {
        userModel = await _authRepository.getTeacherProfile(userId);
      } else {
        userModel = await _authRepository.getStudentProfile(userId);
      }

      if (userModel == null) {
        emit(const AuthError('No se pudo cargar el perfil del usuario.'));
        return;
      }

      emit(AuthAuthenticated(user: userModel));
    } on ProfileNotFoundException {
      // Nuevo usuario de Google: autenticado en Firebase pero sin perfil.
      // Pasamos el email y displayName del usuario de Firebase para pre-rellenar.
      final fbUser = _authRepository.currentUser;
      emit(
        AuthProfileIncomplete(
          email: fbUser?.email,
          displayName: fbUser?.displayName,
        ),
      );
    } on AuthRepositoryException catch (e) {
      if (e.message == 'googleSignInCanceled') {
        // El usuario canceló el selector: volvemos al estado anterior sin mostrar error.
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthError(e.message));
      }
    } catch (error) {
      emit(AuthError(_mapError(error)));
    }
  }

  /// Inicia sesión con Apple Sign-In (iOS).
  Future<void> signInWithApple() async {
    emit(const AuthLoading());
    try {
      final credential = await _authRepository.signInWithApple();
      final userId = credential.user?.uid;
      if (userId == null) {
        emit(const AuthError('No se pudo obtener el usuario autenticado.'));
        return;
      }

      final role = await _authRepository.getUserRole(userId);

      dynamic userModel;
      if (role == UserRole.teacher) {
        userModel = await _authRepository.getTeacherProfile(userId);
      } else {
        userModel = await _authRepository.getStudentProfile(userId);
      }

      if (userModel == null) {
        emit(const AuthError('No se pudo cargar el perfil del usuario.'));
        return;
      }

      emit(AuthAuthenticated(user: userModel));
    } on ProfileNotFoundException {
      // Nuevo usuario de Apple: autenticado en Firebase pero sin perfil.
      final fbUser = _authRepository.currentUser;
      emit(
        AuthProfileIncomplete(
          email: fbUser?.email,
          displayName: fbUser?.displayName,
        ),
      );
    } on AuthRepositoryException catch (e) {
      if (e.message == 'appleSignInCanceled') {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthError(e.message));
      }
    } catch (error) {
      emit(AuthError(_mapError(error)));
    }
  }

  /// Completa el registro de un docente autenticado vía proveedor social (Google o Apple).
  Future<void> completeSocialTeacherProfile({
    required String firstName,
    required String lastName,
    String? acceptedTermsVersion,
  }) async {
    emit(const AuthLoading());
    try {
      await _authRepository.completeSocialTeacherProfile(
        firstName: firstName,
        lastName: lastName,
        acceptedTermsVersion: acceptedTermsVersion,
      );

      final userId = _authRepository.currentUser?.uid;
      if (userId == null) {
        emit(const AuthError('No se pudo obtener el usuario autenticado.'));
        return;
      }

      await _authRepository.getUserRole(userId);
      final teacherModel = await _authRepository.getTeacherProfile(userId);
      if (teacherModel == null) {
        emit(const AuthError('No se pudo cargar el perfil del docente.'));
        return;
      }

      emit(AuthAuthenticated(user: teacherModel));
    } catch (error) {
      emit(AuthError(_mapError(error)));
    }
  }

  /// Completa el registro de un alumno autenticado vía proveedor social (Google o Apple).
  Future<void> completeSocialStudentProfile({
    required String firstName,
    required String lastName,
    String? acceptedTermsVersion,
  }) async {
    emit(const AuthLoading());
    try {
      await _authRepository.completeSocialStudentProfile(
        firstName: firstName,
        lastName: lastName,
        acceptedTermsVersion: acceptedTermsVersion,
      );

      final userId = _authRepository.currentUser?.uid;
      if (userId == null) {
        emit(const AuthError('No se pudo obtener el usuario autenticado.'));
        return;
      }

      await _authRepository.getUserRole(userId);
      final studentModel = await _authRepository.getStudentProfile(userId);
      if (studentModel == null) {
        emit(const AuthError('No se pudo cargar el perfil del alumno.'));
        return;
      }

      emit(AuthAuthenticated(user: studentModel));
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

      final userId = json['userId'] as String?;
      if (userId == null) {
        return const AuthUnauthenticated();
      }

      // Cargar el modelo desde Firestore al rehidratar
      // Nota: esto es asíncrono, por lo que podría no funcionar bien con hydrated_bloc
      // En este caso, dejaríamos que checkAuthState se encargue al iniciar
      return const AuthUnauthenticated();
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

  /// Actualiza el perfil del usuario (nombre y apellidos).
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      emit(const AuthError('No hay sesión activa para actualizar.'));
      return;
    }

    // Evitamos emitir AuthLoading para no disparar redirecciones globales
    // emit(const AuthLoading());
    try {
      await _authRepository.updateUserProfile(
        userId: currentState.userId,
        firstName: firstName,
        lastName: lastName,
      );

      // Recargar el modelo actualizado
      final role = currentState.role;
      dynamic updatedModel;
      if (role == UserRole.teacher) {
        updatedModel = await _authRepository.getTeacherProfile(
          currentState.userId,
        );
      } else {
        updatedModel = await _authRepository.getStudentProfile(
          currentState.userId,
        );
      }

      if (updatedModel == null) {
        emit(const AuthError('No se pudo cargar el perfil actualizado.'));
        return;
      }

      emit(AuthAuthenticated(user: updatedModel));
    } catch (error) {
      emit(AuthError(_mapError(error)));
      // Restaurar el estado anterior en caso de error
      emit(currentState);
    }
  }

  String _mapError(Object error) {
    if (error is AuthRepositoryException) {
      return error.message;
    }
    return FirebaseErrorMapper.map(error);
  }
}

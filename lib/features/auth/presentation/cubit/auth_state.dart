import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';
import 'package:playing_tracker/features/auth/domain/models/student_model.dart';
import 'package:playing_tracker/features/auth/domain/models/teacher_model.dart';
import 'package:playing_tracker/features/auth/domain/models/user_profile.dart';

/// Estados posibles para el flujo de autenticación de Playing Tracker.
///
/// Se usan sealed classes para aprovechar pattern matching con `switch`
/// y asegurar exhaustividad en compilación.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del cubit, previo a verificar la sesión almacenada.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado que indica que se está realizando una operación de autenticación.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado que representa a un usuario autenticado con su modelo completo.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  /// Modelo completo del usuario (TeacherModel o StudentModel).
  /// Tipado como [UserProfile] para acceso seguro a campos comunes.
  final UserProfile user;

  /// Rol del usuario derivado del tipo del modelo.
  UserRole get role {
    if (user is TeacherModel) return UserRole.teacher;
    if (user is StudentModel) return UserRole.student;
    throw StateError('Unknown user type: ${user.runtimeType}');
  }

  /// ID del usuario (acceso directo al campo id del modelo).
  String get userId => user.id;

  /// Nombre del usuario (acceso directo).
  String get firstName => user.firstName;

  /// Apellidos del usuario (acceso directo).
  String get lastName => user.lastName;

  /// Nombre completo del usuario.
  String get fullName => user.fullName;

  @override
  List<Object?> get props => [user];
}

/// Estado que indica que no hay sesión activa.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado que comunica un error durante alguna operación de autenticación.
final class AuthError extends AuthState {
  const AuthError(this.message);

  /// Mensaje legible que se mostrará mediante `SelectableText.rich`.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Estado que indica que el usuario se ha autenticado con Google pero aún
/// no tiene perfil en Firestore. El router debe redirigir a
/// `CompleteProfileScreen` para que complete su registro.
final class AuthProfileIncomplete extends AuthState {
  const AuthProfileIncomplete({this.email, this.displayName});

  /// Email del usuario de Google (puede usarse para pre-rellenar campos).
  final String? email;

  /// Nombre mostrado por Google (puede usarse para pre-rellenar campos).
  final String? displayName;

  @override
  List<Object?> get props => [email, displayName];
}

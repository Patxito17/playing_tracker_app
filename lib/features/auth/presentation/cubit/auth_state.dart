import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';

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

/// Estado que representa a un usuario autenticado, junto a su rol.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.role, required this.userId});

  /// Rol del usuario (teacher o student).
  final UserRole role;

  /// Identificador del usuario en Firebase Auth.
  final String userId;

  @override
  List<Object?> get props => [role, userId];
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

import 'package:equatable/equatable.dart';

/// Estados para el flujo de recuperación de contraseña.
sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial sin interacción del usuario.
final class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

/// Estado mientras se envía el correo de recuperación.
final class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

/// Estado cuando el correo de recuperación se envió exitosamente.
final class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Estado cuando ocurre un error al enviar el correo de recuperación.
final class ForgotPasswordError extends ForgotPasswordState {
  const ForgotPasswordError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

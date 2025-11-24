import 'package:equatable/equatable.dart';

/// Estados posibles para operaciones de membresías (alumnos).
sealed class MembershipState extends Equatable {
  const MembershipState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial sin operaciones ejecutadas.
final class MembershipInitial extends MembershipState {
  const MembershipInitial();
}

/// Estado de carga mientras se ejecuta una operación.
final class MembershipLoading extends MembershipState {
  const MembershipLoading();
}

/// Estado que representa ausencia de resultados u operaciones pendientes.
final class MembershipEmpty extends MembershipState {
  const MembershipEmpty({this.message = 'Sin operaciones pendientes'});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Estado de éxito que comunica la acción realizada.
final class MembershipSuccess extends MembershipState {
  const MembershipSuccess({required this.action, this.message});

  final MembershipAction action;
  final String? message;

  @override
  List<Object?> get props => [action, message];
}

/// Estado de error con mensajes legibles para la UI.
final class MembershipError extends MembershipState {
  const MembershipError({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

/// Acciones soportadas por [MembershipCubit].
enum MembershipAction {
  invitedStudent,
  joinedClass,
  removedStudent,
  regeneratedAccessCode,
}

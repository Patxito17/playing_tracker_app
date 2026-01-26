import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';

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
  const MembershipEmpty({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Estado de carga específico para la lista de miembros.
final class MembershipListLoading extends MembershipState {
  const MembershipListLoading({this.isRefresh = false});

  final bool isRefresh;

  @override
  List<Object?> get props => [isRefresh];
}

/// Estado exitoso con los alumnos cargados.
final class MembershipListSuccess extends MembershipState {
  const MembershipListSuccess({
    required this.members,
    required this.hasMore,
    this.lastDocumentId,
    this.isPaginating = false,
  });

  final List<MembershipModel> members;
  final bool hasMore;
  final String? lastDocumentId;
  final bool isPaginating;

  @override
  List<Object?> get props => [members, hasMore, lastDocumentId, isPaginating];
}

/// Estado de error para cargas de miembros.
final class MembershipListError extends MembershipState {
  const MembershipListError({this.message, this.cause});

  final String? message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
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
  const MembershipError({this.message, this.cause});

  final String? message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

/// Acciones soportadas por [MembershipCubit].
enum MembershipAction {
  invitedStudent,
  joinedClass,
  activatedStudent,
  deactivatedStudent,
  deletedStudent,
  regeneratedAccessCode,
}

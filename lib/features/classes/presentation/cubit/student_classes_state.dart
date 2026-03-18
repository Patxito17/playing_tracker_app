import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';

/// Estados posibles del [StudentClassesCubit] para la vista de alumno.
///
/// El flujo normal es: [StudentClassesInitial] → [StudentClassesLoading] →
/// [StudentClassesSuccess] / [StudentClassesEmpty] / [StudentClassesError].
sealed class StudentClassesState extends Equatable {
  const StudentClassesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de comenzar a observar las clases del alumno.
final class StudentClassesInitial extends StudentClassesState {
  const StudentClassesInitial();
}

/// Estado de carga mientras se obtienen las membresías del alumno.
final class StudentClassesLoading extends StudentClassesState {
  const StudentClassesLoading();
}

/// Estado que indica que el alumno no pertenece a ninguna clase activa.
final class StudentClassesEmpty extends StudentClassesState {
  const StudentClassesEmpty({this.message});

  /// Mensaje opcional para la UI (el texto final proviene de l10n).
  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Estado exitoso con la lista de membresías activas del alumno.
final class StudentClassesSuccess extends StudentClassesState {
  const StudentClassesSuccess({required this.memberships});

  /// Lista inmutable de membresías activas del alumno, ya filtradas
  /// para excluir clases eliminadas o desactivadas.
  final List<MembershipModel> memberships;

  @override
  List<Object?> get props => [memberships];
}

/// Estado de error al obtener o procesar las membresías del alumno.
final class StudentClassesError extends StudentClassesState {
  const StudentClassesError({this.message, this.cause});

  /// Mensaje legible para la UI. Null cuando no se tiene contexto adicional.
  final String? message;

  /// Excepción original que provocó el error (para logging).
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

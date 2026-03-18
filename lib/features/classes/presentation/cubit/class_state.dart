import 'package:equatable/equatable.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';

/// Estados posibles del [ClassCubit].
sealed class ClassState extends Equatable {
  const ClassState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial sin información cargada.
final class ClassInitial extends ClassState {
  const ClassInitial();
}

/// Estado utilizado cuando se ejecutan operaciones de red o base de datos.
final class ClassLoading extends ClassState {
  const ClassLoading();
}

/// Estado que representa ausencia de clases disponibles.
final class ClassEmpty extends ClassState {
  const ClassEmpty({this.message}); // El mensaje vendrá de l10n en la UI

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Estado exitoso con la lista de clases disponibles.
final class ClassSuccess extends ClassState {
  const ClassSuccess({
    required this.classes,
    this.source = ClassStateSource.stream,
  });

  /// Lista inmutable de clases del docente.
  final List<ClassModel> classes;

  /// Indica si los datos provienen de una actualización del stream o de un refresco manual.
  final ClassStateSource source;

  @override
  List<Object?> get props => [classes, source];
}

/// Estado de éxito para operaciones puntuales (crear/actualizar/etc.).
final class ClassActionSuccess extends ClassState {
  const ClassActionSuccess({required this.action, this.message});

  /// Tipo de acción que se completó exitosamente.
  final ClassAction action;

  /// Mensaje opcional de confirmación para la UI.
  final String? message;

  @override
  List<Object?> get props => [action, message];
}

/// Estado que encapsula errores de negocio o de infraestructura.
final class ClassError extends ClassState {
  const ClassError({this.message, this.cause, this.errorType});

  /// Mensaje legible para la UI. Null cuando se usa [errorType] en su lugar.
  final String? message;

  /// Excepción original que provocó el error (para logging).
  final Object? cause;

  /// Tipo de error estructurado para que la UI pueda personalizar el mensaje.
  final ClassErrorType? errorType;

  @override
  List<Object?> get props => [message, cause, errorType];
}

/// Origen de los datos renderizados por [ClassCubit].
enum ClassStateSource { stream, manualRefresh }

/// Acciones que pueden reflejarse como éxito puntual.
enum ClassAction { created, statusUpdated }

/// Tipos de error específicos para ClassCubit.
enum ClassErrorType { createFailed, updateFailed, loadFailed, refreshNoTeacher }

import 'package:equatable/equatable.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
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
  const ClassEmpty({this.message = ClassesStrings.noClassesCreated});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Estado exitoso con la lista de clases disponibles.
final class ClassSuccess extends ClassState {
  const ClassSuccess({
    required this.classes,
    this.source = ClassStateSource.stream,
  });

  final List<ClassModel> classes;
  final ClassStateSource source;

  @override
  List<Object?> get props => [classes, source];
}

/// Estado de éxito para operaciones puntuales (crear/actualizar/etc.).
final class ClassActionSuccess extends ClassState {
  const ClassActionSuccess({required this.action, this.message});

  final ClassAction action;
  final String? message;

  @override
  List<Object?> get props => [action, message];
}

/// Estado que encapsula errores de negocio o de infraestructura.
final class ClassError extends ClassState {
  const ClassError({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

/// Origen de los datos renderizados por [ClassCubit].
enum ClassStateSource { stream, manualRefresh }

/// Acciones que pueden reflejarse como éxito puntual.
enum ClassAction { created, statusUpdated }

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/create_class_input.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_state.dart';

/// Cubit encargado de gestionar la lógica de clases para docentes.
///
class ClassCubit extends Cubit<ClassState> {
  ClassCubit(this._repository) : super(const ClassInitial());

  final ClassRepository _repository;
  StreamSubscription<List<ClassModel>>? _classesSubscription;
  String? _currentTeacherId;
  int _currentLimit = _defaultPaginationLimit;
  bool _manualRefreshPending = false;

  /// Crea una nueva clase y delega la persistencia al repositorio.
  Future<void> createClass(CreateClassInput input) async {
    emit(const ClassLoading());
    try {
      await _repository.createClass(input);
      emit(
        const ClassActionSuccess(
          action: ClassAction.created,
          message: ClassesStrings.classCreateSuccess,
        ),
      );
    } on ClassRepositoryException catch (error) {
      emit(ClassError(message: error.message, cause: error));
    } catch (error) {
      emit(
        ClassError(
          message: 'No fue posible crear la clase. Intenta nuevamente.',
          cause: error,
        ),
      );
    }
  }

  /// Observa en tiempo real las clases del docente autenticado.
  Future<void> watchClasses({
    required String teacherId,
    int limit = _defaultPaginationLimit,
  }) async {
    _currentTeacherId = teacherId;
    _currentLimit = limit;
    emit(const ClassLoading());
    await _classesSubscription?.cancel();

    _classesSubscription = _repository
        .watchTeacherClasses(teacherId: teacherId, limit: limit)
        .listen(
          (classes) {
            final source = _manualRefreshPending
                ? ClassStateSource.manualRefresh
                : ClassStateSource.stream;
            _manualRefreshPending = false;
            if (classes.isEmpty) {
              emit(ClassEmpty(message: ClassesStrings.noClassesCreated));
              return;
            }
            emit(
              ClassSuccess(classes: List.unmodifiable(classes), source: source),
            );
          },
          onError: (error, stackTrace) {
            addError(error, stackTrace);
            if (error is ClassRepositoryException) {
              emit(ClassError(message: error.message, cause: error));
              return;
            }
            emit(
              ClassError(
                message: 'Ocurrió un error al cargar tus clases.',
                cause: error,
              ),
            );
          },
        );
  }

  /// Vuelve a suscribirse al stream utilizando los últimos parámetros.
  Future<void> refreshClasses() async {
    final teacherId = _currentTeacherId;
    if (teacherId == null) {
      emit(
        const ClassError(
          message:
              'No se ha configurado un docente para actualizar las clases.',
        ),
      );
      return;
    }
    _manualRefreshPending = true;
    await watchClasses(teacherId: teacherId, limit: _currentLimit);
  }

  /// Cambia el estado activo/archivado de una clase específica.
  Future<void> updateClassStatus({
    required String classId,
    required bool isActive,
  }) async {
    emit(const ClassLoading());
    try {
      await _repository.updateClassStatus(classId: classId, isActive: isActive);
      emit(
        ClassActionSuccess(
          action: ClassAction.statusUpdated,
          message: ClassesStrings.classStatusUpdatedSuccess,
        ),
      );
    } on ClassRepositoryException catch (error) {
      emit(ClassError(message: error.message, cause: error));
    } catch (error) {
      emit(
        ClassError(
          message: 'No fue posible actualizar la clase.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _classesSubscription?.cancel();
    return super.close();
  }
}

const _defaultPaginationLimit = 20;

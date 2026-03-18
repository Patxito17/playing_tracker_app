import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/create_class_input.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_state.dart';

/// Cubit encargado de gestionar la lógica de clases para docentes.
///
/// Expone operaciones de creación, actualización de estado y observación
/// reactiva de la lista de clases. Utiliza un stream de Firestore para
/// mantener la UI sincronizada en tiempo real.
class ClassCubit extends Cubit<ClassState> {
  ClassCubit(this._repository) : super(const ClassInitial());

  final ClassRepository _repository;

  /// Suscripción activa al stream de clases del docente.
  StreamSubscription<List<ClassModel>>? _classesSubscription;

  /// ID del docente cuyas clases se están observando.
  String? _currentTeacherId;

  /// Límite de paginación activo (número máximo de clases a observar).
  int _currentLimit = _defaultPaginationLimit;

  /// Indica que el próximo evento del stream proviene de un refresco manual.
  /// Se usa para distinguir la fuente en [ClassStateSource].
  bool _manualRefreshPending = false;

  /// Crea una nueva clase y delega la persistencia al repositorio.
  Future<void> createClass(CreateClassInput input) async {
    emit(const ClassLoading());
    try {
      await _repository.createClass(input);
      emit(
        const ClassActionSuccess(action: ClassAction.created, message: null),
      );
    } on ClassRepositoryException catch (error) {
      emit(ClassError(message: error.message, cause: error));
    } catch (error) {
      emit(ClassError(errorType: ClassErrorType.createFailed, cause: error));
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
              emit(const ClassEmpty(message: null));
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
              ClassError(errorType: ClassErrorType.loadFailed, cause: error),
            );
          },
        );
  }

  /// Vuelve a suscribirse al stream utilizando los últimos parámetros.
  Future<void> refreshClasses() async {
    final teacherId = _currentTeacherId;
    if (teacherId == null) {
      emit(ClassError(errorType: ClassErrorType.refreshNoTeacher));
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
        ClassActionSuccess(action: ClassAction.statusUpdated, message: null),
      );
    } on ClassRepositoryException catch (error) {
      emit(ClassError(message: error.message, cause: error));
    } catch (error) {
      emit(ClassError(errorType: ClassErrorType.updateFailed, cause: error));
    }
  }

  /// Cancela la suscripción al stream de clases antes de cerrar el cubit.
  @override
  Future<void> close() async {
    await _classesSubscription?.cancel();
    return super.close();
  }
}

const _defaultPaginationLimit = 20;

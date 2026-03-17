import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';

import 'student_classes_state.dart';

/// Cubit responsable de observar y gestionar las clases activas de un alumno.
///
/// Suscribe un stream de [MembershipModel] desde [ClassRepository] y filtra
/// automáticamente las membresías de clases eliminadas o desactivadas.
/// Adicionalmente mantiene watchers individuales por clase para detectar
/// cambios en tiempo real (p.ej. si la clase es archivada o borrada).
///
/// Ciclo de vida:
/// 1. [watchStudentClasses] inicia la suscripción al stream de membresías.
/// 2. Al recibir un nuevo lote, [_processMemberships] filtra y sincroniza.
/// 3. [close] cancela todas las suscripciones activas para evitar memory leaks.
final class StudentClassesCubit extends Cubit<StudentClassesState> {
  StudentClassesCubit(this._repository) : super(const StudentClassesInitial());

  final ClassRepository _repository;
  StreamSubscription<List<MembershipModel>>? _subscription;

  /// Watchers individuales por clase para detectar eliminaciones en tiempo real.
  final Map<String, StreamSubscription<ClassModel?>> _classWatchers = {};
  List<MembershipModel> _visibleMemberships = [];
  String? _currentStudentId;

  /// Caché local de clases ya resueltas para evitar llamadas Firestore redundantes
  /// cada vez que el stream de membresías emite.
  final Map<String, ClassModel> _classCache = {};

  /// Inicia o reinicia la observación de membresías para el alumno dado.
  ///
  /// Cancela cualquier suscripción previa antes de crear una nueva.
  Future<void> watchStudentClasses({required String studentId}) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      emit(
        const StudentClassesError(
          message: 'El identificador del estudiante es inválido.',
        ),
      );
      return;
    }

    // Limpiar la caché al cambiar de usuario para no servir datos de otro alumno.
    if (_currentStudentId != sanitizedId) {
      _classCache.clear();
    }
    _currentStudentId = sanitizedId;
    emit(const StudentClassesLoading());
    await _subscription?.cancel();
    _subscription = _repository
        .watchStudentMemberships(studentId: sanitizedId)
        .listen(_handleMemberships, onError: _handleError);
  }

  /// Fuerza una recarga de las clases del alumno actual.
  Future<void> refresh() async {
    final studentId = _currentStudentId;
    if (studentId == null) {
      emit(const StudentClassesInitial());
      return;
    }
    await watchStudentClasses(studentId: studentId);
  }

  void _handleMemberships(List<MembershipModel> memberships) {
    unawaited(_processMemberships(memberships));
  }

  Future<void> _processMemberships(List<MembershipModel> memberships) async {
    try {
      if (memberships.isEmpty) {
        _visibleMemberships = [];
        await _disposeClassWatchers();
        emit(const StudentClassesEmpty(message: null));
        return;
      }
      final filtered = await _filterMemberships(memberships);
      await _syncClassWatchers(filtered);
      _emitMemberships(filtered);
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  Future<List<MembershipModel>> _filterMemberships(
    List<MembershipModel> memberships,
  ) async {
    final results = await Future.wait(
      memberships.map((membership) async {
        if (!membership.classIsActive) {
          return (membership: membership, isValid: false);
        }
        // Usar la caché para evitar lecturas Firestore duplicadas en cada
        // emisión del stream cuando la clase ya fue resuelto previamente.
        ClassModel? classModel = _classCache[membership.classId];
        if (classModel == null) {
          classModel = await _repository.getClassById(membership.classId);
          if (classModel != null) {
            _classCache[membership.classId] = classModel;
          }
        }
        return (membership: membership, isValid: classModel != null);
      }),
    );
    return [
      for (final entry in results)
        if (entry.isValid) entry.membership,
    ];
  }

  void _emitMemberships(List<MembershipModel> memberships) {
    _visibleMemberships = memberships;
    if (memberships.isEmpty) {
      emit(const StudentClassesEmpty(message: null));
      return;
    }
    emit(
      StudentClassesSuccess(
        memberships: List<MembershipModel>.unmodifiable(memberships),
      ),
    );
  }

  Future<void> _syncClassWatchers(List<MembershipModel> memberships) async {
    final targetClassIds = memberships.map((m) => m.classId).toSet();
    final toRemove = _classWatchers.keys
        .where((classId) => !targetClassIds.contains(classId))
        .toList();
    for (final classId in toRemove) {
      await _classWatchers.remove(classId)?.cancel();
    }
    for (final membership in memberships) {
      final classId = membership.classId;
      if (_classWatchers.containsKey(classId)) {
        continue;
      }
      _classWatchers[classId] = _repository
          .watchClassById(classId)
          .listen(
            (classModel) => _handleClassSnapshot(classId, classModel),
            onError: (_) => _handleClassSnapshot(classId, null),
          );
    }
  }

  void _handleClassSnapshot(String classId, ClassModel? classModel) {
    if (classModel == null) {
      final updated = _visibleMemberships
          .where((membership) => membership.classId != classId)
          .toList();
      _classWatchers.remove(classId)?.cancel();
      _emitMemberships(updated);
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    final message = error is ClassRepositoryException ? error.message : null;
    emit(StudentClassesError(message: message, cause: error));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _disposeClassWatchers();
    _classCache.clear();
    return super.close();
  }

  Future<void> _disposeClassWatchers() async {
    for (final subscription in _classWatchers.values) {
      await subscription.cancel();
    }
    _classWatchers.clear();
  }
}

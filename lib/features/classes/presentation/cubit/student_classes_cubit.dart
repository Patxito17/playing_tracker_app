import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';

import 'student_classes_state.dart';

final class StudentClassesCubit extends Cubit<StudentClassesState> {
  StudentClassesCubit(this._repository) : super(const StudentClassesInitial());

  final ClassRepository _repository;
  StreamSubscription<List<MembershipModel>>? _subscription;
  final Map<String, StreamSubscription<ClassModel?>> _classWatchers = {};
  List<MembershipModel> _visibleMemberships = [];
  String? _currentStudentId;

  Future<void> watchStudentClasses({required String studentId}) async {
    final sanitizedId = studentId.trim();
    if (sanitizedId.isEmpty) {
      emit(
        const StudentClassesError(message: ClassesStrings.classGenericError),
      );
      return;
    }

    _currentStudentId = sanitizedId;
    emit(const StudentClassesLoading());
    await _subscription?.cancel();
    _subscription = _repository
        .watchStudentMemberships(studentId: sanitizedId)
        .listen(_handleMemberships, onError: _handleError);
  }

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
        emit(const StudentClassesEmpty());
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
        final classModel = await _repository.getClassById(membership.classId);
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
      emit(const StudentClassesEmpty());
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
    final message = error is ClassRepositoryException
        ? error.message
        : ClassesStrings.classGenericError;
    emit(StudentClassesError(message: message, cause: error));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _disposeClassWatchers();
    return super.close();
  }

  Future<void> _disposeClassWatchers() async {
    for (final subscription in _classWatchers.values) {
      await subscription.cancel();
    }
    _classWatchers.clear();
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';

import 'student_classes_state.dart';

final class StudentClassesCubit extends Cubit<StudentClassesState> {
  StudentClassesCubit(this._repository) : super(const StudentClassesInitial());

  final ClassRepository _repository;
  StreamSubscription<List<MembershipModel>>? _subscription;
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

  void _handleError(Object error, StackTrace stackTrace) {
    final message = error is ClassRepositoryException
        ? error.message
        : ClassesStrings.classGenericError;
    emit(StudentClassesError(message: message, cause: error));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

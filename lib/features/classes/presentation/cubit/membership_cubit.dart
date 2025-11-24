import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_state.dart';

/// Cubit encargado de las operaciones de membresías (alumnos en clases).
final class MembershipCubit extends Cubit<MembershipState> {
  MembershipCubit(this._repository) : super(const MembershipInitial());

  final ClassRepository _repository;

  /// Invita o agrega manualmente un alumno a una clase específica.
  Future<void> inviteStudent(InviteStudentInput input) async {
    emit(const MembershipLoading());
    try {
      await _repository.inviteStudent(input);
      emit(
        const MembershipSuccess(
          action: MembershipAction.invitedStudent,
          message: ClassesStrings.membershipInviteSuccess,
        ),
      );
    } on ClassRepositoryException catch (error) {
      emit(MembershipError(message: error.message, cause: error));
    } catch (error) {
      emit(
        const MembershipError(message: ClassesStrings.membershipGenericError),
      );
    }
  }

  /// Permite que un alumno se una con código de acceso.
  Future<void> joinClass(JoinClassInput input) async {
    emit(const MembershipLoading());
    try {
      await _repository.joinClassWithCode(input);
      emit(
        const MembershipSuccess(
          action: MembershipAction.joinedClass,
          message: ClassesStrings.membershipJoinSuccess,
        ),
      );
    } on ClassRepositoryException catch (error) {
      emit(MembershipError(message: error.message, cause: error));
    } catch (error) {
      emit(
        const MembershipError(message: ClassesStrings.membershipGenericError),
      );
    }
  }

  /// Marca la membresía como inactiva (expulsar alumno).
  Future<void> removeStudent({
    required String classId,
    required String studentId,
  }) async {
    emit(const MembershipLoading());
    try {
      await _repository.removeStudentFromClass(
        classId: classId,
        studentId: studentId,
      );
      emit(
        const MembershipSuccess(
          action: MembershipAction.removedStudent,
          message: ClassesStrings.membershipRemoveSuccess,
        ),
      );
    } on ClassRepositoryException catch (error) {
      emit(MembershipError(message: error.message, cause: error));
    } catch (error) {
      emit(
        const MembershipError(message: ClassesStrings.membershipGenericError),
      );
    }
  }

  /// Regenera el código de acceso para la clase indicada.
  Future<void> regenerateAccessCode(String classId) async {
    emit(const MembershipLoading());
    try {
      await _repository.regenerateAccessCode(classId);
      emit(
        const MembershipSuccess(
          action: MembershipAction.regeneratedAccessCode,
          message: ClassesStrings.membershipRegenerateSuccess,
        ),
      );
    } on ClassRepositoryException catch (error) {
      emit(MembershipError(message: error.message, cause: error));
    } catch (error) {
      emit(
        const MembershipError(message: ClassesStrings.membershipGenericError),
      );
    }
  }

  /// Restablece el estado al punto inicial.
  void reset() => emit(const MembershipEmpty());
}

import 'package:equatable/equatable.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';

sealed class StudentClassesState extends Equatable {
  const StudentClassesState();

  @override
  List<Object?> get props => [];
}

final class StudentClassesInitial extends StudentClassesState {
  const StudentClassesInitial();
}

final class StudentClassesLoading extends StudentClassesState {
  const StudentClassesLoading();
}

final class StudentClassesEmpty extends StudentClassesState {
  const StudentClassesEmpty({this.message = ClassesStrings.noClassesJoined});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class StudentClassesSuccess extends StudentClassesState {
  const StudentClassesSuccess({required this.memberships});

  final List<MembershipModel> memberships;

  @override
  List<Object?> get props => [memberships];
}

final class StudentClassesError extends StudentClassesState {
  const StudentClassesError({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

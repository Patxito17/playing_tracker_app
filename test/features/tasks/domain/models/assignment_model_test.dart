import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';

void main() {
  group('AssignmentModel', () {
    final baseAssignment = AssignmentModel(
      id: 'id',
      taskId: 'taskId',
      studentId: 'studentId',
      classId: 'classId',
      teacherId: 'teacherId',
      status: TaskStatus.pending,
      assignedAt: Timestamp.now(),
    );

    group('daysRemaining', () {
      test('returns null when dueDate is null', () {
        final assignment = baseAssignment.copyWith(dueDate: null);
        expect(assignment.daysRemaining, isNull);
      });

      test('returns positive days when due date is in future', () {
        final futureDate = DateTime.now().add(
          const Duration(days: 5, hours: 1),
        );
        final assignment = baseAssignment.copyWith(
          dueDate: Timestamp.fromDate(futureDate),
        );
        // daysRemaining check difference in days.
        // Note: DateTime.now() difference might vary slightly,
        // but typically 5 days + hours suggests 5 days remaining.
        expect(assignment.daysRemaining, 5);
      });

      test('returns negative days when due date is in past', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 3));
        final assignment = baseAssignment.copyWith(
          dueDate: Timestamp.fromDate(pastDate),
        );
        expect(assignment.daysRemaining, -3);
      });

      test('returns 0 when due date is today (less than 24h)', () {
        // Using a point in time slightly ahead to ensure it's "today" future or same day
        final todayFuture = DateTime.now().add(const Duration(hours: 2));
        final assignment = baseAssignment.copyWith(
          dueDate: Timestamp.fromDate(todayFuture),
        );
        expect(assignment.daysRemaining, 0);
      });
    });

    group('studyTimeRemaining', () {
      test('returns full suggested duration when totalDurationLogged is 0', () {
        final assignment = baseAssignment.copyWith(
          durationSuggested: 3600,
          totalDurationLogged: 0,
        );
        expect(assignment.studyTimeRemaining, 3600);
      });

      test('returns remaining time correctly', () {
        final assignment = baseAssignment.copyWith(
          durationSuggested: 3600,
          totalDurationLogged: 1200,
        );
        expect(assignment.studyTimeRemaining, 2400);
      });

      test('returns negative value when logged time > suggested', () {
        final assignment = baseAssignment.copyWith(
          durationSuggested: 3600,
          totalDurationLogged: 4000,
        );
        expect(assignment.studyTimeRemaining, -400);
      });

      test('returns 0 when suggested is null (defaulted to 0)', () {
        final assignment = baseAssignment.copyWith(
          durationSuggested: null,
          totalDurationLogged: 100,
        );
        // If suggested is null -> 0. 0 - 100 = -100
        expect(assignment.studyTimeRemaining, -100);
      });
    });

    group('hasExtraStudyTime', () {
      test('returns true when studyTimeRemaining is negative', () {
        final assignment = baseAssignment.copyWith(
          durationSuggested: 100,
          totalDurationLogged: 200,
        );
        expect(assignment.hasExtraStudyTime, isTrue);
      });

      test('returns false when studyTimeRemaining is positive', () {
        final assignment = baseAssignment.copyWith(
          durationSuggested: 200,
          totalDurationLogged: 100,
        );
        expect(assignment.hasExtraStudyTime, isFalse);
      });

      test('returns false when studyTimeRemaining is zero', () {
        final assignment = baseAssignment.copyWith(
          durationSuggested: 100,
          totalDurationLogged: 100,
        );
        expect(assignment.hasExtraStudyTime, isFalse);
      });
    });
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/features/auth/domain/models/student_model.dart';
import 'package:playing_tracker/features/auth/domain/models/teacher_model.dart';

/// Crea una instancia mock de [TeacherModel] para tests.
TeacherModel createMockTeacher({
  String id = 'teacher-1',
  String firstName = 'Juan',
  String lastName = 'Pérez',
  String email = 'juan@teacher.com',
}) {
  final now = Timestamp.now();
  return TeacherModel(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    createdAt: now,
    updatedAt: now,
    isActive: true,
  );
}

/// Crea una instancia mock de [StudentModel] para tests.
StudentModel createMockStudent({
  String id = 'student-1',
  String firstName = 'Ana',
  String lastName = 'Lopez',
  String email = 'ana@student.com',
}) {
  final now = Timestamp.now();
  return StudentModel(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    createdAt: now,
    updatedAt: now,
    isActive: true,
    totalSessionsCount: 0,
    totalDurationLogged: 0,
    lastSessionDate: null,
  );
}

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';

/// Contrato para operaciones relacionadas con memberships.
abstract interface class MembershipServiceContract {
  Future<void> inviteStudent(InviteStudentInput input);

  Future<void> joinClassWithCode(JoinClassInput input);

  Future<void> removeStudent(String membershipId);

  Future<List<MembershipModel>> listClassMembers(String classId);

  Future<List<String>> getStudentsForClass(String classId);
}

/// Servicio responsable de gestionar la relación N:M entre clases y alumnos.
final class MembershipService implements MembershipServiceContract {
  /// Crea una instancia con dependencias inyectables para pruebas.
  MembershipService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _classesCollection =>
      _firestore.collection(_classesCollectionName);

  CollectionReference<Map<String, dynamic>> get _membershipsCollection =>
      _firestore.collection(_membershipsCollectionName);

  /// Invita o agrega manualmente un alumno a la clase indicada.
  @override
  Future<void> inviteStudent(InviteStudentInput input) async {
    validateInviteStudentInput(input);
    try {
      await _createOrReactivateMembership(
        classId: input.classId,
        studentId: input.studentId,
        teacherId: input.teacherId,
        className: input.className,
      );
    } on FirebaseException catch (error, stackTrace) {
      log(
        'MembershipService#inviteStudent FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Permite que un alumno se una mediante un código de acceso válido.
  @override
  Future<void> joinClassWithCode(JoinClassInput input) async {
    validateJoinClassInput(input);
    final normalizedCode = input.accessCode.trim().toUpperCase();
    try {
      final classSnapshot = await _classesCollection
          .where('accessCode', isEqualTo: normalizedCode)
          .limit(1)
          .get();
      if (classSnapshot.docs.isEmpty) {
        throw FirebaseErrorMapperException(
          'El código de acceso proporcionado no es válido.',
        );
      }

      final classModel = _mapClassSnapshot(classSnapshot.docs.first);
      if (!classModel.canJoin) {
        throw FirebaseErrorMapperException(
          'La clase se encuentra archivada o no admite más alumnos.',
        );
      }

      await _createOrReactivateMembership(
        classId: classModel.id,
        studentId: input.studentId,
        teacherId: classModel.ownerTeacherId,
        className: classModel.name,
      );
    } on FirebaseErrorMapperException catch (error) {
      log(
        'MembershipService#joinClassWithCode ValidationException',
        error: error,
      );
      rethrow;
    } on FirebaseException catch (error, stackTrace) {
      log(
        'MembershipService#joinClassWithCode FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Marca una membresía como inactiva (soft delete).
  @override
  Future<void> removeStudent(String membershipId) async {
    try {
      await _membershipsCollection.doc(membershipId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error, stackTrace) {
      log(
        'MembershipService#removeStudent FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Lista los alumnos activos de una clase específica.
  @override
  Future<List<MembershipModel>> listClassMembers(String classId) async {
    try {
      final snapshot = await _membershipsCollection
          .where('classId', isEqualTo: classId)
          .where('isActive', isEqualTo: true)
          .orderBy('joinedAt', descending: true)
          .get();
      return snapshot.docs.map(_mapMembershipSnapshot).toList();
    } on FirebaseException catch (error, stackTrace) {
      log(
        'MembershipService#listClassMembers FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Obtiene únicamente los IDs de alumnos para preparar fan-outs.
  @override
  Future<List<String>> getStudentsForClass(String classId) async {
    final memberships = await listClassMembers(classId);
    return memberships.map((membership) => membership.studentId).toList();
  }

  /// Crea o re-activa (en caso de existir) la membresía del alumno.
  Future<void> _createOrReactivateMembership({
    required String classId,
    required String studentId,
    required String teacherId,
    required String className,
  }) async {
    final membershipId = _buildMembershipDocId(classId, studentId);
    final membershipRef = _membershipsCollection.doc(membershipId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(membershipRef);
      if (snapshot.exists) {
        transaction.update(membershipRef, {
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      transaction.set(membershipRef, {
        'id': membershipId,
        'classId': classId,
        'studentId': studentId,
        'teacherId': teacherId,
        'className': className,
        'joinedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    });
  }

  MembershipModel _mapMembershipSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    data['id'] = data['id'] ?? snapshot.id;
    return MembershipModel.fromJson(data);
  }

  ClassModel _mapClassSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    data['id'] = data['id'] ?? snapshot.id;
    return ClassModel.fromJson(data);
  }
}

String _buildMembershipDocId(String classId, String studentId) =>
    '${classId}_$studentId';

const _classesCollectionName = 'classes';
const _membershipsCollectionName = 'memberships';

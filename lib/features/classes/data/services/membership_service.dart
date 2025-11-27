import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/membership_page.dart';

/// Contrato para operaciones relacionadas con memberships.
abstract interface class MembershipServiceContract {
  Future<void> inviteStudent(InviteStudentInput input);

  Future<void> joinClassWithCode(JoinClassInput input);

  Future<void> removeStudent(String membershipId);

  Future<void> updateMembershipStatus({
    required String membershipId,
    required bool isActive,
  });

  Future<void> deleteMembership(String membershipId);

  Future<void> deleteMembershipsByClass(String classId);

  Future<void> updateMembershipsClassStatus({
    required String classId,
    required bool isActive,
  });

  Future<MembershipPage> listClassMembers({
    required String classId,
    int limit,
    String? startAfterId,
    bool includeInactive = false,
  });

  Future<List<String>> getStudentsForClass(String classId);

  Stream<List<MembershipModel>> watchStudentMemberships(String studentId);
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

  CollectionReference<Map<String, dynamic>> get _teachersCollection =>
      _firestore.collection(_teachersCollectionName);

  CollectionReference<Map<String, dynamic>> get _studentsCollection =>
      _firestore.collection(_studentsCollectionName);

  /// Invita o agrega manualmente un alumno a la clase indicada.
  @override
  Future<void> inviteStudent(InviteStudentInput input) async {
    validateInviteStudentInput(input);
    try {
      final teacherMetadata = await _resolveTeacherMetadata(input.teacherId);
      final studentMetadata = await _resolveStudentMetadata(input.studentId);
      await _createOrReactivateMembership(
        classId: input.classId,
        studentId: input.studentId,
        studentName: studentMetadata.name,
        studentEmail: studentMetadata.email,
        teacherId: input.teacherId,
        className: input.className,
        teacherName: teacherMetadata.name,
        teacherEmail: teacherMetadata.email,
        classIsActive: true,
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

      final teacherMetadata = await _resolveTeacherMetadata(
        classModel.ownerTeacherId,
      );
      final studentMetadata = await _resolveStudentMetadata(input.studentId);
      await _createOrReactivateMembership(
        classId: classModel.id,
        studentId: input.studentId,
        studentName: studentMetadata.name,
        studentEmail: studentMetadata.email,
        teacherId: classModel.ownerTeacherId,
        className: classModel.name,
        teacherName: teacherMetadata.name,
        teacherEmail: teacherMetadata.email,
        classIsActive: true,
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

  @override
  Future<void> updateMembershipStatus({
    required String membershipId,
    required bool isActive,
  }) async {
    try {
      await _membershipsCollection.doc(membershipId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error, stackTrace) {
      log(
        'MembershipService#updateMembershipStatus FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> deleteMembership(String membershipId) async {
    try {
      await _membershipsCollection.doc(membershipId).delete();
    } on FirebaseException catch (error, stackTrace) {
      log(
        'MembershipService#deleteMembership FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> deleteMembershipsByClass(String classId) async {
    try {
      final snapshot = await _membershipsCollection
          .where('classId', isEqualTo: classId)
          .get();
      if (snapshot.docs.isEmpty) {
        return;
      }
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (error, stackTrace) {
      log(
        'MembershipService#deleteMembershipsByClass FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> updateMembershipsClassStatus({
    required String classId,
    required bool isActive,
  }) async {
    try {
      final snapshot = await _membershipsCollection
          .where('classId', isEqualTo: classId)
          .get();
      if (snapshot.docs.isEmpty) {
        return;
      }
      var batch = _firestore.batch();
      var operations = 0;
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'classIsActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        operations++;
        if (operations == _batchWriteLimit) {
          await batch.commit();
          batch = _firestore.batch();
          operations = 0;
        }
      }
      if (operations > 0) {
        await batch.commit();
      }
    } on FirebaseException catch (error, stackTrace) {
      log(
        'MembershipService#updateMembershipsClassStatus FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Lista los alumnos activos de una clase específica.
  @override
  Future<MembershipPage> listClassMembers({
    required String classId,
    int limit = _defaultPaginationLimit,
    String? startAfterId,
    bool includeInactive = false,
  }) async {
    if (classId.trim().isEmpty) {
      throw ArgumentError('El identificador de la clase es obligatorio');
    }
    if (limit <= 0) {
      throw ArgumentError('El límite de paginación debe ser mayor a cero');
    }
    try {
      Query<Map<String, dynamic>> query = _membershipsCollection.where(
        'classId',
        isEqualTo: classId,
      );

      if (!includeInactive) {
        query = query.where('isActive', isEqualTo: true);
      }

      query = query
          .orderBy('joinedAt', descending: true)
          .orderBy('id', descending: true)
          .limit(limit);

      if (startAfterId != null) {
        final cursorSnapshot = await _membershipsCollection
            .doc(startAfterId)
            .get();
        final cursorData = cursorSnapshot.data();
        final joinedAtValue = cursorData?['joinedAt'];
        final cursorId = cursorData?['id'];
        if (!cursorSnapshot.exists ||
            joinedAtValue == null ||
            cursorId == null) {
          throw FirebaseErrorMapperException(
            'El cursor solicitado ya no es válido. Refresca la lista.',
          );
        }
        query = query.startAfter([joinedAtValue, cursorId]);
      }

      final snapshot = await query.get();
      final members = snapshot.docs.map(_mapMembershipSnapshot).toList();
      final lastDocumentId = snapshot.docs.isEmpty
          ? null
          : snapshot.docs.last.id;

      return (members: members, lastDocumentId: lastDocumentId);
    } on FirebaseErrorMapperException {
      rethrow;
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
  ///
  /// TODO(Sprint4): Optimizar para fan-outs masivos usando lotes paralelos.
  @override
  Future<List<String>> getStudentsForClass(String classId) async {
    final students = <String>[];
    String? cursor;
    while (true) {
      final page = await listClassMembers(
        classId: classId,
        limit: _fanOutPaginationLimit,
        startAfterId: cursor,
      );
      students.addAll(page.members.map((membership) => membership.studentId));
      final reachedEnd =
          page.lastDocumentId == null ||
          page.members.length < _fanOutPaginationLimit;
      if (reachedEnd) {
        return students;
      }
      cursor = page.lastDocumentId;
      // TODO(Sprint4): Considerar cortes de seguridad para evitar loops infinitos
      // una vez que se implemente fan-out real.
    }
  }

  @override
  Stream<List<MembershipModel>> watchStudentMemberships(String studentId) {
    final normalizedId = studentId.trim();
    if (normalizedId.isEmpty) {
      return Stream<List<MembershipModel>>.error(
        ArgumentError('El identificador del alumno es obligatorio'),
      );
    }

    final snapshots = _membershipsCollection
        .where('studentId', isEqualTo: normalizedId)
        .where('isActive', isEqualTo: true)
        .orderBy('joinedAt', descending: true)
        .snapshots();

    return snapshots.transform(
      StreamTransformer.fromHandlers(
        handleData: (snapshot, sink) {
          final memberships = snapshot.docs
              .map(_mapMembershipSnapshot)
              .where((membership) => membership.classIsActive)
              .toList();
          sink.add(memberships);
        },
        handleError: (error, stackTrace, sink) {
          if (error is FirebaseException) {
            sink.addError(
              FirebaseErrorMapperException(FirebaseErrorMapper.map(error)),
            );
            return;
          }
          sink.addError(error);
        },
      ),
    );
  }

  /// Crea o re-activa (en caso de existir) la membresía del alumno.
  Future<void> _createOrReactivateMembership({
    required String classId,
    required String studentId,
    String? studentName,
    String? studentEmail,
    required String teacherId,
    required String className,
    String? teacherName,
    String? teacherEmail,
    bool classIsActive = true,
  }) async {
    final membershipId = _buildMembershipDocId(classId, studentId);
    final membershipRef = _membershipsCollection.doc(membershipId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(membershipRef);
      if (snapshot.exists) {
        final updateData = <String, dynamic>{
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
          'classIsActive': classIsActive,
        };
        if (studentName != null) {
          updateData['studentName'] = studentName;
        }
        if (studentEmail != null) {
          updateData['studentEmail'] = studentEmail;
        }
        if (teacherName != null) {
          updateData['teacherName'] = teacherName;
        }
        if (teacherEmail != null) {
          updateData['teacherEmail'] = teacherEmail;
        }
        transaction.update(membershipRef, updateData);
        return;
      }

      transaction.set(membershipRef, {
        'id': membershipId,
        'classId': classId,
        'studentId': studentId,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'teacherEmail': teacherEmail,
        'className': className,
        'classIsActive': classIsActive,
        'joinedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    });
  }

  Future<({String? name, String? email})> _resolveTeacherMetadata(
    String teacherId,
  ) async {
    final normalizedId = teacherId.trim();
    if (normalizedId.isEmpty) {
      return (name: null, email: null);
    }
    try {
      final snapshot = await _teachersCollection.doc(normalizedId).get();
      if (!snapshot.exists) {
        return (name: null, email: null);
      }
      final data = snapshot.data();
      final firstName = (data?['firstName'] as String?)?.trim() ?? '';
      final lastName = (data?['lastName'] as String?)?.trim() ?? '';
      final rawEmail = (data?['email'] as String?)?.trim();
      final fullName = '$firstName $lastName'.trim();
      return (
        name: fullName.isEmpty ? null : fullName,
        email: rawEmail != null && rawEmail.isNotEmpty ? rawEmail : null,
      );
    } catch (error, stackTrace) {
      log(
        'MembershipService#resolveTeacherMetadata error',
        error: error,
        stackTrace: stackTrace,
      );
      return (name: null, email: null);
    }
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

  Future<({String? name, String? email})> _resolveStudentMetadata(
    String studentId,
  ) async {
    final normalizedId = studentId.trim();
    if (normalizedId.isEmpty) {
      return (name: null, email: null);
    }
    try {
      final snapshot = await _studentsCollection.doc(normalizedId).get();
      if (!snapshot.exists) {
        return (name: null, email: null);
      }
      final data = snapshot.data();
      final firstName = (data?['firstName'] as String?)?.trim() ?? '';
      final lastName = (data?['lastName'] as String?)?.trim() ?? '';
      final rawEmail = (data?['email'] as String?)?.trim();
      final fullName = '$firstName $lastName'.trim();
      return (
        name: fullName.isEmpty ? null : fullName,
        email: rawEmail != null && rawEmail.isNotEmpty ? rawEmail : null,
      );
    } catch (error, stackTrace) {
      log(
        'MembershipService#resolveStudentMetadata error',
        error: error,
        stackTrace: stackTrace,
      );
      return (name: null, email: null);
    }
  }
}

String _buildMembershipDocId(String classId, String studentId) =>
    '${classId}_$studentId';

const _classesCollectionName = 'classes';
const _membershipsCollectionName = 'memberships';
const _teachersCollectionName = 'teachers';
const _studentsCollectionName = 'students';
const _defaultPaginationLimit = 20;
const _fanOutPaginationLimit = 200;
const _batchWriteLimit = 400;

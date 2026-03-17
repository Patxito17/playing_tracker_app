import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/core/utils/access_code_generator.dart';
import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/create_class_input.dart';

/// Contrato para permitir testear e intercambiar implementaciones.
abstract interface class ClassServiceContract {
  Future<ClassModel> createClass(CreateClassInput input);

  Stream<List<ClassModel>> watchTeacherClasses({
    required String teacherId,
    int limit,
  });

  Stream<ClassModel?> watchClassById(String classId);

  Future<ClassModel?> getClassById(String classId);

  Future<void> updateClassStatus({
    required String classId,
    required bool isActive,
  });

  Future<void> deleteClass(String classId);

  Future<void> regenerateAccessCode(String classId);
}

/// Servicio dedicado a interactuar con la colección `classes` de Firestore.
///
/// Se encarga de generar códigos de acceso, ejecutar transacciones básicas y
/// entregar modelos tipados al repositorio.
final class ClassService implements ClassServiceContract {
  /// Crea una instancia del servicio con dependencias inyectables para tests.
  ClassService({
    FirebaseFirestore? firestore,
    AccessCodeGenerator? accessCodeGenerator,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _accessCodeGenerator = accessCodeGenerator ?? AccessCodeGenerator();

  final FirebaseFirestore _firestore;
  final AccessCodeGenerator _accessCodeGenerator;

  CollectionReference<Map<String, dynamic>> get _classesCollection =>
      _firestore.collection(_classesCollectionName);

  /// Crea una clase nueva persistiendo los metadatos requeridos.
  @override
  Future<ClassModel> createClass(CreateClassInput input) async {
    validateCreateClassInput(input);
    try {
      final accessCode = await _generateUniqueAccessCode();
      final docRef = _classesCollection.doc();
      final sanitizedDescription = _sanitizeDescription(input.description);
      final payload = <String, dynamic>{
        'id': docRef.id,
        'name': input.name.trim(),
        'description': sanitizedDescription,
        'ownerTeacherId': input.ownerId,
        'accessCode': accessCode,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };
      await docRef.set(payload);
      final snapshot = await docRef.get();
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (error, stackTrace) {
      log(
        'ClassService#createClass FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Lista las clases de un docente en lotes limitados.
  Future<List<ClassModel>> listTeacherClasses({
    required String teacherId,
    int limit = _defaultPaginationLimit,
  }) async {
    try {
      final snapshot = await _classesCollection
          .where('ownerTeacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map(_mapSnapshot).toList();
    } on FirebaseException catch (error, stackTrace) {
      log(
        'ClassService#listTeacherClasses FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Observa en tiempo real las clases del docente autenticado.
  @override
  Stream<List<ClassModel>> watchTeacherClasses({
    required String teacherId,
    int limit = _defaultPaginationLimit,
  }) {
    return _classesCollection
        .where('ownerTeacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapSnapshot).toList());
  }

  @override
  Stream<ClassModel?> watchClassById(String classId) {
    final sanitizedId = classId.trim();
    if (sanitizedId.isEmpty) {
      return Stream<ClassModel?>.error(
        FirebaseErrorMapperException(
          'El identificador de la clase es obligatorio.',
        ),
      );
    }
    return _classesCollection.doc(sanitizedId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return _mapSnapshot(snapshot);
    });
  }

  /// Obtiene una clase por su ID o retorna null si no existe.
  @override
  Future<ClassModel?> getClassById(String classId) async {
    try {
      final snapshot = await _classesCollection.doc(classId).get();
      if (!snapshot.exists) {
        return null;
      }
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (error, stackTrace) {
      log(
        'ClassService#getClassById FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Actualiza el estado `isActive` y la marca de tiempo de la clase.
  @override
  Future<void> updateClassStatus({
    required String classId,
    required bool isActive,
  }) async {
    try {
      await _classesCollection.doc(classId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error, stackTrace) {
      log(
        'ClassService#updateClassStatus FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<void> deleteClass(String classId) async {
    try {
      await _classesCollection.doc(classId).delete();
    } on FirebaseException catch (error, stackTrace) {
      log(
        'ClassService#deleteClass FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Regenera el código de acceso garantizando que no exista duplicado.
  @override
  Future<void> regenerateAccessCode(String classId) async {
    try {
      final newCode = await _generateUniqueAccessCode(ignoreClassId: classId);
      await _classesCollection.doc(classId).update({
        'accessCode': newCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error, stackTrace) {
      log(
        'ClassService#regenerateAccessCode FirebaseException: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FirebaseErrorMapperException(FirebaseErrorMapper.map(error));
    }
  }

  /// Punto de integración con el fan-out de tareas hacia `assignments`.
  ///
  /// La distribución real se delega al [FanOutHelper]; este método actúa
  /// como coordinador dentro del servicio de clases.

  Future<String> _generateUniqueAccessCode({
    String? ignoreClassId,
    int maxRetries = 5,
  }) async {
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      final candidate = _accessCodeGenerator.generate();
      final collisionSnapshot = await _classesCollection
          .where('accessCode', isEqualTo: candidate)
          .limit(1)
          .get();
      final docs = collisionSnapshot.docs;
      final hasCollision =
          docs.isNotEmpty &&
          (ignoreClassId == null || docs.first.id != ignoreClassId);
      if (!hasCollision) {
        return candidate;
      }
    }
    throw DuplicateAccessCodeException(
      'No fue posible generar un código único tras $maxRetries intentos.',
    );
  }

  ClassModel _mapSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw FirebaseErrorMapperException(
        'La clase solicitada no contiene datos.',
      );
    }
    data['id'] = data['id'] ?? snapshot.id;
    final createdAt = data['createdAt'];
    final fallbackTimestamp = Timestamp.now();
    data['createdAt'] = createdAt ?? fallbackTimestamp;
    data['updatedAt'] = data['updatedAt'] ?? createdAt ?? fallbackTimestamp;
    return ClassModel.fromJson(data);
  }

  String? _sanitizeDescription(String? description) {
    if (description == null) {
      return null;
    }
    final trimmed = description.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

const _classesCollectionName = 'classes';
const _defaultPaginationLimit = 20;

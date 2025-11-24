import 'dart:async';
import 'dart:developer';

import 'package:playing_tracker/core/utils/firebase_error_mapper.dart';
import 'package:playing_tracker/features/classes/data/helpers/fan_out_helper.dart';
import 'package:playing_tracker/features/classes/data/services/class_service.dart';
import 'package:playing_tracker/features/classes/data/services/membership_service.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/create_class_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';

/// Implementación concreta del [ClassRepository] que orquesta servicios y
/// helpers de datos respetando la arquitectura Domain → Repository → Service.
final class ClassRepositoryImpl implements ClassRepository {
  ClassRepositoryImpl({
    ClassServiceContract? classService,
    MembershipServiceContract? membershipService,
    FanOutHelperContract? fanOutHelper,
  }) : _classService = classService ?? ClassService(),
       _membershipService = membershipService ?? MembershipService(),
       _fanOutHelper = fanOutHelper ?? FanOutHelper();

  final ClassServiceContract _classService;
  final MembershipServiceContract _membershipService;
  final FanOutHelperContract _fanOutHelper;

  @override
  Future<ClassModel> createClass(CreateClassInput input) async {
    try {
      return await _classService.createClass(input);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'createClass',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible crear la clase.',
      );
    }
  }

  @override
  Stream<List<ClassModel>> watchTeacherClasses({
    required String teacherId,
    int limit = _defaultPaginationLimit,
  }) {
    final sanitizedTeacherId = teacherId.trim();
    if (sanitizedTeacherId.isEmpty) {
      return Stream<List<ClassModel>>.error(
        const InvalidClassRepositoryArgumentException(
          'El identificador del docente es obligatorio',
        ),
      );
    }
    if (limit <= 0) {
      return Stream<List<ClassModel>>.error(
        const InvalidClassRepositoryArgumentException(
          'El límite de paginación debe ser mayor a cero',
        ),
      );
    }
    final stream = _classService.watchTeacherClasses(
      teacherId: sanitizedTeacherId,
      limit: limit,
    );
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (classes, sink) => sink.add(classes),
        handleError: (error, stackTrace, sink) {
          final mapped = _mapToRepositoryException(
            method: 'watchTeacherClasses',
            error: error,
            fallbackMessage: 'No fue posible cargar las clases del docente.',
          );
          sink.addError(mapped, stackTrace);
        },
      ),
    );
  }

  @override
  Future<ClassModel?> getClassById(String classId) async {
    if (classId.trim().isEmpty) {
      throw ArgumentError('El identificador de la clase es obligatorio');
    }
    try {
      return await _classService.getClassById(classId);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'getClassById',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible obtener la clase solicitada.',
        exceptionFactory: (message, cause) =>
            ClassNotFoundException(message, cause: cause),
      );
    }
  }

  @override
  Future<void> inviteStudent(InviteStudentInput input) async {
    try {
      await _membershipService.inviteStudent(input);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'inviteStudent',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible invitar al alumno.',
      );
    }
  }

  @override
  Future<void> joinClassWithCode(JoinClassInput input) async {
    try {
      await _membershipService.joinClassWithCode(input);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'joinClassWithCode',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible unirse a la clase.',
        exceptionFactory: (message, cause) =>
            InvalidAccessCodeException(message, cause: cause),
      );
    }
  }

  @override
  Future<void> updateClassStatus({
    required String classId,
    required bool isActive,
  }) async {
    if (classId.trim().isEmpty) {
      throw ArgumentError('El identificador de la clase es obligatorio');
    }
    try {
      await _classService.updateClassStatus(
        classId: classId,
        isActive: isActive,
      );
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'updateClassStatus',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible actualizar el estado de la clase.',
      );
    }
  }

  @override
  Future<void> removeStudentFromClass({
    required String classId,
    required String studentId,
  }) async {
    if (classId.trim().isEmpty || studentId.trim().isEmpty) {
      throw ArgumentError(
        'Los identificadores de clase y alumno son obligatorios',
      );
    }
    final membershipId = _buildMembershipId(classId, studentId);
    try {
      await _membershipService.removeStudent(membershipId);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'removeStudentFromClass',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible remover al alumno de la clase.',
        exceptionFactory: (message, cause) =>
            MembershipNotFoundException(message, cause: cause),
      );
    }
  }

  @override
  Future<void> regenerateAccessCode(String classId) async {
    if (classId.trim().isEmpty) {
      throw ArgumentError('El identificador de la clase es obligatorio');
    }
    try {
      await _classService.regenerateAccessCode(classId);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'regenerateAccessCode',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible regenerar el código de acceso.',
      );
    }
  }

  @override
  Future<void> fanOutTask({
    required String taskId,
    required String classId,
  }) async {
    try {
      await _fanOutHelper.prepareFanOut(taskId, classId);
      await _fanOutHelper.propagateToAssignments(taskId, classId);
      await _classService.fanOutTaskHook(taskId: taskId, classId: classId);
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'fanOutTask',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage:
            'El fan-out de la tarea se encuentra pendiente de implementación.',
      );
    }
  }

  @override
  Future<MembershipPage> listClassMembers({
    required String classId,
    int limit = _defaultPaginationLimit,
    String? startAfterId,
  }) async {
    if (classId.trim().isEmpty) {
      throw ArgumentError('El identificador de la clase es obligatorio');
    }
    try {
      return await _membershipService.listClassMembers(
        classId: classId,
        limit: limit,
        startAfterId: startAfterId,
      );
    } catch (error, stackTrace) {
      _throwRepositoryException(
        method: 'listClassMembers',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'No fue posible obtener los alumnos de la clase.',
      );
    }
  }

  Never _throwRepositoryException({
    required String method,
    required Object error,
    required String fallbackMessage,
    StackTrace? stackTrace,
    ClassRepositoryException Function(String message, Object cause)?
    exceptionFactory,
  }) {
    log(
      'ClassRepositoryImpl#$method error',
      error: error,
      stackTrace: stackTrace,
    );
    if (error is ClassRepositoryException) {
      throw error;
    }
    if (error is FirebaseErrorMapperException) {
      final exception =
          exceptionFactory?.call(error.message, error) ??
          UnknownClassRepositoryException(error.message, cause: error);
      throw exception;
    }
    throw UnknownClassRepositoryException(fallbackMessage, cause: error);
  }

  ClassRepositoryException _mapToRepositoryException({
    required String method,
    required Object error,
    required String fallbackMessage,
  }) {
    ClassRepositoryException mapped = UnknownClassRepositoryException(
      fallbackMessage,
      cause: error,
    );
    try {
      _throwRepositoryException(
        method: method,
        error: error,
        fallbackMessage: fallbackMessage,
      );
    } on ClassRepositoryException catch (repositoryException) {
      mapped = repositoryException;
    }
    return mapped;
  }

  String _buildMembershipId(String classId, String studentId) =>
      '${classId}_$studentId';
}

const _defaultPaginationLimit = 20;

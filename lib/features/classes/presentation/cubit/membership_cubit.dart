import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/invite_student_input.dart';
import 'package:playing_tracker/features/classes/domain/value_objects/join_class_input.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_state.dart';

/// Cubit encargado de las operaciones de membresías (alumnos en clases).
///
/// Gestiona dos conjuntos de acciones diferenciados:
/// - **Mutaciones**: invitar alumno, unirse por código, activar/desactivar,
///   eliminar membresía y regenerar código de acceso.
/// - **Consulta paginada**: cargar y refrescar la lista de alumnos de una clase
///   con soporte de paginación mediante cursor ([_lastMemberDocumentId]).
///
/// Mantiene una caché interna ([_membersCache]) para evitar re-consultas
/// innecesarias. El parámetro `refresh: true` fuerza la recarga desde cero.
class MembershipCubit extends Cubit<MembershipState> {
  MembershipCubit(this._repository) : super(const MembershipInitial());

  final ClassRepository _repository;

  /// Caché en memoria con los miembros cargados de la clase activa.
  final List<MembershipModel> _membersCache = [];

  /// ID de la clase cuyos alumnos se están consultando actualmente.
  String? _currentClassId;

  /// Cursor de paginación: ID del último documento devuelto por Firestore.
  /// Null indica que la siguiente consulta comenzará desde el principio.
  String? _lastMemberDocumentId;

  /// Indica si existen más páginas por cargar para la clase activa.
  bool _hasMoreMembers = true;

  /// Invita o agrega manualmente un alumno a una clase específica.
  Future<void> inviteStudent(InviteStudentInput input) async {
    emit(const MembershipLoading());
    try {
      await _repository.inviteStudent(input);
      emit(
        const MembershipSuccess(
          action: MembershipAction.invitedStudent,
          message: null,
        ),
      );
      await _refreshMembersAfterMutation();
    } on ClassRepositoryException catch (error) {
      emit(MembershipError(message: error.message, cause: error));
      await _restoreMembersAfterOperation();
    } catch (error) {
      emit(const MembershipError(message: null));
      await _restoreMembersAfterOperation();
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
          message: null,
        ),
      );
      await _refreshMembersAfterMutation();
    } on ClassRepositoryException catch (error) {
      emit(MembershipError(message: error.message, cause: error));
      await _restoreMembersAfterOperation();
    } catch (error) {
      emit(const MembershipError(message: null));
      await _restoreMembersAfterOperation();
    }
  }

  /// Marca la membresía como inactiva (expulsar alumno).
  Future<void> removeStudent({
    required String classId,
    required String studentId,
  }) async {
    await updateStudentMembershipStatus(
      classId: classId,
      studentId: studentId,
      isActive: false,
    );
  }

  /// Activa o inactiva una membresía existente.
  Future<void> updateStudentMembershipStatus({
    required String classId,
    required String studentId,
    required bool isActive,
  }) async {
    emit(const MembershipLoading());
    try {
      await _repository.updateStudentMembershipStatus(
        classId: classId,
        studentId: studentId,
        isActive: isActive,
      );
      emit(
        MembershipSuccess(
          action: isActive
              ? MembershipAction.activatedStudent
              : MembershipAction.deactivatedStudent,
          message: null,
        ),
      );
      await loadMembers(classId: classId, refresh: true);
    } on ClassRepositoryException catch (error) {
      emit(MembershipError(message: error.message, cause: error));
      await _restoreMembersAfterOperation();
    } catch (error) {
      emit(const MembershipError(message: null));
      await _restoreMembersAfterOperation();
    }
  }

  /// Elimina permanentemente la membresía del alumno.
  Future<void> deleteStudentMembership({
    required String classId,
    required String studentId,
  }) async {
    emit(const MembershipLoading());
    try {
      await _repository.deleteStudentMembershipPermanent(
        classId: classId,
        studentId: studentId,
      );
      emit(
        const MembershipSuccess(
          action: MembershipAction.deletedStudent,
          message: null,
        ),
      );
      await loadMembers(classId: classId, refresh: true);
    } on ClassRepositoryException catch (error) {
      emit(MembershipError(message: error.message, cause: error));
      await _restoreMembersAfterOperation();
    } catch (error) {
      emit(const MembershipError(message: null));
      await _restoreMembersAfterOperation();
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
          message: null,
        ),
      );
      await _restoreMembersAfterOperation();
    } on ClassRepositoryException catch (error) {
      emit(MembershipError(message: error.message, cause: error));
      await _restoreMembersAfterOperation();
    } catch (error) {
      emit(const MembershipError(message: null));
      await _restoreMembersAfterOperation();
    }
  }

  /// Carga los alumnos de la clase con soporte de paginación.
  Future<void> loadMembers({
    required String classId,
    bool refresh = false,
  }) async {
    final normalizedClassId = classId.trim();
    if (normalizedClassId.isEmpty) {
      _emitMembersState(const MembershipListError(message: null));
      return;
    }
    final isSameClass = _currentClassId == normalizedClassId;
    final shouldResetCache = !isSameClass || refresh;
    if (shouldResetCache) {
      _membersCache.clear();
      _lastMemberDocumentId = null;
      _hasMoreMembers = true;
      _currentClassId = normalizedClassId;
    }

    if (!_hasMoreMembers &&
        !refresh &&
        isSameClass &&
        _membersCache.isNotEmpty) {
      return;
    }

    final isInitialLoad = _membersCache.isEmpty;
    if (isInitialLoad || refresh || !isSameClass) {
      _emitMembersState(MembershipListLoading(isRefresh: refresh));
    } else {
      _emitMembersState(
        MembershipListSuccess(
          members: List.unmodifiable(_membersCache),
          hasMore: _hasMoreMembers,
          lastDocumentId: _lastMemberDocumentId,
          isPaginating: true,
        ),
      );
    }

    try {
      final page = await _repository.listClassMembers(
        classId: normalizedClassId,
        limit: _membersPageSize,
        startAfterId: (isInitialLoad || refresh || !isSameClass)
            ? null
            : _lastMemberDocumentId,
        includeInactive: true,
      );

      if (isInitialLoad || refresh || !isSameClass) {
        _membersCache.clear();
        _membersCache.addAll(page.members);
      } else {
        _mergeMembers(page.members);
      }

      _lastMemberDocumentId = page.lastDocumentId;
      _hasMoreMembers =
          page.lastDocumentId != null &&
          page.members.length == _membersPageSize;

      if (_membersCache.isEmpty) {
        _emitMembersState(const MembershipEmpty(message: null));
      } else {
        _emitMembersState(
          MembershipListSuccess(
            members: List.unmodifiable(_membersCache),
            hasMore: _hasMoreMembers,
            lastDocumentId: _lastMemberDocumentId,
          ),
        );
      }
    } on ClassRepositoryException catch (error) {
      _emitMembersState(
        MembershipListError(message: error.message, cause: error),
      );
    } catch (error) {
      _emitMembersState(const MembershipListError(message: null));
    }
  }

  /// Fuerza una recarga desde el inicio conservando la clase activa.
  Future<void> refreshMembers() async {
    final classId = _currentClassId;
    if (classId == null) {
      _emitMembersState(
        const MembershipListError(
          message:
              'No se ha seleccionado ninguna clase para refrescar sus alumnos.',
        ),
      );
      return;
    }
    await loadMembers(classId: classId, refresh: true);
  }

  /// Restablece el estado al punto inicial.
  void reset() {
    _membersCache.clear();
    _currentClassId = null;
    _lastMemberDocumentId = null;
    _hasMoreMembers = true;
    emit(const MembershipEmpty());
  }

  /// Fuerza la recarga de la lista de miembros tras una mutación exitosa.
  /// Si no hay clase activa, restaura el último estado conocido.
  Future<void> _refreshMembersAfterMutation() async {
    final classId = _currentClassId;
    if (classId != null) {
      await loadMembers(classId: classId, refresh: true);
    } else {
      await _restoreMembersAfterOperation();
    }
  }

  /// Restaura el último estado emitido de la lista de miembros.
  /// Se usa para recuperar la UI después de una operación fallida.
  Future<void> _restoreMembersAfterOperation() async {
    if (_lastMembersState != null) {
      emit(_lastMembersState!);
    }
  }

  /// Agrega al caché solo los miembros que no estén ya presentes,
  /// evitando duplicados al paginar hacia adelante.
  void _mergeMembers(List<MembershipModel> newMembers) {
    final existingIds = _membersCache.map((member) => member.id).toSet();
    for (final member in newMembers) {
      if (!existingIds.contains(member.id)) {
        _membersCache.add(member);
      }
    }
  }

  /// Emite un estado y lo guarda como último estado conocido de la lista.
  void _emitMembersState(MembershipState state) {
    _lastMembersState = state;
    emit(state);
  }

  /// Último estado de lista de miembros emitido; usado para restaurar la UI tras errores.
  MembershipState? _lastMembersState;
}

const _membersPageSize = 20;

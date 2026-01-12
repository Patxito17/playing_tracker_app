import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/class_state.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_cubit.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';
import 'package:playing_tracker/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:playing_tracker/features/tasks/presentation/widgets/student_selection_modal.dart';

import '../../../../shared/widgets/custom_card.dart';

/// Diálogo mejorado para asignar una tarea a una o varias clases.
/// Permite seleccionar clases del docente y, si solo hay una, personalizar alumnos.
class AssignTaskDialog extends StatefulWidget {
  const AssignTaskDialog({super.key, required this.task});

  final TaskModel task;

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  final Set<String> _selectedClasses = {};
  final Set<String> _selectedStudentIds = {};
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<ClassCubit>().watchClasses(teacherId: authState.userId);
      }
    });
  }

  Future<void> _toggleClass(String classId) async {
    final isSelecting = !_selectedClasses.contains(classId);
    setState(() {
      if (isSelecting) {
        _selectedClasses.add(classId);
      } else {
        _selectedClasses.remove(classId);
      }
      _selectedStudentIds.clear();
      _error = null;
    });

    // Si solo hay una clase seleccionada, precargamos sus asignaciones actuales
    if (isSelecting && _selectedClasses.length == 1) {
      await _loadExistingAssignments(classId);
    }
  }

  Future<void> _loadExistingAssignments(String classId) async {
    final taskCubit = context.read<TaskCubit>();
    final authState = context.read<AuthCubit>().state;
    final teacherId = authState is AuthAuthenticated ? authState.userId : null;

    try {
      final assignments = await taskCubit.getAssignmentsByTaskAndClass(
        taskId: widget.task.id,
        classId: classId,
        teacherId: teacherId,
      );

      if (mounted &&
          _selectedClasses.length == 1 &&
          _selectedClasses.contains(classId)) {
        setState(() {
          _selectedStudentIds.addAll(assignments.map((a) => a.studentId));
        });
      }
    } catch (e) {
      // Error silencioso al precargar, no bloquea el flujo
    }
  }

  void _showStudentSelectionModal(BuildContext context, String classId) {
    final membershipCubit = context.read<MembershipCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BlocProvider.value(
        value: membershipCubit,
        child: StudentSelectionModal(
          classId: classId,
          initialSelectedIds: _selectedStudentIds,
          onSelectionChanged: (selectedIds) {
            setState(() {
              _selectedStudentIds.clear();
              _selectedStudentIds.addAll(selectedIds);
            });
          },
        ),
      ),
    );
  }

  Future<void> _handleAssign() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      setState(() => _error = TaskStrings.taskGenericError);
      return;
    }

    if (_selectedClasses.isEmpty) {
      setState(() => _error = ValidationStrings.atLeastOneClassRequired);
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    final taskCubit = context.read<TaskCubit>();
    final classRepo = context.read<ClassRepository>();

    try {
      // Validar que las clases seleccionadas tengan alumnos
      for (final classId in _selectedClasses) {
        final membersPage = await classRepo.listClassMembers(
          classId: classId,
          limit: 1,
        );
        if (membersPage.members.isEmpty) {
          setState(() {
            _error = TaskStrings.noStudentsInClassError;
            _isSubmitting = false;
          });
          return;
        }
      }

      // Realizar las asignaciones
      for (final classId in _selectedClasses) {
        final studentIds = (_selectedClasses.length == 1)
            ? (_selectedStudentIds.isEmpty
                  ? null
                  : _selectedStudentIds.toList())
            : null;

        await taskCubit.assignTaskToClass((
          taskId: widget.task.id,
          classId: classId,
          teacherId: authState.userId,
          studentIds: studentIds,
        ));
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = TaskStrings.taskGenericError;
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(TaskStrings.assignTask),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<ClassCubit, ClassState>(
            builder: (context, state) {
              final classes = (state is ClassSuccess)
                  ? state.classes
                  : <ClassModel>[];

              if (state is ClassLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.m),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (classes.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                  child: Text(
                    'No tienes clases registradas para asignar esta tarea.',
                    style: context.bodyMediumOnSurfaceVariant,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TaskStrings.selectClassToAssign,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Wrap(
                    spacing: AppSpacing.s,
                    runSpacing: AppSpacing.s,
                    children: classes.map((classModel) {
                      final isSelected = _selectedClasses.contains(
                        classModel.id,
                      );
                      return FilterChip(
                        label: Text(classModel.name),
                        selected: isSelected,
                        onSelected: (_) => _toggleClass(classModel.id),
                        avatar: isSelected
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          if (_selectedClasses.length == 1) ...[
            const SizedBox(height: AppSpacing.m),
            CustomCard(
              title: TaskStrings.recipientsTitle,
              subtitle: _selectedStudentIds.isEmpty
                  ? TaskStrings.assignToAllStudents
                  : '${_selectedStudentIds.length} ${TaskStrings.selectedRecipients}',
              margin: EdgeInsets.zero,
              onTap: () =>
                  _showStudentSelectionModal(context, _selectedClasses.first),
              child: Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      _selectedStudentIds.isEmpty
                          ? TaskStrings.assignToAllStudents
                          : TaskStrings.assignToSelectedStudents,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              _error!,
              style: (context.textError ?? const TextStyle()).copyWith(
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(CommonStrings.cancel),
        ),
        FilledButton(
          onPressed: (_isSubmitting || _selectedClasses.isEmpty)
              ? null
              : _handleAssign,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(TaskStrings.assignTask),
        ),
      ],
    );
  }
}

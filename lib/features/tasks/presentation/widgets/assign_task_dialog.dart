import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/models/task_model.dart';
import '../cubit/task_cubit.dart';

/// Diálogo Material 3 para asignar una tarea a una clase.
///
/// En esta primera iteración permite introducir manualmente el ID de la clase
/// destino. Más adelante puede extenderse para mostrar una lista de clases
/// del docente usando `ClassRepository`.
class AssignTaskDialog extends StatefulWidget {
  const AssignTaskDialog({super.key, required this.task});

  final TaskModel task;

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  final _classIdController = TextEditingController();
  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _classIdController.dispose();
    super.dispose();
  }

  Future<void> _handleAssign() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      setState(() {
        _error = TaskStrings.taskGenericError;
      });
      return;
    }

    final classId = _classIdController.text.trim();
    if (classId.isEmpty) {
      setState(() {
        _error = ValidationStrings.required(TaskStrings.selectClassToAssign);
      });
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    final input = (
      taskId: widget.task.id,
      classId: classId,
      teacherId: authState.userId,
      studentIds: null,
    );

    await context.read<TaskCubit>().assignTaskToClass(input);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(TaskStrings.assignTask),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TaskStrings.selectClassToAssign,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _classIdController,
            decoration: const InputDecoration(labelText: 'ID de la clase'),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
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
          onPressed: _isSubmitting ? null : _handleAssign,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(TaskStrings.assignTask),
        ),
      ],
    );
  }
}

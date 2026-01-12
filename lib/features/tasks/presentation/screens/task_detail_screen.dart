import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/domain/enums/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/models/task_model.dart';
import '../../presentation/cubit/task_cubit.dart';
import '../../presentation/cubit/task_state.dart';
import '../widgets/assign_task_dialog.dart';

/// Pantalla de detalle de tarea conectada a [TaskCubit].
///
/// Muestra información completa de una tarea y permite al docente editarla,
/// asignarla a una clase o eliminarla usando diálogos Material 3.
class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  @override
  void initState() {
    super.initState();
    // En el detalle de tarea, necesitamos asegurarnos de que el docente pueda ver
    // TODAS las tareas (activas e inactivas), ya que puede querer activar/desactivar
    // cualquier tarea desde aquí.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final cubit = context.read<TaskCubit>();

        // Aplicar filtros para mostrar todas las tareas sin importar si están activas
        cubit.watchTasks(
          teacherId: authState.userId,
          filters: (
            isActive: null, // null = mostrar tanto activas como inactivas
            createdFrom: null,
            createdTo: null,
            dueFrom: null,
            dueTo: null,
            status: null,
            assignedFrom: null,
            assignedTo: null,
          ),
        );
      }
    });
  }

  Future<void> _showEditDialog(BuildContext context, TaskModel task) async {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(
      text: task.description ?? '',
    );

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(TaskStrings.editTask),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: TaskStrings.taskTitleLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: TaskStrings.taskDescriptionLabel,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(CommonStrings.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final input = (
                    taskId: task.id,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    durationSuggested: null,
                    attachments: null,
                    dueDate: null,
                    isActive: null,
                  );
                  context.read<TaskCubit>().updateTask(input);
                  Navigator.of(dialogContext).pop();
                },
                child: Text(CommonStrings.save),
              ),
            ],
          );
        },
      );
    } finally {
      // Liberamos explícitamente los controladores usados solo en este diálogo.
      titleController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> _showAssignDialog(BuildContext context, TaskModel task) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AssignTaskDialog(task: task),
    );
  }

  Future<void> _toggleStatus(bool value) async {
    final input = (
      taskId: widget.taskId,
      title: null,
      description: null,
      durationSuggested: null,
      attachments: null,
      dueDate: null,
      isActive: value,
    );
    await context.read<TaskCubit>().updateTask(input);
  }

  Future<void> _confirmDelete(BuildContext context, TaskModel task) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TaskStrings.confirmDeleteTask),
          content: const Text(
            'ATENCIÓN: Esta acción eliminará PERMANENTEMENTE la tarea y todas las asignaciones de los alumnos. '
            'No se podrá recuperar ninguna información. ¿Deseas continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(CommonStrings.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colorScheme.error,
                foregroundColor: context.colorScheme.onError,
              ),
              onPressed: () {
                context.read<TaskCubit>().deleteTask(task.id);
                Navigator.of(dialogContext).pop();
              },
              child: Text(TaskStrings.deleteTask),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isTeacher =
        authState is AuthAuthenticated && authState.role == UserRole.teacher;

    return Scaffold(
      appBar: const CustomAppBar(title: TaskStrings.taskDetailTitle),
      body: BlocConsumer<TaskCubit, TaskState>(
        listenWhen: (previous, current) =>
            current is TaskActionSuccess || current is TaskError,
        listener: (context, state) {
          if (state is TaskActionSuccess &&
              state.action == TaskAction.deleted) {
            context.go(AppRoutes.taskList);
          }
        },
        buildWhen: (previous, current) {
          // No reconstruir cuando es TaskActionSuccess (excepto deleted)
          // Esto mantiene la UI visible mientras el stream actualiza los datos
          if (current is TaskActionSuccess) {
            return current.action == TaskAction.deleted;
          }
          return true;
        },
        builder: (context, state) {
          if (state is TaskLoading || state is TaskInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Center(
                child: SelectableText.rich(
                  TextSpan(text: state.message, style: context.textError),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is! TaskSuccess) {
            return const SizedBox.shrink();
          }

          final matching = state.tasks.where(
            (task) => task.id == widget.taskId,
          );
          if (matching.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: SelectableText.rich(
                  TextSpan(
                    text: TaskStrings.noTasksFound,
                    style: context.bodyMediumOnSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final selectedTask = matching.first;
          final createdDate = selectedTask.createdAt.toDate();
          final dueDate = selectedTask.dueDate?.toDate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomCard(
                  title: selectedTask.title,
                  subtitle: selectedTask.description ?? '',
                  trailingAction: Chip(
                    label: Text(TaskStrings.pending),
                    backgroundColor: context.colorScheme.outline.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: TextStyle(
                      color: context.colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                    avatar: Icon(
                      Icons.pending_outlined,
                      size: 16,
                      color: context.colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.s),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: TaskStrings.estimatedTime,
                        value: selectedTask.durationFormatted,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: TaskStrings.createdDate,
                        value: _formatDate(createdDate),
                      ),
                      if (dueDate != null) ...[
                        const SizedBox(height: AppSpacing.s),
                        _InfoRow(
                          icon: Icons.event,
                          label: TaskStrings.dueDate,
                          value: _formatDate(dueDate),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                CustomCard(
                  title: TaskStrings.recipients,
                  subtitle: TaskStrings.noRecipients,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Text(
                      TaskStrings.noRecipients,
                      style: context.bodyMediumOnSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                CustomCard(
                  title: TaskStrings.attachments,
                  subtitle: TaskStrings.noAttachments,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Text(
                      TaskStrings.noAttachments,
                      style: context.bodyMediumOnSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (isTeacher) ...[
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: SwitchListTile(
                      value: selectedTask.isActive,
                      onChanged: _toggleStatus,
                      title: const Text('Tarea activa'),
                      subtitle: Text(
                        selectedTask.isActive
                            ? 'Visible para los estudiantes'
                            : 'No visible para los estudiantes',
                        style: context.bodySmallOnSurfaceVariant,
                      ),
                      secondary: Icon(
                        selectedTask.isActive
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: selectedTask.isActive
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  CustomButton(
                    label: TaskStrings.editTask,
                    variant: CustomButtonVariant.filled,
                    icon: Icons.edit,
                    onPressed: () => _showEditDialog(context, selectedTask),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  CustomButton(
                    label: TaskStrings.assignTask,
                    variant: CustomButtonVariant.outlined,
                    icon: Icons.person_add,
                    onPressed: () => _showAssignDialog(context, selectedTask),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, selectedTask),
                    icon: Icon(
                      Icons.delete_outline,
                      color: context.colorScheme.error,
                    ),
                    label: Text(
                      TaskStrings.deleteTask,
                      style: TextStyle(color: context.colorScheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colorScheme.error,
                    ),
                  ),
                ] else ...[
                  CustomButton(
                    label: TaskStrings.startTimer,
                    variant: CustomButtonVariant.filled,
                    icon: Icons.play_arrow,
                    onPressed: () => context.push(
                      AppRoutes.timer.replaceAll(':taskId', selectedTask.id),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Widget para mostrar una fila de información
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.s),
        Text('$label: ', style: context.bodySmallOnSurfaceVariant),
        Text(value, style: context.bodySmallBold),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import '../../../classes/domain/repositories/class_repository.dart';
import '../../../classes/presentation/cubit/class_cubit.dart';
import '../../../classes/presentation/cubit/membership_cubit.dart';
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
    final taskCubit = context.read<TaskCubit>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: taskCubit,
        child: _EditTaskDialog(task: task),
      ),
    );
  }

  Future<void> _showAssignDialog(BuildContext context, TaskModel task) async {
    final taskCubit = context.read<TaskCubit>();
    final classRepository = context.read<ClassRepository>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: taskCubit),
          BlocProvider(create: (context) => ClassCubit(classRepository)),
          BlocProvider(create: (context) => MembershipCubit(classRepository)),
        ],
        child: AssignTaskDialog(task: task),
      ),
    );
  }

  Future<void> _refreshTask(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      await context.read<TaskCubit>().refreshTasks();
    }
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
    final taskCubit = context.read<TaskCubit>();
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
                taskCubit.deleteTask(task.id);
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
          if (state is TaskActionSuccess) {
            if (state.action == TaskAction.deleted) {
              context.go(AppRoutes.taskList);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message ?? TaskStrings.taskUpdateSuccess),
                  backgroundColor: context.colorScheme.primary,
                ),
              );
            }
          } else if (state is TaskError) {
            // Si ya tenemos una tarea cargada (o una acción exitosa previa),
            // mostramos el error como un SnackBar en lugar de romper la pantalla.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.colorScheme.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) {
          // Si es una acción exitosa y no es borrado, NO reconstruimos el body.
          if (current is TaskActionSuccess) {
            return current.action == TaskAction.deleted;
          }

          // Si estamos cargando o hay un error, pero ya teníamos datos (Success o ActionSuccess),
          // o venimos de un Loading que a su vez venía de datos...
          // En definitiva: si ya hay algo bueno en pantalla, no reconstruyas para Error/Loading.
          if ((current is TaskLoading || current is TaskError) &&
              (previous is TaskSuccess ||
                  previous is TaskActionSuccess ||
                  previous is TaskLoading)) {
            return false;
          }

          return true;
        },
        builder: (context, state) {
          if (state is TaskLoading || state is TaskInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: context.colorScheme.error,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.m),
                    TextButton(
                      onPressed: () => _refreshTask(context),
                      child: const Text('Reintentar carga'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! TaskSuccess) {
            return const Center(child: Text('Cargando tarea...'));
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

class _EditTaskDialog extends StatefulWidget {
  const _EditTaskDialog({required this.task});

  final TaskModel task;

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _durationController = TextEditingController(
      text: (widget.task.durationSuggested ~/ 60).toString(),
    );
    _dueDate = widget.task.dueDate?.toDate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(TaskStrings.editTask),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: TaskStrings.taskTitleLabel),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: TaskStrings.taskDescriptionLabel,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _durationController,
            decoration: InputDecoration(
              labelText: TaskStrings.estimatedTimeLabel,
              suffixText: ' min',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.m),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(TaskStrings.dueDate),
            subtitle: Text(
              _dueDate != null
                  ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                  : TaskStrings.dueDateHint,
            ),
            onTap: _pickDueDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(CommonStrings.cancel),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final description = _descriptionController.text.trim();
            final minutes = int.tryParse(_durationController.text.trim());

            if (title.isEmpty || minutes == null || minutes <= 0) {
              return;
            }

            final input = (
              taskId: widget.task.id,
              title: title,
              description: description.isEmpty ? null : description,
              durationSuggested: minutes * 60,
              attachments: null,
              dueDate: _dueDate,
              isActive: null,
            );
            context.read<TaskCubit>().updateTask(input);
            Navigator.of(context).pop();
          },
          child: Text(CommonStrings.save),
        ),
      ],
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

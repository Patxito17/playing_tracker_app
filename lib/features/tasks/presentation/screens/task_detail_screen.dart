import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/domain/enums/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../classes/domain/repositories/class_repository.dart';
import '../../../classes/presentation/cubit/class_cubit.dart';
import '../../../classes/presentation/cubit/membership_cubit.dart';
import '../../domain/models/assignment_model.dart';
import '../../domain/models/task_model.dart';
import '../../presentation/cubit/task_cubit.dart';
import '../../presentation/cubit/task_state.dart';
import '../widgets/assign_task_dialog.dart';
import '../widgets/task_info_row.dart';
import '../widgets/task_status_badge.dart';

/// Pantalla de detalle de tarea con diseño premium Material 3.
///
/// Acciones del docente (editar, asignar, eliminar) en barra fija al fondo.
/// Información organizada en cards con jerarquía tipográfica clara.
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<TaskCubit>().watchTasks(
          teacherId: authState.userId,
          filters: (
            isActive: null,
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
      attachmentUrl: null,
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
          title: Text(context.l10n.confirmDeleteTask),
          content: Text(context.l10n.confirmDeleteTaskWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
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
              child: Text(context.l10n.deleteTaskAction),
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
      appBar: CustomAppBar(title: context.l10n.taskDetailTitle),
      body: BlocConsumer<TaskCubit, TaskState>(
        listenWhen: (previous, current) =>
            current is TaskActionSuccess || current is TaskError,
        listener: (context, state) {
          if (state is TaskActionSuccess) {
            if (state.action == TaskAction.deleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.taskDeleteSuccess),
                  backgroundColor: context.colorScheme.primary,
                ),
              );
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.taskList);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message ?? context.l10n.taskUpdateSuccess,
                  ),
                  backgroundColor: context.colorScheme.primary,
                ),
              );
            }
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? context.l10n.loadingError),
                backgroundColor: context.colorScheme.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) {
          if (current is TaskActionSuccess) {
            return current.action == TaskAction.deleted;
          }
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
                    Text(
                      state.message ?? context.l10n.loadingError,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextButton(
                      onPressed: () => _refreshTask(context),
                      child: Text(context.l10n.reTryLoadAction),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! TaskSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          final matching = state.tasks.where((t) => t.id == widget.taskId);
          if (matching.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: SelectableText.rich(
                  TextSpan(
                    text: context.l10n.noTasksFound,
                    style: context.bodyMediumOnSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final task = matching.first;
          final createdDate = task.createdAt.toDate();
          final dueDate = task.dueDate?.toDate();

          return Column(
            children: [
              // Contenido principal scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Card principal con info de la tarea ---
                      _TaskMainCard(
                        task: task,
                        createdDate: createdDate,
                        dueDate: dueDate,
                        formatDate: _formatDate,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      // --- Card destinatarios ---
                      _RecipientsCard(
                        assignmentsStream: context
                            .read<TaskCubit>()
                            .watchTaskAssignments(
                              task.id,
                              teacherId: authState is AuthAuthenticated
                                  ? authState.userId
                                  : null,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      // --- Card adjunto ---
                      _AttachmentCard(task: task),
                      if (isTeacher) ...[
                        const SizedBox(height: AppSpacing.m),
                        // --- Toggle activa/inactiva ---
                        Card(
                          margin: EdgeInsets.zero,
                          child: SwitchListTile(
                            value: task.isActive,
                            onChanged: _toggleStatus,
                            title: Text(context.l10n.activeTaskLabel),
                            subtitle: Text(
                              task.isActive
                                  ? context.l10n.activeTaskSubtitle
                                  : context.l10n.inactiveTaskSubtitle,
                              style: context.bodySmallOnSurfaceVariant,
                            ),
                            secondary: Icon(
                              task.isActive
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: task.isActive
                                  ? context.colorScheme.primary
                                  : context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                      // Espacio para que el contenido no quede debajo de la barra fija
                      const SizedBox(height: AppSpacing.xxl + AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              // --- Barra de acciones fija al fondo ---
              _BottomActionBar(
                task: task,
                isTeacher: isTeacher,
                onEdit: () => _showEditDialog(context, task),
                onAssign: () => _showAssignDialog(context, task),
                onDelete: () => _confirmDelete(context, task),
                onStartTimer: () => context.push(
                  AppRoutes.timer.replaceAll(':taskId', task.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Card principal con título, descripción y metadatos de la tarea.
class _TaskMainCard extends StatelessWidget {
  final TaskModel task;
  final DateTime createdDate;
  final DateTime? dueDate;
  final String Function(DateTime) formatDate;

  const _TaskMainCard({
    required this.task,
    required this.createdDate,
    required this.dueDate,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge de estado
            TaskStatusBadge(
              label: task.isActive
                  ? context.l10n.taskStatusActive
                  : context.l10n.taskStatusArchived,
              icon: task.isActive
                  ? Icons.check_circle_outline
                  : Icons.archive_outlined,
              color: task.isActive
                  ? context.colorScheme.primary
                  : context.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(task.title, style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            )),
            if (task.description?.isNotEmpty == true) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                task.description!,
                style: context.bodyMediumOnSurfaceVariant,
              ),
            ],
            const Divider(height: AppSpacing.xl),
            TaskInfoRow(
              icon: Icons.access_time_outlined,
              label: context.l10n.estimatedTimeRowLabel,
              value: task.durationFormatted,
            ),
            const SizedBox(height: AppSpacing.s),
            TaskInfoRow(
              icon: Icons.calendar_today_outlined,
              label: context.l10n.createdDateRowLabel,
              value: formatDate(createdDate),
            ),
            if (dueDate != null) ...[
              const SizedBox(height: AppSpacing.s),
              TaskInfoRow(
                icon: Icons.event_outlined,
                label: context.l10n.dueDateRowLabel,
                value: formatDate(dueDate!),
                valueColor: context.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card de destinatarios de la tarea con datos en tiempo real.
class _RecipientsCard extends StatelessWidget {
  final Stream<List<AssignmentModel>> assignmentsStream;

  const _RecipientsCard({required this.assignmentsStream});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.recipientsRowLabel,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            StreamBuilder<List<AssignmentModel>>(
              stream: assignmentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.m),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final assignments = snapshot.data ?? [];

                if (assignments.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                      border: Border.all(
                        color: context.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_off_outlined,
                          size: 32,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          context.l10n.noRecipientsLabel,
                          style: context.bodyMediumOnSurfaceVariant,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Agrupar por clase para mostrar un resumen por clase
                final byClass = <String, List<AssignmentModel>>{};
                for (final a in assignments) {
                  final key = a.className ?? a.classId;
                  byClass.putIfAbsent(key, () => []).add(a);
                }

                return Column(
                  children: byClass.entries.map((entry) {
                    final className = entry.key;
                    final classAssignments = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerLow,
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.medium),
                          border: Border.all(
                            color: context.colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 20,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    className,
                                    style:
                                        context.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    context.l10n.studentsCount(
                                      classAssignments.length,
                                    ),
                                    style: context.bodySmallOnSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                            TaskStatusBadge(
                              label: '${classAssignments.length}',
                              icon: Icons.people_outline,
                              color: context.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de adjunto de la tarea.
class _AttachmentCard extends StatelessWidget {
  final TaskModel task;

  const _AttachmentCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.attachmentUrlLabel,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            task.attachmentUrl != null
                ? Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 18,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: SelectableText(
                          task.attachmentUrl!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.attachment_outlined,
                        size: 18,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        context.l10n.noAttachments,
                        style: context.bodyMediumOnSurfaceVariant,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

/// Barra de acciones fija al fondo de la pantalla.
///
/// Docente: Editar (filled) + Asignar + Eliminar.
/// Alumno: Iniciar cronómetro (filled).
class _BottomActionBar extends StatelessWidget {
  final TaskModel task;
  final bool isTeacher;
  final VoidCallback onEdit;
  final VoidCallback onAssign;
  final VoidCallback onDelete;
  final VoidCallback onStartTimer;

  const _BottomActionBar({
    required this.task,
    required this.isTeacher,
    required this.onEdit,
    required this.onAssign,
    required this.onDelete,
    required this.onStartTimer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: isTeacher
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón editar (full width, filled)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(context.l10n.editTaskAction),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  // Asignar + Eliminar en fila
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onAssign,
                          icon: const Icon(Icons.person_add_outlined),
                          label: Text(context.l10n.assignTask),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                          ),
                          label: Text(
                            context.l10n.deleteTaskAction,
                            style: TextStyle(color: colorScheme.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(
                              color: colorScheme.error.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onStartTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(context.l10n.startTimerAction),
                ),
              ),
      ),
    );
  }
}

// ============================================================
// Dialog de edición de tarea
// ============================================================

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
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.editTaskAction),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: context.l10n.taskTitleLabel),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: context.l10n.taskDescriptionLabel,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _durationController,
            decoration: InputDecoration(
              labelText: context.l10n.estimatedTimeRowLabel,
              suffixText: ' min',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.m),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(context.l10n.dueDateRowLabel),
            subtitle: Text(
              _dueDate != null
                  ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                  : context.l10n.dueDateHint,
            ),
            onTap: _pickDueDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final description = _descriptionController.text.trim();
            final minutes = int.tryParse(_durationController.text.trim());

            if (title.isEmpty || minutes == null || minutes <= 0) return;

            final input = (
              taskId: widget.task.id,
              title: title,
              description: description.isEmpty ? null : description,
              durationSuggested: minutes * 60,
              attachmentUrl: null,
              dueDate: _dueDate,
              isActive: null,
            );
            context.read<TaskCubit>().updateTask(input);
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

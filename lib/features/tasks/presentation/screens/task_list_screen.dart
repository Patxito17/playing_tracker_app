import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/models/task_model.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/task_filters_bottom_sheet.dart';
import '../widgets/task_status_badge.dart';

/// Pantalla de lista de tareas del docente.
///
/// Muestra las tareas reales del docente con diseño premium Material 3.
/// Las tareas activas tienen mayor prominencia visual que las archivadas.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<TaskCubit>().watchTasks(teacherId: authState.userId);
      }
    });
  }

  List<TaskModel> _applyFilters(List<TaskModel> tasks) => tasks;

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TaskFiltersBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.myTasksTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
            tooltip: context.l10n.filters,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(
              AppRoutes.createTask,
              extra: context.read<TaskCubit>(),
            ),
            tooltip: context.l10n.createTaskAction,
          ),
        ],
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        buildWhen: (previous, current) {
          if (current is TaskActionSuccess) return false;
          if (previous is TaskSuccess &&
              (current is TaskLoading || current is TaskError)) {
            return false;
          }
          return true;
        },
        listener: (context, state) {
          if (state is TaskActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? context.l10n.taskUpdateSuccess),
                backgroundColor: context.colorScheme.primary,
              ),
            );
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? context.l10n.loadingError),
                backgroundColor: context.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if ((state is TaskLoading || state is TaskInitial) &&
              state is! TaskSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError && state is! TaskSuccess) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Center(
                child: SelectableText.rich(
                  TextSpan(
                    text: state.message ?? context.l10n.loadingError,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is TaskEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<TaskCubit>().refreshTasks(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.l),
                children: [
                  _TaskEmptyState(
                    message: state.message?.isNotEmpty == true
                        ? state.message!
                        : context.l10n.noTasksFound,
                    onCreateTap: () => context.push(
                      AppRoutes.createTask,
                      extra: context.read<TaskCubit>(),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is! TaskSuccess) return const SizedBox.shrink();

          final tasks = _applyFilters(state.tasks);

          return RefreshIndicator(
            onRefresh: () => context.read<TaskCubit>().refreshTasks(),
            child: tasks.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.l),
                    children: [
                      _TaskEmptyState(
                        message: context.l10n.noTasksFound,
                        onCreateTap: () => context.push(
                          AppRoutes.createTask,
                          extra: context.read<TaskCubit>(),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.xxl * 2,
                    ),
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskCard(
                        task: task,
                        onTap: () => context.push(
                          AppRoutes.taskDetail.replaceAll(':taskId', task.id),
                          extra: context.read<TaskCubit>(),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          AppRoutes.createTask,
          extra: context.read<TaskCubit>(),
        ),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.createTaskAction),
      ),
    );
  }
}

/// Card de tarea con diseño premium Material 3.
///
/// Las tareas activas tienen fondo surfaceContainer normal.
/// Las archivadas tienen menor opacidad y fondo tintado.
class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isActive = task.isActive;

    return Opacity(
      opacity: isActive ? 1.0 : 0.72,
      child: Card(
        elevation: isActive ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          side: BorderSide(
            color: isActive
                ? colorScheme.outlineVariant.withValues(alpha: 0.5)
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        color: isActive
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLowest,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description?.isNotEmpty == true) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          task.description!,
                          style: context.bodySmallOnSurfaceVariant,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            task.durationFormatted,
                            style: context.bodySmallOnSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                TaskStatusBadge(
                  label: isActive
                      ? context.l10n.taskStatusActive
                      : context.l10n.taskStatusArchived,
                  icon: isActive
                      ? Icons.check_circle_outline
                      : Icons.archive_outlined,
                  color: isActive ? colorScheme.primary : colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado vacío de la lista de tareas del docente.
class _TaskEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onCreateTap;

  const _TaskEmptyState({required this.message, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 48,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            message,
            style: context.titleLargeBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            context.l10n.adjustFilters,
            style: context.bodyMediumOnSurfaceVariant,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.createTaskAction),
          ),
        ],
      ),
    );
  }
}

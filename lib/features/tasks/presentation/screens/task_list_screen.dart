import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/models/task_model.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/task_filters_bottom_sheet.dart';

/// Pantalla de lista de tareas conectada a [TaskCubit].
///
/// Muestra las tareas reales del docente y se preparará para soportar filtros
/// compatibles con Firestore mediante un bottom sheet en esta fase del sprint.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializamos la suscripción al stream de tareas en initState para
    // garantizar que se establezca correctamente antes del primer build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<TaskCubit>().watchTasks(teacherId: authState.userId);
      }
    });
  }

  List<TaskModel> _applyFilters(List<TaskModel> tasks) {
    // Por ahora la pantalla no aplica filtros adicionales en memoria; el
    // filtrado real se realiza a nivel de repositorio usando [TaskFilters]
    // desde el [TaskCubit]. Este método queda como punto de extensión para
    // futuras transformaciones locales si fueran necesarias.
    return tasks;
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TaskFiltersBottomSheet(),
    );
  }

  String _getStatusText(bool isActive) {
    return isActive ? TaskStrings.active : TaskStrings.archived;
  }

  Color _getStatusColor(bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return isActive ? colorScheme.primary : colorScheme.outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TaskStrings.myTasksTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
            tooltip: TaskStrings.filters,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(
              AppRoutes.createTask,
              extra: context.read<TaskCubit>(),
            ),
            tooltip: TaskStrings.createTask,
          ),
        ],
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading || state is TaskInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Center(
                child: SelectableText.rich(
                  TextSpan(
                    text: state.message,
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
                  _EmptyState(
                    icon: Icons.assignment_outlined,
                    title: state.message,
                    subtitle: TaskStrings.adjustFilters,
                    actionLabel: TaskStrings.createTask,
                    onAction: () => context.push(
                      AppRoutes.createTask,
                      extra: context.read<TaskCubit>(),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is! TaskSuccess) {
            return const SizedBox.shrink();
          }

          final tasks = _applyFilters(state.tasks);

          return RefreshIndicator(
            onRefresh: () => context.read<TaskCubit>().refreshTasks(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (tasks.isEmpty)
                    _EmptyState(
                      icon: Icons.assignment_outlined,
                      title: TaskStrings.noTasksFound,
                      subtitle: TaskStrings.adjustFilters,
                      actionLabel: TaskStrings.createTask,
                      onAction: () => context.push(
                        AppRoutes.createTask,
                        extra: context.read<TaskCubit>(),
                      ),
                    )
                  else
                    ...tasks.map((task) {
                      final statusText = _getStatusText(task.isActive);
                      final statusColor = _getStatusColor(task.isActive);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: CustomCard(
                          title: task.title,
                          subtitle: task.description ?? '',
                          trailingAction: Chip(
                            label: Text(statusText),
                            backgroundColor: statusColor.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                            avatar: Icon(
                              task.isActive
                                  ? Icons.check_circle_outline
                                  : Icons.archive_outlined,
                              size: 16,
                              color: statusColor,
                            ),
                          ),
                          onTap: () => context.push(
                            AppRoutes.taskDetail.replaceAll(':taskId', task.id),
                            extra: context.read<TaskCubit>(),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.s),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: context.colorScheme.onSurfaceVariant,
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
                      );
                    }),
                ],
              ),
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
        label: Text(TaskStrings.createTask),
      ),
    );
  }
}

/// Widget para mostrar estado vacío
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: context.colorScheme.outline),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            style: context.titleLargeBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle,
            style: context.bodyMediumOnSurfaceVariant,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

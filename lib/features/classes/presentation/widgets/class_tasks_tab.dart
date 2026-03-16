import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/features/tasks/presentation/widgets/task_status_badge.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Tab de tareas de la clase (para docente).
///
/// Muestra las tareas asignadas a esta clase agrupadas por tarea,
/// con diseño premium Material 3.
class ClassTasksTab extends StatelessWidget {
  final String classId;

  const ClassTasksTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final teacherId = authState is AuthAuthenticated ? authState.userId : null;

    return StreamBuilder<List<AssignmentModel>>(
      stream: context.read<TaskRepository>().watchClassAssignments(
        classId,
        teacherId: teacherId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              context.l10n.classGenericError,
              style: context.bodyMediumOnSurfaceVariant,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final assignments = snapshot.data ?? [];

        // Agrupar asignaciones por taskId
        final tasksGrouped = <String, List<AssignmentModel>>{};
        for (final assignment in assignments) {
          tasksGrouped.putIfAbsent(assignment.taskId, () => []).add(assignment);
        }

        return RefreshIndicator(
          onRefresh: () async {
            // El StreamBuilder se actualiza solo; el pull-to-refresh
            // solo necesita completar para desaparecer el indicador.
          },
          child: tasksGrouped.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  children: [
                    _ClassTasksEmptyState(
                      onCreateTap: () => context.push(AppRoutes.createTask),
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
                  itemCount: tasksGrouped.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.s),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.s),
                        child: FilledButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.createTask),
                          icon: const Icon(Icons.add),
                          label: Text(context.l10n.createTaskAction),
                        ),
                      );
                    }

                    final entry =
                        tasksGrouped.entries.elementAt(index - 1);
                    final taskId = entry.key;
                    final taskAssignments = entry.value;
                    final taskTitle =
                        taskAssignments.first.taskTitle ??
                        context.l10n.noTasksFound;
                    final count = taskAssignments.length;
                    final completedCount =
                        taskAssignments.where((a) => a.isCompleted).length;

                    return _ClassTaskCard(
                      taskTitle: taskTitle,
                      studentCount: count,
                      completedCount: completedCount,
                      onTap: () => context.pushNamed(
                        'taskDetail',
                        pathParameters: {'taskId': taskId},
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

/// Card de tarea en el contexto de la clase.
class _ClassTaskCard extends StatelessWidget {
  final String taskTitle;
  final int studentCount;
  final int completedCount;
  final VoidCallback onTap;

  const _ClassTaskCard({
    required this.taskTitle,
    required this.studentCount,
    required this.completedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final allCompleted =
        studentCount > 0 && completedCount == studentCount;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: colorScheme.surfaceContainerLow,
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
                      taskTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          context.l10n.studentsCount(studentCount),
                          style: context.bodySmallOnSurfaceVariant,
                        ),
                        if (completedCount > 0) ...[
                          const SizedBox(width: AppSpacing.s),
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '$completedCount ${context.l10n.completed.toLowerCase()}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              TaskStatusBadge(
                label: allCompleted
                    ? context.l10n.completed
                    : '$completedCount/$studentCount',
                icon: allCompleted
                    ? Icons.check_circle_outline
                    : Icons.assignment_outlined,
                color: allCompleted
                    ? colorScheme.tertiary
                    : colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Estado vacío premium para la tab de tareas de la clase.
class _ClassTasksEmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;

  const _ClassTasksEmptyState({required this.onCreateTap});

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
              color: context.colorScheme.primaryContainer
                  .withValues(alpha: 0.4),
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
            context.l10n.noTasksInClass,
            style: context.titleLargeBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            context.l10n.noTasksInClassSubtitle,
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

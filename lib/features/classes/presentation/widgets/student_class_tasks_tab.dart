import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Tab de tareas de la clase (para estudiante)
///
/// Muestra todas las tareas asignadas al estudiante con opción para iniciar sesión de estudio.
/// Sprint 0 - Fase 7: UI completa con Material Design 3 y estados visuales
class StudentClassTasksTab extends StatelessWidget {
  final String classId;

  const StudentClassTasksTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }
    final studentId = authState.userId;

    return StreamBuilder<List<AssignmentModel>>(
      stream: context.read<TaskRepository>().watchStudentAssignments(studentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              TaskStrings.taskGenericError,
              style: context.bodyMediumOnSurfaceVariant,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allAssignments = snapshot.data ?? [];
        final classAssignments = allAssignments
            .where((a) => a.classId == classId)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (classAssignments.isEmpty)
                _EmptyTasksState(
                  icon: Icons.assignment_outlined,
                  title: TaskStrings.noTasksAssigned,
                  subtitle: TaskStrings.waitForTasks,
                  actionLabel: CommonStrings.close,
                  onAction: () => context.pop(),
                )
              else
                ...classAssignments.map((assignment) {
                  final status = assignment.status;
                  final statusText = _getStatusText(status);
                  final statusColor = _getStatusColor(context, status);
                  final title = assignment.taskTitle ?? 'Sin título';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: CustomCard(
                      title: title,
                      subtitle: '${TaskStrings.status}: $statusText',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge de estado
                          Chip(
                            label: Text(statusText),
                            backgroundColor: statusColor.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                            avatar: Icon(
                              _getStatusIcon(status),
                              size: 16,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          CustomButton(
                            label: status == TaskStatus.completed
                                ? TaskStrings.viewDetails
                                : TaskStrings.startStudySession,
                            variant: status == TaskStatus.completed
                                ? CustomButtonVariant.outlined
                                : CustomButtonVariant.filled,
                            icon: status == TaskStatus.completed
                                ? Icons.visibility_outlined
                                : Icons.play_arrow,
                            onPressed: () {
                              if (status == TaskStatus.completed) {
                                context.push(
                                  AppRoutes.taskDetail.replaceAll(
                                    ':taskId',
                                    assignment.taskId,
                                  ),
                                );
                              } else {
                                context.push(
                                  AppRoutes.timer.replaceAll(
                                    ':taskId',
                                    assignment.taskId,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return TaskStrings.pending;
      case TaskStatus.inProgress:
        return TaskStrings.inProgress;
      case TaskStatus.completed:
        return TaskStrings.completed;
    }
  }

  Color _getStatusColor(BuildContext context, TaskStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case TaskStatus.pending:
        return colorScheme.outline;
      case TaskStatus.inProgress:
        return colorScheme.primary;
      case TaskStatus.completed:
        return colorScheme.tertiary;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.pending_outlined;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
    }
  }
}

/// Widget para mostrar estado vacío en tabs de tareas
class _EmptyTasksState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyTasksState({
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
          Icon(icon, size: 80, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            style: context.titleLargeBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.close),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    // Datos mock de tareas
    final mockTasks = [
      {'id': 'task1', 'title': 'Escala de Do Mayor', 'status': 'pending'},
      {'id': 'task2', 'title': 'Arpegios de Do Menor', 'status': 'in_progress'},
      {'id': 'task3', 'title': 'Ejercicio de velocidad', 'status': 'completed'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mockTasks.isEmpty)
            _EmptyTasksState(
              icon: Icons.assignment_outlined,
              title: TaskStrings.noTasksAssigned,
              subtitle: TaskStrings.waitForTasks,
              actionLabel: CommonStrings.close,
              onAction: () => context.pop(),
            )
          else
            ...mockTasks.map((taskData) {
              final status = taskData['status'] as String;
              final statusText = _getStatusText(status);
              final statusColor = _getStatusColor(context, status);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: CustomCard(
                  title: taskData['title'] as String,
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
                        label: status == 'completed'
                            ? TaskStrings.viewDetails
                            : TaskStrings.startStudySession,
                        variant: status == 'completed'
                            ? CustomButtonVariant.outlined
                            : CustomButtonVariant.filled,
                        icon: status == 'completed'
                            ? Icons.visibility_outlined
                            : Icons.play_arrow,
                        onPressed: () {
                          if (status == 'completed') {
                            context.push(
                              AppRoutes.taskDetail.replaceAll(
                                ':taskId',
                                taskData['id'] as String,
                              ),
                            );
                          } else {
                            context.push(
                              AppRoutes.timer.replaceAll(
                                ':taskId',
                                taskData['id'] as String,
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
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return TaskStrings.pending;
      case 'in_progress':
        return TaskStrings.inProgress;
      case 'completed':
        return TaskStrings.completed;
      default:
        return TaskStrings.pending;
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'pending':
        return colorScheme.outline;
      case 'in_progress':
        return colorScheme.primary;
      case 'completed':
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'in_progress':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.pending_outlined;
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

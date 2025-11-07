import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Tab de tareas de la clase (para docente)
///
/// Muestra todas las tareas de la clase con opción para crear nuevas.
/// Sprint 0 - Fase 7: UI completa con Material Design 3
class ClassTasksTab extends StatelessWidget {
  final String classId;

  const ClassTasksTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    // Datos mock de tareas
    final mockTasks = [
      {'id': 'task1', 'title': 'Escala de Do Mayor', 'assignedTo': 12},
      {'id': 'task2', 'title': 'Arpegios de Do Menor', 'assignedTo': 8},
      {'id': 'task3', 'title': 'Ejercicio de velocidad', 'assignedTo': 15},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
            label: TaskStrings.createTask,
            variant: CustomButtonVariant.filled,
            icon: Icons.add,
            onPressed: () => context.push(AppRoutes.createTask),
          ),
          const SizedBox(height: AppSpacing.m),
          if (mockTasks.isEmpty)
            _EmptyState(
              icon: Icons.assignment_outlined,
              title: TaskStrings.noTasksInClass,
              subtitle: TaskStrings.createFirstTask,
              actionLabel: TaskStrings.createTask,
              onAction: () => context.push(AppRoutes.createTask),
            )
          else
            ...mockTasks.map((taskData) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: CustomCard(
                  title: taskData['title'] as String,
                  subtitle:
                      '${TaskStrings.assignedTo} ${taskData['assignedTo']} ${TaskStrings.studentsLabel}',
                  onTap: () => context.push(
                    AppRoutes.taskDetail.replaceAll(
                      ':taskId',
                      taskData['id'] as String,
                    ),
                  ),
                  child: const SizedBox.shrink(),
                ),
              );
            }),
        ],
      ),
    );
  }
}

/// Widget para mostrar estado vacío en tabs
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
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
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

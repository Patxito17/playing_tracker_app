import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomButton(
                label: context.l10n.tasksTab, // O createTask si estuviera
                variant: CustomButtonVariant.filled,
                icon: Icons.add,
                onPressed: () => context.push(AppRoutes.createTask),
              ),
              const SizedBox(height: AppSpacing.m),
              if (tasksGrouped.isEmpty)
                _EmptyState(
                  icon: Icons.assignment_outlined,
                  title: context.l10n.tasksTab, // O noTasksInClass
                  subtitle: context.l10n.tasksTab, // O createFirstTask
                  actionLabel: context.l10n.tasksTab,
                  onAction: () => context.push(AppRoutes.createTask),
                )
              else
                ...tasksGrouped.entries.map((entry) {
                  final taskId = entry.key;
                  final taskAssignments = entry.value;
                  // Usamos el título del primer assignment (todos deberían ser iguales para la misma task)
                  final taskTitle =
                      taskAssignments.first.taskTitle ?? 'Sin título';
                  final count = taskAssignments.length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: CustomCard(
                      title: taskTitle,
                      subtitle:
                          '${context.l10n.assignedToLabel} ${context.l10n.studentsCount(count)}',
                      onTap: () => context.pushNamed(
                        'taskDetail',
                        pathParameters: {'taskId': taskId},
                      ),
                      child: const SizedBox.shrink(),
                    ),
                  );
                }),
            ],
          ),
        );
      },
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

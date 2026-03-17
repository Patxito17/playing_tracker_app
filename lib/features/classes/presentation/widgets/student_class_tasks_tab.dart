import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../tasks/presentation/widgets/assignment_card.dart';

/// Tab de tareas de la clase (para estudiante).
///
/// Muestra las tareas asignadas al alumno autenticado en la clase indicada.
/// Cada tarea incluye acceso directo para iniciar una sesión de estudio.
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
              context.l10n.classGenericError,
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
                  title: context.l10n.noTasksInClass,
                  subtitle: context.l10n.noTasksInClass, // O similar
                  actionLabel: context.l10n.close,
                  onAction: () => context.pop(),
                )
              else
                ...classAssignments.map(
                  (assignment) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: AssignmentCard(assignment: assignment),
                  ),
                ),
            ],
          ),
        );
      },
    );
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

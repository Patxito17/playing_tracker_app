import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/models/assignment_model.dart';

/// Widget reutilizable que muestra un [AssignmentModel] con información
/// visual del estado, progreso y detalles de la asignación.
///
/// Muestra:
/// - Título de la tarea (denormalizado)
/// - Chip de estado con color y nombre según [TaskStatus]
/// - Duración sugerida
/// - Progreso (sesiones completadas y tiempo total practicado)
///
/// Ejemplo de uso:
/// ```dart
/// AssignmentCard(
///   assignment: assignmentModel,
///   onTap: () => navigateToDetail(assignment.id),
/// )
/// ```
class AssignmentCard extends StatelessWidget {
  /// Asignación a mostrar en el card
  final AssignmentModel assignment;

  /// Callback al hacer tap en el card
  final VoidCallback? onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = assignment.status.color;
    final statusText = assignment.status.displayName;

    return CustomCard(
      title: assignment.taskTitle ?? TaskStrings.noTasksAssigned,
      trailingAction: Chip(
        label: Text(statusText),
        backgroundColor: statusColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
        avatar: Icon(
          _getStatusIcon(assignment.status),
          size: 16,
          color: statusColor,
        ),
      ),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s),
          // Duración sugerida
          if (assignment.durationSuggested != null)
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _formatDuration(assignment.durationSuggested!),
                  style: context.bodySmallOnSurfaceVariant,
                ),
              ],
            ),
          // Progreso (sesiones y tiempo total)
          if (assignment.sessionsCount > 0 || assignment.totalDurationLogged > 0) ...[
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${TaskStrings.sessionsCompleted}: ${assignment.sessionsCount}',
                  style: context.bodySmallOnSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.m),
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${TaskStrings.totalPracticeTime}: ${assignment.durationFormatted}',
                  style: context.bodySmallOnSurfaceVariant,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Retorna el icono apropiado según el estado de la asignación
  IconData _getStatusIcon(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => Icons.pending_outlined,
      TaskStatus.inProgress => Icons.play_circle_outline,
      TaskStatus.completed => Icons.check_circle_outline,
    };
  }

  /// Formatea la duración sugerida en formato legible (minutos/horas)
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? "$minutes min" : ""}';
    }
    return '$minutes min';
  }
}


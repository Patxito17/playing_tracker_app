import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/shared/widgets/custom_button.dart';
import 'package:playing_tracker/shared/widgets/custom_card.dart';

/// Tarjeta de tarea del alumno con información motivadora y badge interactivo
///
/// Muestra el título de la tarea, estado actual, y permite iniciar sesiones de estudio.
/// Al pulsar el badge de estado, muestra un diálogo con información motivadora sobre
/// días restantes hasta la fecha límite y progreso de tiempo de estudio.
class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback? onTap;

  const AssignmentCard({super.key, required this.assignment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = assignment.status;
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(context, status);
    final title = assignment.taskTitle ?? 'Sin título';

    return CustomCard(
      onTap: onTap,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badge de estado tocable
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => _showProgressDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Chip(
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
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          // Botón de iniciar sesión siempre visible
          CustomButton(
            label: TaskStrings.startStudySession,
            variant: CustomButtonVariant.filled,
            icon: Icons.play_arrow,
            onPressed: () => _navigateToTimer(context),
          ),
        ],
      ),
    );
  }

  /// Muestra bottom sheet con información motivadora del progreso
  void _showProgressDialog(BuildContext context) {
    // Calcular mensaje de fecha límite
    final daysRemainingValue = assignment.daysRemaining;
    String dueDateMessage;
    Color dueDateColor;

    if (daysRemainingValue != null) {
      if (daysRemainingValue < 0) {
        dueDateMessage = TaskStrings.overdueDays(-daysRemainingValue);
        dueDateColor = Theme.of(context).colorScheme.error;
      } else if (daysRemainingValue == 0) {
        dueDateMessage = TaskStrings.dueToday;
        dueDateColor = Colors.orange;
      } else if (daysRemainingValue == 1) {
        dueDateMessage = TaskStrings.dueTomorrow;
        dueDateColor = Colors.orange;
      } else {
        dueDateMessage = TaskStrings.daysRemaining(daysRemainingValue);
        dueDateColor = Theme.of(context).colorScheme.primary;
      }
    } else {
      dueDateMessage = TaskStrings.noDueDate;
      dueDateColor = Theme.of(context).colorScheme.outline;
    }

    // Calcular mensaje de tiempo de estudio
    final remainingSeconds = assignment.studyTimeRemaining;
    String studyMessage;

    if (remainingSeconds < 0) {
      final extraMinutes = (-remainingSeconds / 60).round();
      studyMessage = TaskStrings.extraStudyTime('$extraMinutes min');
    } else if (remainingSeconds == 0) {
      studyMessage = TaskStrings.studyGoalReached;
    } else {
      final minutes = (remainingSeconds / 60).round();
      studyMessage = TaskStrings.studyTimeRemaining('$minutes min');
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              TaskStrings.taskProgressTitle,
              style: context.titleLargeBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            _ProgressInfoCard(
              icon: Icons.calendar_today,
              message: dueDateMessage,
              color: dueDateColor,
            ),
            const SizedBox(height: AppSpacing.s),
            _ProgressInfoCard(
              icon: Icons.timer,
              message: studyMessage,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              TaskStrings.keepGoing,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(CommonStrings.close),
            ),
          ],
        ),
      ),
    );
  }

  /// Navega al TimerScreen con todos los parámetros necesarios
  void _navigateToTimer(BuildContext context) {
    context.pushNamed(
      'timer',
      pathParameters: {'taskId': assignment.taskId},
      extra: {
        'studentId': assignment.studentId,
        'teacherId': assignment.teacherId,
        'taskTitle': assignment.taskTitle ?? 'Tarea',
        'className': assignment.className,
        'classId': assignment.classId,
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

/// Widget para mostrar info de progreso en el bottom sheet
class _ProgressInfoCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _ProgressInfoCard({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

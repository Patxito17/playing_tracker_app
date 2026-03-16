import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/presentation/widgets/task_status_badge.dart';

/// Tarjeta de asignación del alumno con diseño gamificado y motivador.
///
/// El fondo y el acento de color varían según el estado de la tarea,
/// guiando visualmente al alumno hacia las tareas pendientes e in-progress.
/// Muestra un icono musical decorativo según el estado.
class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback? onTap;

  const AssignmentCard({super.key, required this.assignment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = assignment.status;
    final statusText = _getStatusText(context, status);
    final statusColor = _getStatusColor(context, status);
    final statusIcon = _getStatusIcon(status);
    final musicIcon = _getMusicIcon(status);
    final title = assignment.taskTitle ?? context.l10n.noTasksFound;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
      ),
      color: _getCardColor(context, status),
      child: InkWell(
        onTap: onTap ?? () => _showProgressDialog(context),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskStatusBadge(
                      label: statusText,
                      icon: statusIcon,
                      color: statusColor,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      title,
                      style: context.titleMediumBold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildActionButton(context, status),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              // Acento musical decorativo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.large),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  musicIcon,
                  size: 36,
                  color: statusColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, TaskStatus status) {
    if (status == TaskStatus.completed) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: _getStatusColor(context, status),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            context.l10n.completed,
            style: TextStyle(
              color: _getStatusColor(context, status),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final isInProgress = status == TaskStatus.inProgress;
    return FilledButton.icon(
      onPressed: () => _navigateToTimer(context),
      icon: Icon(
        isInProgress ? Icons.play_circle_outline : Icons.play_arrow,
        size: 18,
      ),
      label: Text(
        isInProgress
            ? context.l10n.continueStudySession
            : context.l10n.startStudySession,
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Color _getCardColor(BuildContext context, TaskStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case TaskStatus.pending:
        return colorScheme.surfaceContainerLow;
      case TaskStatus.inProgress:
        return colorScheme.primaryContainer.withValues(alpha: 0.35);
      case TaskStatus.completed:
        return colorScheme.tertiaryContainer.withValues(alpha: 0.35);
    }
  }

  /// Muestra bottom sheet con información motivadora del progreso
  void _showProgressDialog(BuildContext context) {
    final daysRemainingValue = assignment.daysRemaining;
    String dueDateMessage;
    Color dueDateColor;

    if (daysRemainingValue != null) {
      if (daysRemainingValue < 0) {
        dueDateMessage = context.l10n.overdueDays(-daysRemainingValue);
        dueDateColor = Theme.of(context).colorScheme.error;
      } else if (daysRemainingValue == 0) {
        dueDateMessage = context.l10n.dueToday;
        dueDateColor = Theme.of(context).colorScheme.secondary;
      } else if (daysRemainingValue == 1) {
        dueDateMessage = context.l10n.dueTomorrow;
        dueDateColor = Theme.of(context).colorScheme.secondary;
      } else {
        dueDateMessage = context.l10n.daysRemaining(daysRemainingValue);
        dueDateColor = Theme.of(context).colorScheme.primary;
      }
    } else {
      dueDateMessage = context.l10n.noDueDate;
      dueDateColor = Theme.of(context).colorScheme.outline;
    }

    final remainingSeconds = assignment.studyTimeRemaining;
    String studyMessage;

    if (remainingSeconds < 0) {
      final extraMinutes = (-remainingSeconds / 60).round();
      studyMessage = context.l10n.extraStudyTime('$extraMinutes min');
    } else if (remainingSeconds == 0) {
      studyMessage = context.l10n.studyGoalReached;
    } else {
      final minutes = (remainingSeconds / 60).round();
      studyMessage = context.l10n.studyTimeRemaining('$minutes min');
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
              context.l10n.taskProgressTitle,
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
              context.l10n.keepGoing,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ],
        ),
      ),
    );
  }

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

  String _getStatusText(BuildContext context, TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return context.l10n.pending;
      case TaskStatus.inProgress:
        return context.l10n.inProgress;
      case TaskStatus.completed:
        return context.l10n.completed;
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

  IconData _getMusicIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.music_note_outlined;
      case TaskStatus.inProgress:
        return Icons.piano_outlined;
      case TaskStatus.completed:
        return Icons.library_music_outlined;
    }
  }
}

/// Tarjeta de progreso en el bottom sheet motivacional
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
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
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

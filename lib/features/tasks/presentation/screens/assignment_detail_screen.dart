import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../domain/enums/task_status.dart';
import '../cubit/assignment_cubit.dart';
import '../cubit/assignment_state.dart';

/// Pantalla de detalle de asignación conectada a [AssignmentCubit].
///
/// Muestra información completa de una asignación y permite al alumno
/// iniciar una sesión de práctica (placeholder para Sprint 5).
class AssignmentDetailScreen extends StatefulWidget {
  final String assignmentId;

  const AssignmentDetailScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours h ${minutes > 0 ? "$minutes min" : ""}';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: TaskStrings.assignmentDetailTitle),
      body: BlocBuilder<AssignmentCubit, AssignmentState>(
        builder: (context, state) {
          if (state is AssignmentLoading || state is AssignmentInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AssignmentError) {
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

          if (state is! AssignmentSuccess) {
            return const SizedBox.shrink();
          }

          // Buscar la asignación de forma segura para evitar crashes si no existe
          // Esto puede ocurrir si el estado cambia, se aplican filtros o hay
          // condiciones de carrera durante la navegación
          final matchingAssignments = state.assignments.where(
            (a) => a.id == widget.assignmentId,
          );
          final assignment = matchingAssignments.isEmpty
              ? null
              : matchingAssignments.first;

          // Si no se encontró la asignación, mostrar mensaje de error
          if (assignment == null) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Center(
                child: SelectableText.rich(
                  TextSpan(
                    text: TaskStrings.taskGenericError,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final statusColor = assignment.status.color;
          final statusText = assignment.status.displayName;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomCard(
                  title: assignment.taskTitle ?? TaskStrings.taskTitleLabel,
                  subtitle: assignment.durationSuggested != null
                      ? '${TaskStrings.durationSuggested}: ${_formatDuration(assignment.durationSuggested!)}'
                      : null,
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
                  child: const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.m),
                CustomCard(
                  title: TaskStrings.status,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoRow(
                        TaskStrings.sessionsCompleted,
                        '${assignment.sessionsCount}',
                      ),
                      const SizedBox(height: AppSpacing.s),
                      _buildInfoRow(
                        TaskStrings.totalPracticeTime,
                        assignment.durationFormatted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                CustomCard(
                  title: TaskStrings.assignedAt,
                  child: Text(
                    _formatDate(assignment.assignedAt.toDate()),
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomButton(
                  label: TaskStrings.startPractice,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(TaskStrings.practiceAvailableSoon),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => Icons.pending_outlined,
      TaskStatus.inProgress => Icons.play_circle_outline,
      TaskStatus.completed => Icons.check_circle_outline,
    };
  }
}

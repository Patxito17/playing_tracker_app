import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/auth/presentation/widgets/auth_wrapper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla de detalle de tarea
///
/// Muestra información completa de una tarea y acciones según el rol.
/// Sprint 0 - Fase 8: UI completa con Material Design 3
class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  // Datos mock de tarea
  Map<String, dynamic> _getMockTaskData() {
    return {
      'id': taskId,
      'title': 'Escala de Do Mayor',
      'description':
          'Practicar la escala de Do Mayor en todas las octavas. Enfocarse en mantener un tempo constante y una técnica correcta.',
      'status': 'pending',
      'estimatedTime': 30,
      'createdDate': '2025-11-01',
      'dueDate': '2025-11-15',
      'recipients': [
        {'id': 'student1', 'name': 'Juan Pérez'},
        {'id': 'student2', 'name': 'María García'},
        {'id': 'student3', 'name': 'Carlos López'},
      ],
      'attachments': ['escala_do_mayor.pdf', 'ejercicios_complementarios.pdf'],
    };
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

  @override
  Widget build(BuildContext context) {
    final taskData = _getMockTaskData();
    final status = taskData['status'] as String;
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(context, status);
    final isTeacher = AuthWrapper.mockRole == 'teacher';

    return Scaffold(
      appBar: const CustomAppBar(title: TaskStrings.taskDetailTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información principal
            CustomCard(
              title: taskData['title'] as String,
              subtitle: taskData['description'] as String,
              trailingAction: Chip(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: TaskStrings.estimatedTime,
                    value:
                        '${taskData['estimatedTime']} ${TaskStrings.minutes}',
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: TaskStrings.createdDate,
                    value: taskData['createdDate'] as String,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _InfoRow(
                    icon: Icons.event,
                    label: TaskStrings.dueDate,
                    value: taskData['dueDate'] as String,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            // Destinatarios
            CustomCard(
              title: TaskStrings.recipients,
              subtitle:
                  '${(taskData['recipients'] as List).length} ${TaskStrings.studentsLabel}',
              child: (taskData['recipients'] as List).isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Text(
                        TaskStrings.noRecipients,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (taskData['recipients'] as List).map<Widget>((
                        recipient,
                      ) {
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            child: Text(
                              (recipient['name'] as String)[0].toUpperCase(),
                            ),
                          ),
                          title: Text(recipient['name'] as String),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: AppSpacing.m),
            // Adjuntos
            CustomCard(
              title: TaskStrings.attachments,
              subtitle: '${(taskData['attachments'] as List).length} archivos',
              child: (taskData['attachments'] as List).isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Text(
                        TaskStrings.noAttachments,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (taskData['attachments'] as List).map<Widget>((
                        attachment,
                      ) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(attachment as String),
                          trailing: IconButton(
                            icon: const Icon(Icons.download_outlined),
                            onPressed: () {
                              // Placeholder: descargar adjunto
                            },
                            tooltip: CommonStrings.download,
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Acciones según rol
            if (isTeacher) ...[
              CustomButton(
                label: TaskStrings.editTask,
                variant: CustomButtonVariant.filled,
                icon: Icons.edit,
                onPressed: () {
                  // Placeholder: editar tarea
                },
              ),
              const SizedBox(height: AppSpacing.m),
              CustomButton(
                label: TaskStrings.assignTask,
                variant: CustomButtonVariant.outlined,
                icon: Icons.person_add,
                onPressed: () {
                  // Placeholder: asignar tarea
                },
              ),
              const SizedBox(height: AppSpacing.m),
              OutlinedButton.icon(
                onPressed: () {
                  // Placeholder: eliminar tarea
                  context.pop();
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: context.colorScheme.error,
                ),
                label: Text(
                  TaskStrings.deleteTask,
                  style: TextStyle(color: context.colorScheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colorScheme.error,
                ),
              ),
            ] else ...[
              if (status != 'completed')
                CustomButton(
                  label: TaskStrings.startTimer,
                  variant: CustomButtonVariant.filled,
                  icon: Icons.play_arrow,
                  onPressed: () => context.push(
                    AppRoutes.timer.replaceAll(':taskId', taskId),
                  ),
                ),
              const SizedBox(height: AppSpacing.m),
              CustomButton(
                label: TaskStrings.viewDetails,
                variant: CustomButtonVariant.outlined,
                icon: Icons.info_outline,
                onPressed: () {
                  // Placeholder: ver más detalles
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar una fila de información
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.s),
        Text(
          '$label: ',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

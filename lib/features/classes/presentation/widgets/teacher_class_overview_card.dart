import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/classes/domain/models/class_model.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Tarjeta reutilizable que muestra el resumen principal de una clase.
class TeacherClassOverviewCard extends StatelessWidget {
  const TeacherClassOverviewCard({
    super.key,
    required this.classModel,
    required this.onCopyCode,
    required this.onRegenerateCode,
    this.studentsCount,
    this.activeTasksCount,
    this.showStudentsHint = true,
  });

  final ClassModel classModel;
  final void Function(String code) onCopyCode;
  final Future<void> Function() onRegenerateCode;
  final int? studentsCount;
  final int? activeTasksCount;
  final bool showStudentsHint;

  @override
  Widget build(BuildContext context) {
    final isActive = classModel.canJoin;
    final statusLabel = isActive
        ? context.l10n.classStatusActive
        : context.l10n.classStatusArchived;
    final statusColor = isActive
        ? context.colorScheme.primary
        : context.colorScheme.outline;
    final createdAt = DateFormat(
      'dd/MM/yyyy',
    ).format(classModel.createdAt.toDate());
    final studentsLabel = studentsCount != null
        ? context.l10n.studentsCount(studentsCount!)
        : null;
    final tasksLabel = activeTasksCount != null
        ? context.l10n.tasksCount(activeTasksCount!)
        : null;

    final textTheme = Theme.of(context).textTheme;

    final card = CustomCard(
      title: classModel.name,
      subtitle: classModel.description ?? '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            children: [
              Chip(
                label: Text(statusLabel),
                backgroundColor: statusColor.withValues(alpha: 0.12),
                labelStyle: textTheme.bodySmall?.copyWith(color: statusColor),
              ),
              Chip(
                avatar: const Icon(Icons.event, size: 16),
                label: Text('${context.l10n.createdDateLabel}: $createdAt'),
                labelStyle: textTheme.bodySmall,
              ),
              if (studentsLabel != null)
                Chip(
                  avatar: const Icon(Icons.people_alt_rounded, size: 16),
                  label: Text(studentsLabel),
                  labelStyle: textTheme.bodySmall,
                ),
              if (tasksLabel != null)
                Chip(
                  avatar: const Icon(Icons.assignment_turned_in, size: 16),
                  label: Text(tasksLabel),
                  labelStyle: textTheme.bodySmall,
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.l10n.accessCodeLabel}: ${classModel.accessCode}',
                  style: textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined),
                tooltip: context.l10n.copy,
                onPressed: () => onCopyCode(classModel.accessCode),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: context.l10n.regenerateAccessCodeAction,
                onPressed: onRegenerateCode,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          if (showStudentsHint)
            Text(
              context.l10n.studentsJoinWithCode,
              style: textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );

    if (isActive) {
      return card;
    }
    return Opacity(opacity: 0.7, child: card);
  }
}

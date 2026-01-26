import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Tab de estudiantes de la clase (para docente)
///
/// Muestra todos los estudiantes de la clase con sus estadísticas y acciones.
/// Sprint 0 - Fase 7: UI completa con Material Design 3
class ClassStudentsTab extends StatelessWidget {
  final String classId;

  const ClassStudentsTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    // Datos mock de estudiantes
    final mockStudents = [
      {'id': 'student1', 'name': 'Juan Pérez', 'sessions': 12, 'hours': 8.5},
      {'id': 'student2', 'name': 'María García', 'sessions': 15, 'hours': 12.0},
      {'id': 'student3', 'name': 'Carlos López', 'sessions': 8, 'hours': 5.5},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.studentsTab, // O studentsTitle
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.m),
          if (mockStudents.isEmpty)
            _EmptyStudentsState(
              icon: Icons.person_outline,
              title: context.l10n.studentsTab, // O noStudentsInClass
              subtitle: context.l10n.studentsJoinWithCode,
              actionLabel: context.l10n.close,
              onAction: () => context.pop(),
            )
          else
            ...mockStudents.map((studentData) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: CustomCard(
                  title: studentData['name'] as String,
                  subtitle:
                      '${context.l10n.sessionsCount(studentData['sessions'] as int)} - ${studentData['hours']} ${context.l10n.hoursCount(1)}', // O similar
                  trailingAction: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person_outline),
                        onPressed: () {
                          // Placeholder: ver perfil del estudiante
                        },
                        tooltip: context.l10n.infoTab, // O viewProfile
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          // Placeholder: eliminar estudiante
                        },
                        tooltip: context.l10n.removeStudent,
                        color: context.colorScheme.error,
                      ),
                    ],
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

/// Widget para mostrar estado vacío en tabs de estudiantes
class _EmptyStudentsState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyStudentsState({
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
            icon: const Icon(Icons.close),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

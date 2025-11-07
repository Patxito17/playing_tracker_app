import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla para gestionar alumnos de una clase
///
/// Permite al docente ver y gestionar los estudiantes de una clase.
/// Sprint 0 - Fase 7: UI completa con Material Design 3
class ManageStudentsScreen extends StatelessWidget {
  final String classId;

  const ManageStudentsScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    // Datos mock de estudiantes
    final mockStudents = [
      {
        'id': 'student1',
        'name': 'Juan Pérez',
        'email': 'juan.perez@ejemplo.com',
        'sessions': 12,
        'hours': 8.5,
      },
      {
        'id': 'student2',
        'name': 'María García',
        'email': 'maria.garcia@ejemplo.com',
        'sessions': 15,
        'hours': 12.0,
      },
      {
        'id': 'student3',
        'name': 'Carlos López',
        'email': 'carlos.lopez@ejemplo.com',
        'sessions': 8,
        'hours': 5.5,
      },
    ];

    return Scaffold(
      appBar: const CustomAppBar(title: ClassDetailStrings.manageStudentsTitle),
      body: mockStudents.isEmpty
          ? Center(
              child: _EmptyManageStudentsState(
                icon: Icons.person_outline,
                title: StudentStrings.noStudentsInClass,
                subtitle: StudentStrings.studentsJoinWithCode,
                actionLabel: CommonStrings.close,
                onAction: () => Navigator.of(context).pop(),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: mockStudents.length,
              itemBuilder: (context, index) {
                final student = mockStudents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: CustomCard(
                    title: student['name'] as String,
                    subtitle: student['email'] as String,
                    trailingAction: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_outline),
                          onPressed: () {
                            // Placeholder: ver perfil del estudiante
                          },
                          tooltip: StudentStrings.viewProfile,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            // Placeholder: eliminar estudiante
                          },
                          tooltip: StudentStrings.removeStudent,
                          color: context.colorScheme.error,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '${student['sessions']} ${StudentStrings.sessionsHours} ${student['hours']} ${StudentStrings.hours}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Widget para mostrar estado vacío en gestión de estudiantes
class _EmptyManageStudentsState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyManageStudentsState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
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
            icon: const Icon(Icons.close),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

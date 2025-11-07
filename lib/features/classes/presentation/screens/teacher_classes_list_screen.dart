import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla de lista de clases creadas por el docente
///
/// Muestra todas las clases creadas por el docente con Material Design 3.
/// El BottomNavigationBar se maneja mediante ShellRoute en app_routes.dart.
///
/// Sprint 0 - Fase 6: UI completa implementada con Material Design 3
class TeacherClassesListScreen extends StatelessWidget {
  const TeacherClassesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos mock de clases
    final mockClasses = [
      {'id': 'class1', 'name': 'Piano Nivel 1', 'students': 12},
      {'id': 'class2', 'name': 'Guitarra Avanzada', 'students': 8},
      {'id': 'class3', 'name': 'Violín Inicial', 'students': 15},
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: ClassesStrings.myClassesTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go(AppRoutes.createClass),
            tooltip: ClassesStrings.createNewClass,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Mock: simular refresh
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título de sección
              Text(
                ClassesStrings.classesCreatedTitle,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Lista de clases o estado vacío
              if (mockClasses.isEmpty)
                _EmptyState(
                  icon: Icons.class_outlined,
                  title: ClassesStrings.noClassesCreated,
                  subtitle: ClassesStrings.createFirstClass,
                  actionLabel: ClassesStrings.createClass,
                  onAction: () => context.go(AppRoutes.createClass),
                )
              else
                ...mockClasses.map((classData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: CustomCard(
                      title: classData['name'] as String,
                      subtitle:
                          '${classData['students']} ${ClassesStrings.studentsCount}',
                      onTap: () => context.push(
                        '${AppRoutes.teacherClassDetail}/${classData['id']}',
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.class_,
                            color: context.colorScheme.primary,
                            size: 24,
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      // BottomNavigationBar se maneja mediante ShellRoute en app_routes.dart
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.createClass),
        icon: const Icon(Icons.add),
        label: Text(ClassesStrings.createClass),
      ),
    );
  }
}

/// Widget para mostrar estado vacío
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
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

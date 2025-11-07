import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../config/routes/app_routes.dart';

/// Pantalla de lista de clases a las que pertenece el estudiante
///
/// Muestra todas las clases a las que pertenece el estudiante con Material Design 3.
/// El BottomNavigationBar se maneja mediante ShellRoute en app_routes.dart.
///
/// Sprint 0 - Fase 6: UI completa implementada con Material Design 3
class StudentClassesListScreen extends StatelessWidget {
  const StudentClassesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos mock de clases
    final mockClasses = [
      {'id': 'class1', 'name': 'Piano Nivel 1', 'teacher': 'Prof. García'},
      {'id': 'class2', 'name': 'Guitarra Avanzada', 'teacher': 'Prof. López'},
      {'id': 'class3', 'name': 'Violín Inicial', 'teacher': 'Prof. Martínez'},
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: ClassesStrings.myClassesTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.joinClass),
            tooltip: ClassesStrings.joinClass,
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
                ClassesStrings.classesTitle,
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
                  title: ClassesStrings.noClassesJoined,
                  subtitle: ClassesStrings.joinClassWithCode,
                  actionLabel: ClassesStrings.joinClassAction,
                  onAction: () => context.push(AppRoutes.joinClass),
                )
              else
                ...mockClasses.map((classData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: CustomCard(
                      title: classData['name'] as String,
                      subtitle:
                          '${ClassesStrings.teacherLabel}${classData['teacher']}',
                      onTap: () => context.push(
                        '${AppRoutes.studentClassDetail}/${classData['id']}',
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
        onPressed: () => context.push(AppRoutes.joinClass),
        icon: const Icon(Icons.add),
        label: Text(ClassesStrings.joinClassAction),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../config/routes/app_routes.dart';

/// Tab de tareas de la clase (para docente)
///
/// Muestra todas las tareas de la clase con opción para crear nuevas.
/// Placeholder para Sprint 0 - Fase 7.
class ClassTasksTab extends StatelessWidget {
  final String classId;

  const ClassTasksTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    // Datos mock de tareas
    final mockTasks = [
      {'id': 'task1', 'title': 'Escala de Do Mayor', 'assignedTo': 12},
      {'id': 'task2', 'title': 'Arpegios de Do Menor', 'assignedTo': 8},
      {'id': 'task3', 'title': 'Ejercicio de velocidad', 'assignedTo': 15},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
            label: 'Crear Nueva Tarea',
            variant: CustomButtonVariant.filled,
            icon: Icons.add,
            onPressed: () => context.go(AppRoutes.createTask),
          ),
          const SizedBox(height: AppSpacing.m),
          if (mockTasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'No hay tareas en esta clase',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Crea tu primera tarea para comenzar',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ...mockTasks.map((taskData) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: CustomCard(
                  title: taskData['title'] as String,
                  subtitle: 'Asignada a ${taskData['assignedTo']} estudiantes',
                  onTap: () => context.go(
                    AppRoutes.taskDetail.replaceAll(
                      ':taskId',
                      taskData['id'] as String,
                    ),
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

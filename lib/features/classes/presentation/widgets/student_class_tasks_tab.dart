import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../config/routes/app_routes.dart';

/// Tab de tareas de la clase (para estudiante)
///
/// Muestra todas las tareas asignadas al estudiante con opción para iniciar sesión de estudio.
/// Placeholder para Sprint 0 - Fase 7.
class StudentClassTasksTab extends StatelessWidget {
  final String classId;

  const StudentClassTasksTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    // Datos mock de tareas
    final mockTasks = [
      {'id': 'task1', 'title': 'Escala de Do Mayor', 'status': 'pending'},
      {'id': 'task2', 'title': 'Arpegios de Do Menor', 'status': 'in_progress'},
      {'id': 'task3', 'title': 'Ejercicio de velocidad', 'status': 'completed'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                      'No hay tareas asignadas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Espera a que tu profesor asigne tareas',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ...mockTasks.map((taskData) {
              final status = taskData['status'] as String;
              final statusText = status == 'pending'
                  ? 'Pendiente'
                  : status == 'in_progress'
                  ? 'En progreso'
                  : 'Completada';

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: CustomCard(
                  title: taskData['title'] as String,
                  subtitle: 'Estado: $statusText',
                  child: CustomButton(
                    label: status == 'completed'
                        ? 'Ver Detalles'
                        : 'Iniciar Sesión de Estudio',
                    variant: status == 'completed'
                        ? CustomButtonVariant.outlined
                        : CustomButtonVariant.filled,
                    onPressed: () {
                      if (status == 'completed') {
                        context.go(
                          AppRoutes.taskDetail.replaceAll(
                            ':taskId',
                            taskData['id'] as String,
                          ),
                        );
                      } else {
                        context.go(
                          AppRoutes.timer.replaceAll(
                            ':taskId',
                            taskData['id'] as String,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

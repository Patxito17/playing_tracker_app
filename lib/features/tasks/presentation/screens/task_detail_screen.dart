import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/navigation_helper.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla de detalle de tarea (Placeholder - Sprint 0)
///
/// Esta es una pantalla placeholder simple para probar la navegación.
/// La UI completa se implementará en Sprint 0 - Fase 8.
class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalle de Tarea'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomCard(
                    title: 'Tarea: $taskId',
                    subtitle: 'Descripción detallada de la tarea',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información de la Tarea',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text('Tiempo estimado: 30 minutos'),
                        const SizedBox(height: AppSpacing.s),
                        Text('Estado: Pendiente'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  CustomButton(
                    label: 'Iniciar Cronómetro',
                    variant: CustomButtonVariant.filled,
                    onPressed: () => context.go('/timer/$taskId'),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  CustomButton(
                    label: 'Volver a Tareas',
                    variant: CustomButtonVariant.outlined,
                    onPressed: () => context.go('/tasks'),
                  ),
                ],
              ),
            ),
          ),
          const NavigationHelper(),
        ],
      ),
    );
  }
}

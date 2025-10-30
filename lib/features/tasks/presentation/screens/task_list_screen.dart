import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/navigation_helper.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla de lista de tareas (Placeholder - Sprint 0)
///
/// Esta es una pantalla placeholder simple para probar la navegación.
/// La UI completa se implementará en Sprint 0 - Fase 8.
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Mis Tareas'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  CustomButton(
                    label: 'Crear Nueva Tarea',
                    variant: CustomButtonVariant.filled,
                    onPressed: () => context.go('/tasks/create'),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return CustomCard(
                          title: 'Tarea ${index + 1}',
                          subtitle: 'Descripción de la tarea ${index + 1}',
                          onTap: () => context.go('/tasks/task${index + 1}'),
                          child: const SizedBox.shrink(),
                        );
                      },
                    ),
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

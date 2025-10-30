import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/navigation_helper.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla de cronómetro (Placeholder - Sprint 0)
///
/// Esta es una pantalla placeholder simple para probar la navegación.
/// La UI completa se implementará en Sprint 0 - Fase 9.
class TimerScreen extends StatelessWidget {
  final String taskId;

  const TimerScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Cronómetro'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomCard(
                    title: 'Tarea: $taskId',
                    child: Column(
                      children: [
                        Text(
                          '00:00:00',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: AppSpacing.l),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              label: 'Iniciar',
                              variant: CustomButtonVariant.filled,
                              onPressed: () {},
                            ),
                            const SizedBox(width: AppSpacing.s),
                            CustomButton(
                              label: 'Pausar',
                              variant: CustomButtonVariant.outlined,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  CustomButton(
                    label: 'Finalizar Sesión',
                    variant: CustomButtonVariant.filled,
                    onPressed: () => context.go('/tasks/$taskId'),
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

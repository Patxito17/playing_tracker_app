import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/navigation_helper.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla para unirse a una clase (Placeholder - Sprint 0)
///
/// Esta es una pantalla placeholder simple para probar la navegación.
/// La UI completa se implementará en Sprint 0 - Fase 7.
class JoinClassScreen extends StatelessWidget {
  const JoinClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Unirse a Clase'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Unirse a una Clase',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const CustomTextField(
                    label: 'Código de Acceso',
                    hint: 'Ingresa el código de la clase',
                  ),
                  const SizedBox(height: AppSpacing.l),
                  CustomButton(
                    label: 'Unirse',
                    variant: CustomButtonVariant.filled,
                    onPressed: () {
                      // Placeholder: navegar de vuelta
                      context.go('/home/student');
                    },
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

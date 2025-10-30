import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/navigation_helper.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla para crear una clase (Placeholder - Sprint 0)
///
/// Esta es una pantalla placeholder simple para probar la navegación.
/// La UI completa se implementará en Sprint 0 - Fase 7.
class CreateClassScreen extends StatelessWidget {
  const CreateClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Crear Clase'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  Text(
                    'Crear Nueva Clase',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const CustomTextField(
                    label: 'Nombre de la Clase',
                    hint: 'Ej: Piano Nivel 1',
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const CustomTextField(
                    label: 'Descripción',
                    hint: 'Descripción de la clase',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  CustomButton(
                    label: 'Crear Clase',
                    variant: CustomButtonVariant.filled,
                    onPressed: () {
                      // Placeholder: navegar de vuelta
                      context.go('/home/teacher');
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

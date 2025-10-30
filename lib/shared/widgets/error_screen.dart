import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import 'custom_app_bar.dart';
import 'custom_button.dart';

/// Pantalla de error para rutas no encontradas (404)
///
/// Se muestra cuando el usuario intenta acceder a una ruta que no existe.
class ErrorScreen extends StatelessWidget {
  final String? errorMessage;

  const ErrorScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Error'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppSpacing.l),
            CustomButton(
              label: 'Volver al Inicio',
              variant: CustomButtonVariant.filled,
              onPressed: () => context.go('/'),
            ),
            const SizedBox(height: AppSpacing.s),
            CustomButton(
              label: 'Ir a Login',
              variant: CustomButtonVariant.outlined,
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}

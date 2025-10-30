import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/navigation_helper.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla de registro (Placeholder - Sprint 0)
///
/// Esta es una pantalla placeholder simple para probar la navegación.
/// La UI completa se implementará en Sprint 0 - Fase 5.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Registro'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pantalla de Registro',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const CustomTextField(
                    label: 'Nombre',
                    hint: 'Ingresa tu nombre',
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const CustomTextField(
                    label: 'Email',
                    hint: 'usuario@ejemplo.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const CustomTextField(label: 'Contraseña', obscureText: true),
                  const SizedBox(height: AppSpacing.m),
                  const CustomTextField(
                    label: 'Repetir Contraseña',
                    obscureText: true,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  CustomButton(
                    label: 'Registrarse',
                    variant: CustomButtonVariant.filled,
                    onPressed: () {
                      // Placeholder: solo navegar
                      context.go('/login');
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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

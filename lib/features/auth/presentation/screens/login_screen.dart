import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/navigation_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/auth_wrapper.dart';

/// Pantalla de inicio de sesión (Placeholder - Sprint 0)
///
/// Esta es una pantalla placeholder simple para probar la navegación.
/// La UI completa se implementará en Sprint 0 - Fase 5.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Iniciar Sesión'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pantalla de Login',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const CustomTextField(
                    label: 'Email',
                    hint: 'usuario@ejemplo.com',
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const CustomTextField(label: 'Contraseña', obscureText: true),
                  const SizedBox(height: AppSpacing.l),
                  CustomButton(
                    label: 'Iniciar Sesión',
                    variant: CustomButtonVariant.filled,
                    onPressed: () {
                      // Mock: establecer rol como teacher para probar navegación
                      AuthWrapper.mockRole = 'teacher';
                      context.go('/home/teacher');
                    },
                  ),
                  const SizedBox(height: AppSpacing.s),
                  CustomButton(
                    label: 'Iniciar como Alumno (Mock)',
                    variant: CustomButtonVariant.outlined,
                    onPressed: () {
                      // Mock: establecer rol como student para probar navegación
                      AuthWrapper.mockRole = 'student';
                      context.go('/home/student');
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('¿No tienes cuenta? Regístrate'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: const Text('¿Olvidaste tu contraseña?'),
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

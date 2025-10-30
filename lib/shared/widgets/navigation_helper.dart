import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/presentation/widgets/auth_wrapper.dart';
import 'custom_button.dart';

/// Widget helper para facilitar la navegación durante las pruebas
///
/// Muestra botones de navegación rápida para volver a pantallas principales
/// y gestionar el rol mock. Solo debe usarse en pantallas placeholder.
///
/// **Ejemplo de uso:**
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       YourContent(),
///       const NavigationHelper(),
///     ],
///   ),
/// )
/// ```
class NavigationHelper extends StatelessWidget {
  const NavigationHelper({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    final currentRole = AuthWrapper.mockRole;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Navegación de Prueba',
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            alignment: WrapAlignment.center,
            children: [
              if (canPop)
                CustomButton(
                  label: '← Volver',
                  variant: CustomButtonVariant.outlined,
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                ),
              CustomButton(
                label: 'Login',
                variant: CustomButtonVariant.text,
                onPressed: () {
                  AuthWrapper.mockRole = null;
                  context.go('/login');
                },
              ),
              if (currentRole != 'teacher')
                CustomButton(
                  label: 'Home Docente',
                  variant: CustomButtonVariant.text,
                  onPressed: () {
                    AuthWrapper.mockRole = 'teacher';
                    context.go('/home/teacher');
                  },
                ),
              if (currentRole != 'student')
                CustomButton(
                  label: 'Home Alumno',
                  variant: CustomButtonVariant.text,
                  onPressed: () {
                    AuthWrapper.mockRole = 'student';
                    context.go('/home/student');
                  },
                ),
              CustomButton(
                label: 'Limpiar Rol',
                variant: CustomButtonVariant.text,
                onPressed: () {
                  AuthWrapper.mockRole = null;
                  context.go('/login');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Pantalla de inicio para alumnos
///
/// Redirige automáticamente a la lista de clases del estudiante.
/// Muestra un indicador de carga con Material Design 3 mientras redirige.
///
/// Sprint 0 - Fase 6: UI mejorada con Material Design 3
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirigir automáticamente a la lista de clases
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(AppRoutes.studentClassesList);
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              CommonStrings.loading,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

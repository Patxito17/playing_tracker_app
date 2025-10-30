import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';

/// Pantalla de inicio para alumnos (Placeholder - Sprint 0)
///
/// Redirige automáticamente a la lista de clases del estudiante.
/// La UI completa se implementará en Sprint 0 - Fase 6.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirigir automáticamente a la lista de clases
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(AppRoutes.studentClassesList);
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

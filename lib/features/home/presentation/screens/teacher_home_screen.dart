import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';

/// Pantalla de inicio para docentes (Placeholder - Sprint 0)
///
/// Redirige automáticamente a la lista de clases del docente.
/// La UI completa se implementará en Sprint 0 - Fase 6.
class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirigir automáticamente a la lista de clases
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(AppRoutes.teacherClassesList);
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

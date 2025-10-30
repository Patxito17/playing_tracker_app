import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../core/constants/app_constants.dart';

/// Tab de estadísticas de la clase (común para docente y estudiante)
///
/// Muestra estadísticas agregadas de la clase.
/// Para docente: estadísticas de todos los estudiantes.
/// Para estudiante: estadísticas individuales.
/// Placeholder para Sprint 0 - Fase 7.
class ClassStatisticsTab extends StatelessWidget {
  final String classId;
  final bool isTeacher;

  const ClassStatisticsTab({
    super.key,
    required this.classId,
    this.isTeacher = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isTeacher ? 'Estadísticas de la Clase' : 'Mis Estadísticas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.l),
          CustomCard(
            title: 'Tiempo Total',
            subtitle: isTeacher
                ? 'Tiempo total de todos los estudiantes'
                : 'Tiempo total de estudio',
            child: Text(
              '0 horas',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          CustomCard(
            title: isTeacher ? 'Sesiones Totales' : 'Mis Sesiones',
            subtitle: isTeacher
                ? 'Total de sesiones de todos los estudiantes'
                : 'Total de sesiones completadas',
            child: Text(
              '0 sesiones',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (isTeacher)
            CustomCard(
              title: 'Estudiantes Activos',
              subtitle: 'Estudiantes con actividad esta semana',
              child: Text(
                '0 estudiantes',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
        ],
      ),
    );
  }
}

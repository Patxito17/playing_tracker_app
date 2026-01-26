import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../statistics/presentation/widgets/app_bar_chart.dart';
import '../../../statistics/presentation/widgets/app_pie_chart.dart';
import '../../../statistics/presentation/widgets/app_progress_chart.dart';

/// Tab de estadísticas de la clase (común para docente y estudiante)
///
/// Muestra estadísticas agregadas de la clase.
/// Para docente: estadísticas de todos los estudiantes.
/// Para estudiante: estadísticas individuales.
/// Sprint 6 Fase 2: Integración de gráficos reales para verificación manual.
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
            isTeacher
                ? ClassDetailStrings.classStatisticsTitle
                : ClassDetailStrings.myStatisticsTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.l),
          CustomCard(
            title: ClassDetailStrings.totalTime,
            subtitle: isTeacher
                ? ClassDetailStrings.totalTimeDescription
                : ClassDetailStrings.myTotalTimeDescription,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '12 horas',
                  style: context.textTheme.headlineLarge?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                const AppBarChart(
                  height: 150,
                  data: [
                    (label: 'Sem 1', value: 120),
                    (label: 'Sem 2', value: 180),
                    (label: 'Sem 3', value: 150),
                    (label: 'Sem 4', value: 210),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          CustomCard(
            title: isTeacher
                ? ClassDetailStrings.totalSessions
                : ClassDetailStrings.mySessions,
            subtitle: isTeacher
                ? ClassDetailStrings.totalSessionsDescription
                : ClassDetailStrings.mySessionsDescription,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24 sesiones',
                  style: context.textTheme.headlineLarge?.copyWith(
                    color: context.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                const AppPieChart(
                  radius: 70,
                  data: [
                    (label: 'Completadas', value: 18, color: Colors.green),
                    (label: 'En curso', value: 6, color: Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (isTeacher)
            CustomCard(
              title: ClassDetailStrings.activeStudents,
              subtitle: ClassDetailStrings.activeStudentsDescription,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '15 estudiantes',
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: context.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const Center(
                    child: AppProgressChart(
                      progress: 0.85,
                      size: 120,
                      strokeWidth: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

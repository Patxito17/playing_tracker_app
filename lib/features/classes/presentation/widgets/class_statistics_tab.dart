import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Tab de estadísticas de la clase (común para docente y estudiante)
///
/// Muestra estadísticas agregadas de la clase.
/// Para docente: estadísticas de todos los estudiantes.
/// Para estudiante: estadísticas individuales.
/// Sprint 0 - Fase 7: UI completa con Material Design 3 y gráficos placeholder
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
                  '0 horas',
                  style: context.textTheme.headlineLarge?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                // Gráfico placeholder
                _ChartPlaceholder(
                  height: 100,
                  color: context.colorScheme.primary,
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
                  '0 sesiones',
                  style: context.textTheme.headlineLarge?.copyWith(
                    color: context.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                // Gráfico placeholder
                _ChartPlaceholder(
                  height: 100,
                  color: context.colorScheme.secondary,
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
                    '0 estudiantes',
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: context.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Gráfico placeholder
                  _ChartPlaceholder(
                    height: 100,
                    color: context.colorScheme.tertiary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget placeholder para gráficos
class _ChartPlaceholder extends StatelessWidget {
  final double height;
  final Color color;

  const _ChartPlaceholder({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.bar_chart,
          size: 48,
          color: color.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

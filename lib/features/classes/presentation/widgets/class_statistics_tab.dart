import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../statistics/presentation/cubit/student_stats_cubit.dart';
import '../../../statistics/presentation/cubit/student_stats_state.dart';
import '../../../statistics/presentation/widgets/app_bar_chart.dart';
import '../../../statistics/presentation/widgets/app_pie_chart.dart';
import '../../../statistics/presentation/widgets/app_progress_chart.dart';

/// Tab de estadísticas de la clase (común para docente y estudiante)
///
/// Muestra estadísticas agregadas de la clase.
/// Para docente: estadísticas de todos los estudiantes.
/// Para estudiante: estadísticas individuales dentro de esta clase.
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
    if (isTeacher) {
      return _buildTeacherMock(context);
    }

    return BlocBuilder<StudentStatsCubit, StudentStatsState>(
      builder: (context, state) {
        return switch (state) {
          StudentStatsInitial() || StudentStatsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          StudentStatsError(:final message) => Center(child: Text(message)),
          StudentStatsLoaded(:final weeklyStats) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ClassDetailStrings.myStatisticsTitle,
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.l),
                CustomCard(
                  title: ClassDetailStrings.totalTime,
                  subtitle: ClassDetailStrings.myTotalTimeDescription,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weeklyStats.durationFormatted,
                        style: context.textTheme.headlineLarge?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppBarChart(
                        height: 150,
                        data: weeklyStats.dailyBreakdown
                            .map(
                              (day) => (
                                label: _getDayLabel(day.date.toDate()),
                                value: (day.totalDuration / 60).toDouble(),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                CustomCard(
                  title: ClassDetailStrings.mySessions,
                  subtitle: ClassDetailStrings.mySessionsDescription,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weeklyStats.totalSessions} sesiones',
                        style: context.textTheme.headlineLarge?.copyWith(
                          color: context.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      if (weeklyStats.taskBreakdown.isNotEmpty)
                        AppPieChart(
                          radius: 70,
                          data: weeklyStats.taskBreakdown
                              .map(
                                (task) => (
                                  label: task.taskTitle,
                                  value: task.totalDuration.toDouble(),
                                  color: null,
                                ),
                              )
                              .toList(),
                        )
                      else
                        const Center(child: Text('Sin datos de tareas')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        };
      },
    );
  }

  String _getDayLabel(DateTime date) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[date.weekday - 1];
  }

  /// Mock para la vista de docente (Fase 4)
  Widget _buildTeacherMock(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ClassDetailStrings.classStatisticsTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.l),
          CustomCard(
            title: ClassDetailStrings.totalTime,
            subtitle: ClassDetailStrings.totalTimeDescription,
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
            title: ClassDetailStrings.totalSessions,
            subtitle: ClassDetailStrings.totalSessionsDescription,
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

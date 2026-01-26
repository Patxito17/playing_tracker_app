import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../statistics/presentation/cubit/student_stats_cubit.dart';
import '../../../statistics/presentation/cubit/student_stats_state.dart';
import '../../../statistics/presentation/cubit/teacher_stats_cubit.dart';
import '../../../statistics/presentation/cubit/teacher_stats_state.dart';
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
      return BlocBuilder<TeacherStatsCubit, TeacherStatsState>(
        builder: (context, state) {
          return switch (state) {
            TeacherStatsInitial() || TeacherStatsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TeacherStatsError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Text(message, textAlign: TextAlign.center),
              ),
            ),
            TeacherStatsLoaded(:final classStats) => RefreshIndicator(
              onRefresh: () {
                final authState = context.read<AuthCubit>().state;
                final teacherId = authState is AuthAuthenticated
                    ? authState.userId
                    : '';
                return context.read<TeacherStatsCubit>().refreshClassStats(
                  classId: classId,
                  teacherId: teacherId,
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.classStatisticsTitle,
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    CustomCard(
                      title: context.l10n.totalTime,
                      subtitle: context.l10n.totalTimeDescription,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classStats.durationFormatted,
                            style: context.textTheme.headlineLarge?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          // Aquí podríamos poner un gráfico de barras si tuviéramos dailyBreakdown por clase,
                          // por ahora mostramos el resumen destacado.
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.medium,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: context.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: AppSpacing.s),
                                Text(
                                  '${context.l10n.averageDurationLabel}: ${classStats.averageDurationPerStudentFormatted}',
                                  style: context.bodyMediumOnSurfaceVariant
                                      ?.copyWith(
                                        color: context
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    CustomCard(
                      title: context.l10n.totalSessions,
                      subtitle: context.l10n.totalSessions, // O similar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.sessionsCount(
                              classStats.totalSessions,
                            ),
                            style: context.textTheme.headlineLarge?.copyWith(
                              color: context.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          if (classStats.taskBreakdown.isNotEmpty)
                            AppPieChart(
                              radius: 70,
                              data: classStats.taskBreakdown
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
                    const SizedBox(height: AppSpacing.m),
                    CustomCard(
                      title: context.l10n.activeStudents,
                      subtitle: context.l10n.activeStudents, // O similar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.activeStudentsCount(
                              classStats.activeStudents,
                            ),
                            style: context.textTheme.headlineLarge?.copyWith(
                              color: context.colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            'De un total de ${context.l10n.studentsCount(classStats.totalStudents)}',
                            style: context.bodySmallOnSurfaceVariant,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Center(
                            child: AppProgressChart(
                              progress:
                                  classStats.activeStudentsPercentage / 100,
                              size: 120,
                              strokeWidth: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Desglose detallado por tareas
                    if (classStats.taskBreakdown.isNotEmpty)
                      CustomCard(
                        title: context.l10n.generalOverview,
                        subtitle: context.l10n.generalOverview,
                        child: Column(
                          children: [
                            ...classStats.taskBreakdown.map((task) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.m,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.taskTitle,
                                            style: context.titleMediumBold,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${task.totalSessions} sesiones registradas',
                                            style: context
                                                .bodySmallOnSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.s,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          AppBorderRadius.small,
                                        ),
                                      ),
                                      child: Text(
                                        task.durationFormatted,
                                        style: context
                                            .bodyMediumOnSurfaceVariant
                                            ?.copyWith(
                                              color: context
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          };
        },
      );
    }

    return BlocBuilder<StudentStatsCubit, StudentStatsState>(
      builder: (context, state) {
        return switch (state) {
          StudentStatsInitial() || StudentStatsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          StudentStatsError(:final message) => Center(child: Text(message)),
          StudentStatsLoaded(:final weeklyStats) => RefreshIndicator(
            onRefresh: () {
              final authState = context.read<AuthCubit>().state;
              final studentId = authState is AuthAuthenticated
                  ? authState.userId
                  : '';
              return context.read<StudentStatsCubit>().refreshStats(
                studentId: studentId,
                classId: classId,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.classStatisticsTitle,
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  CustomCard(
                    title: context.l10n.totalTime,
                    subtitle: context.l10n.totalTime, // O totalTimeDescription
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
                    title: context.l10n.totalSessions,
                    subtitle: context
                        .l10n
                        .totalSessions, // O totalSessionsDescription
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.sessionsCount(weeklyStats.totalSessions),
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
          ),
        };
      },
    );
  }

  String _getDayLabel(DateTime date) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[date.weekday - 1];
  }
}

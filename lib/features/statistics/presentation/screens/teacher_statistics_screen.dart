import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_cubit.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_state.dart';
import 'package:playing_tracker/features/statistics/presentation/constants/statistics_strings.dart';
import 'package:playing_tracker/shared/widgets/custom_app_bar.dart';
import 'package:playing_tracker/shared/widgets/custom_card.dart';

/// Pantalla de estadísticas del docente para una clase específica.
///
/// Muestra:
/// - Resumen de actividad de la clase (alumnos activos, tiempo total)
/// - Ranking de alumnos por tiempo de práctica
/// - Identificación de alumnos que necesitan atención
class TeacherStatisticsScreen extends StatelessWidget {
  const TeacherStatisticsScreen({
    super.key,
    required this.classId,
    required this.teacherId,
  });

  final String classId;
  final String teacherId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: StatisticsStrings.classStatisticsTitle),
      body: BlocBuilder<TeacherStatsCubit, TeacherStatsState>(
        builder: (context, state) {
          return switch (state) {
            TeacherStatsInitial() || TeacherStatsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TeacherStatsError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: context.colorScheme.error,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    StatisticsStrings.loadingError,
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    message,
                    style: context.bodySmallOnSurfaceVariant,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  FilledButton.tonal(
                    onPressed: () =>
                        context.read<TeacherStatsCubit>().refreshClassStats(
                          classId: classId,
                          teacherId: teacherId,
                        ),
                    child: Text(CommonStrings.retry),
                  ),
                ],
              ),
            ),
            TeacherStatsLoaded(:final classStats) => RefreshIndicator(
              onRefresh: () => context
                  .read<TeacherStatsCubit>()
                  .refreshClassStats(classId: classId, teacherId: teacherId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Resumen general de la clase
                    CustomCard(
                      title: classStats.className,
                      subtitle: StatisticsStrings.activitySummary,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                label: StatisticsStrings.students,
                                value: '${classStats.totalStudents}',
                                icon: Icons.people,
                                color: context.colorScheme.primary,
                              ),
                              _StatItem(
                                label: StatisticsStrings.active,
                                value: '${classStats.activeStudents}',
                                subtitle: classStats
                                    .activeStudentsPercentageFormatted,
                                icon: Icons.trending_up,
                                color: context.colorScheme.tertiary,
                              ),
                              _StatItem(
                                label: StatisticsStrings.sessions,
                                value: '${classStats.totalSessions}',
                                icon: Icons.event_note,
                                color: context.colorScheme.secondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.medium,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: context.colorScheme.onPrimaryContainer,
                                  size: 24,
                                ),
                                const SizedBox(width: AppSpacing.s),
                                Text(
                                  '${StatisticsStrings.totalTime}: ${classStats.durationFormatted}',
                                  style: context.titleMediumBold?.copyWith(
                                    color:
                                        context.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Desglose por tareas
                    if (classStats.taskBreakdown.isNotEmpty)
                      CustomCard(
                        title: StatisticsStrings.workedTasks,
                        subtitle: StatisticsStrings.tasksCount(
                          classStats.taskBreakdown.length,
                        ),
                        child: Column(
                          children: classStats.taskBreakdown.map((task) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s,
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
                                          style: context.bodyMediumOnSurface,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          StatisticsStrings.sessionsLabelCount(
                                            task.totalSessions,
                                          ),
                                          style:
                                              context.bodySmallOnSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    task.durationFormatted,
                                    style: context.titleSmallBold?.copyWith(
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          };
        },
      ),
    );
  }
}

/// Widget para mostrar un ítem de estadística
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: context.bodySmallOnSurfaceVariant?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        Text(label, style: context.bodySmallOnSurfaceVariant),
      ],
    );
  }
}

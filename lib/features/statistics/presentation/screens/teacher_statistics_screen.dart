import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_cubit.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_state.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/time_filter_selector.dart';
import 'package:playing_tracker/shared/widgets/custom_app_bar.dart';
import 'package:playing_tracker/shared/widgets/custom_card.dart';

/// Pantalla de estadísticas del docente para una clase específica.
///
/// Muestra:
/// - Filtro temporal avanzado (SegmentedButton)
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
      appBar: CustomAppBar(title: context.l10n.classStatisticsTitle),
      body: BlocBuilder<TeacherStatsCubit, TeacherStatsState>(
        builder: (context, state) {
          final isLoading = state is TeacherStatsLoading;
          final hasData =
              state is TeacherStatsLoaded ||
              (state is TeacherStatsError &&
                  context.read<TeacherStatsCubit>().state
                      is TeacherStatsLoaded);

          return Column(
            children: [
              // Barra de carga superior sutil (evita flicker)
              if (isLoading && hasData)
                const LinearProgressIndicator(minHeight: 2),
              if (!isLoading || !hasData) const SizedBox(height: 2),

              // Filtro Temporal
              TimeFilterSelector(
                currentFilter: state.timeFilter,
                onFilterChanged: (newFilter) {
                  context.read<TeacherStatsCubit>().changeFilter(
                    classId: classId,
                    teacherId: teacherId,
                    newFilter: newFilter,
                  );
                },
              ),

              Expanded(
                child: switch (state) {
                  TeacherStatsInitial() || TeacherStatsLoading()
                      when !hasData =>
                    const Center(child: CircularProgressIndicator()),
                  TeacherStatsError(:final message) when !hasData => Center(
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
                          context.l10n.loadingError,
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
                          onPressed: () => context
                              .read<TeacherStatsCubit>()
                              .refreshClassStats(
                                classId: classId,
                                teacherId: teacherId,
                              ),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                  _ => _StatsContent(
                    classStats: state is TeacherStatsLoaded
                        ? state.classStats
                        : (state as dynamic)
                              .classStats, // Manejo seguro si hay data previa
                    classId: classId,
                    teacherId: teacherId,
                    isLoading: isLoading,
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({
    required this.classStats,
    required this.classId,
    required this.teacherId,
    required this.isLoading,
  });

  final dynamic
  classStats; // Usamos dynamic para simplificar el paso de data previa si existe
  final String classId;
  final String teacherId;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isLoading ? 0.6 : 1.0,
      child: RefreshIndicator(
        onRefresh: () => context.read<TeacherStatsCubit>().refreshClassStats(
          classId: classId,
          teacherId: teacherId,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Resumen general de la clase
              CustomCard(
                title: classStats.className,
                subtitle: context.l10n.activitySummary,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: context.l10n.studentsLabel,
                          value: '${classStats.totalStudents}',
                          icon: Icons.people,
                          color: context.colorScheme.primary,
                        ),
                        _StatItem(
                          label: context.l10n.classStatusActive,
                          value: '${classStats.activeStudents}',
                          subtitle:
                              classStats.activeStudentsPercentageFormatted,
                          icon: Icons.trending_up,
                          color: context.colorScheme.tertiary,
                        ),
                        _StatItem(
                          label: context.l10n
                              .sessionsLabelCount(0)
                              .split(' ')
                              .last,
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
                            '${context.l10n.totalTime}: ${classStats.durationFormatted}',
                            style: context.titleMediumBold?.copyWith(
                              color: context.colorScheme.onPrimaryContainer,
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
                  title: context.l10n.workedTasks,
                  subtitle: context.l10n.tasksCount(
                    classStats.taskBreakdown.length,
                  ),
                  child: Column(
                    children: classStats.taskBreakdown.map<Widget>((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.taskTitle,
                                    style: context.bodyMediumOnSurface,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    context.l10n.sessionsLabelCount(
                                      task.totalSessions,
                                    ),
                                    style: context.bodySmallOnSurfaceVariant,
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

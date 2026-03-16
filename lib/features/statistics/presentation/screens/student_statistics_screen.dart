import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_cubit.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_state.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_bar_chart.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_pie_chart.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_progress_chart.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/stat_metric_tile.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/stats_section_card.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/time_filter_selector.dart';
import 'package:playing_tracker/shared/widgets/custom_app_bar.dart';

/// Pantalla de estadísticas del alumno.
///
/// Muestra un resumen del progreso general y gráficos interactivos:
/// - Progreso hacia el objetivo semanal (gráfico circular)
/// - Tiempo de estudio por día (gráfico de barras)
/// - Distribución de estudio por tarea (gráfico circular)
class StudentStatisticsScreen extends StatelessWidget {
  const StudentStatisticsScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.myStatisticsTitle),
      body: BlocBuilder<StudentStatsCubit, StudentStatsState>(
        builder: (context, state) {
          final isLoading = state is StudentStatsLoading;
          final hasData =
              state is StudentStatsLoaded ||
              (state is StudentStatsError && state.weeklyStats != null) ||
              (state is StudentStatsLoading && state.weeklyStats != null);

          return Column(
            children: [
              if (isLoading && hasData)
                const LinearProgressIndicator(minHeight: 2),
              if (!isLoading || !hasData) const SizedBox(height: 2),

              TimeFilterSelector(
                currentFilter: state.timeFilter,
                onFilterChanged: (newFilter) {
                  context.read<StudentStatsCubit>().changeFilter(
                    studentId: studentId,
                    newFilter: newFilter,
                  );
                },
              ),

              Expanded(
                child: switch (state) {
                  StudentStatsInitial() || StudentStatsLoading()
                      when !hasData =>
                    const Center(child: CircularProgressIndicator()),
                  StudentStatsError(:final message) when !hasData => Center(
                    child: _ErrorState(
                      message: message,
                      onRetry: () => context
                          .read<StudentStatsCubit>()
                          .refreshStats(studentId: studentId),
                    ),
                  ),
                  _ => RefreshIndicator(
                    onRefresh: () => context
                        .read<StudentStatsCubit>()
                        .refreshStats(studentId: studentId),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.m,
                        AppSpacing.m,
                        AppSpacing.m,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_getStats(state) != null)
                            _StudentStatsContent(
                              progress: _getStats(state)!.progress,
                              weeklyStats: _getStats(state)!.weeklyStats,
                            ),
                        ],
                      ),
                    ),
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  ({StudentProgressModel progress, WeeklyStatsModel weeklyStats})? _getStats(
    StudentStatsState state,
  ) {
    if (state is StudentStatsLoaded) {
      return (progress: state.progress, weeklyStats: state.weeklyStats);
    }
    if (state is StudentStatsLoading &&
        state.progress != null &&
        state.weeklyStats != null) {
      return (progress: state.progress!, weeklyStats: state.weeklyStats!);
    }
    if (state is StudentStatsError &&
        state.progress != null &&
        state.weeklyStats != null) {
      return (progress: state.progress!, weeklyStats: state.weeklyStats!);
    }
    return null;
  }
}

String _getDayLabel(DateTime date) {
  const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  return days[date.weekday - 1];
}

class _StudentStatsContent extends StatelessWidget {
  const _StudentStatsContent({
    required this.progress,
    required this.weeklyStats,
  });

  final StudentProgressModel progress;
  final WeeklyStatsModel weeklyStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Resumen general ---
        StatsSectionCard(
          icon: Icons.insights_rounded,
          title: context.l10n.generalSummaryTitle,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatMetricTile(
                    icon: Icons.access_time_rounded,
                    value: progress.durationFormatted,
                    label: context.l10n.totalTime,
                    color: context.colorScheme.primary,
                  ),
                  StatMetricTile(
                    icon: Icons.event_note_rounded,
                    value: '${progress.totalSessions}',
                    label: context.l10n.sessionsLabel,
                    color: context.colorScheme.secondary,
                  ),
                  StatMetricTile(
                    icon: Icons.local_fire_department_rounded,
                    value: context.l10n.daysStreak(progress.currentStreak),
                    label: context.l10n.streakLabel,
                    color: context.colorScheme.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Center(
                child: AppProgressChart(
                  progress: progress.completionPercentage / 100,
                  size: 120,
                  strokeWidth: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),

        // --- Actividad semanal ---
        StatsSectionCard(
          icon: Icons.bar_chart_rounded,
          title: context.l10n.weeklyActivityTitle,
          child: AppBarChart(
            height: 200,
            data: weeklyStats.dailyBreakdown
                .map(
                  (day) => (
                    label: _getDayLabel(day.date.toDate()),
                    value: (day.totalDuration / 60).toDouble(),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.m),

        // --- Distribución por tarea ---
        if (weeklyStats.taskBreakdown.isNotEmpty)
          StatsSectionCard(
            icon: Icons.pie_chart_rounded,
            title: context.l10n.taskDistributionTitle,
            child: AppPieChart(
              radius: 80,
              data: weeklyStats.taskBreakdown
                  .map(
                    (task) => (
                      label: task.taskTitle,
                      value: task.totalDuration.toDouble(),
                      color: null,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: context.colorScheme.errorContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: context.colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            context.l10n.errorLoadingStats,
            style: context.titleLargeBold?.copyWith(
              color: context.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            message,
            style: context.bodyMediumOnSurfaceVariant,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.m),
          FilledButton.tonal(
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

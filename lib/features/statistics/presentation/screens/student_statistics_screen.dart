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
import 'package:playing_tracker/features/statistics/presentation/widgets/time_filter_selector.dart';
import 'package:playing_tracker/shared/widgets/custom_app_bar.dart';
import 'package:playing_tracker/shared/widgets/custom_card.dart';

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
      appBar: const CustomAppBar(title: 'Mis Estadísticas'),
      body: BlocBuilder<StudentStatsCubit, StudentStatsState>(
        builder: (context, state) {
          final isLoading = state is StudentStatsLoading;
          final hasData =
              state is StudentStatsLoaded ||
              (state is StudentStatsError && state.weeklyStats != null) ||
              (state is StudentStatsLoading && state.weeklyStats != null);

          return Column(
            children: [
              // Barra de carga superior
              if (isLoading && hasData)
                const LinearProgressIndicator(minHeight: 2),
              if (!isLoading || !hasData) const SizedBox(height: 2),

              // Selector de Filtro
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
                          'Error al cargar estadísticas',
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
                              .read<StudentStatsCubit>()
                              .refreshStats(studentId: studentId),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                  _ => RefreshIndicator(
                    onRefresh: () => context
                        .read<StudentStatsCubit>()
                        .refreshStats(studentId: studentId),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_getStats(state) != null) ...[
                            _StudentStatsContent(
                              progress: _getStats(state)!.progress,
                              weeklyStats: _getStats(state)!.weeklyStats,
                            ),
                          ],
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

  static String _getDayLabel(DateTime date) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[date.weekday - 1];
  }
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
      children: [
        // Resumen general
        CustomCard(
          title: 'Resumen General',
          subtitle: 'Progreso total: ${progress.completionPercentageFormatted}',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Tiempo Total',
                    value: progress.durationFormatted,
                    icon: Icons.access_time,
                    color: context.colorScheme.primary,
                  ),
                  _StatItem(
                    label: 'Sesiones',
                    value: '${progress.totalSessions}',
                    icon: Icons.event_note,
                    color: context.colorScheme.secondary,
                  ),
                  _StatItem(
                    label: 'Racha',
                    value: '${progress.currentStreak} días',
                    icon: Icons.local_fire_department,
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

        // Gráfico de barras: Tiempo por día
        CustomCard(
          title: 'Actividad Semanal',
          subtitle: 'Tiempo total: ${weeklyStats.durationFormatted}',
          child: AppBarChart(
            height: 200,
            data: weeklyStats.dailyBreakdown
                .map(
                  (day) => (
                    label: StudentStatisticsScreen._getDayLabel(
                      day.date.toDate(),
                    ),
                    value: (day.totalDuration / 60).toDouble(),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.m),

        // Gráfico circular: Distribución por tarea
        if (weeklyStats.taskBreakdown.isNotEmpty)
          CustomCard(
            title: 'Distribución por Tarea',
            subtitle: '${weeklyStats.taskBreakdown.length} tareas trabajadas',
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

/// Widget para mostrar un ítem de estadística
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
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
        Text(label, style: context.bodySmallOnSurfaceVariant),
      ],
    );
  }
}

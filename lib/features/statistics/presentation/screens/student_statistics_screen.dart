import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_cubit.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/student_stats_state.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_bar_chart.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_pie_chart.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_progress_chart.dart';
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
          return switch (state) {
            StudentStatsInitial() || StudentStatsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            StudentStatsError(:final message) => Center(
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
            StudentStatsLoaded(:final progress, :final weeklyStats) =>
              RefreshIndicator(
                onRefresh: () => context.read<StudentStatsCubit>().refreshStats(
                  studentId: studentId,
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Resumen general
                      CustomCard(
                        title: 'Resumen General',
                        subtitle:
                            'Progreso total: ${progress.completionPercentageFormatted}',
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
                        subtitle:
                            'Tiempo total: ${weeklyStats.durationFormatted}',
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

                      // Gráfico circular: Distribución por tarea
                      if (weeklyStats.taskBreakdown.isNotEmpty)
                        CustomCard(
                          title: 'Distribución por Tarea',
                          subtitle:
                              '${weeklyStats.taskBreakdown.length} tareas trabajadas',
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
                  ),
                ),
              ),
          };
        },
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[date.weekday - 1];
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

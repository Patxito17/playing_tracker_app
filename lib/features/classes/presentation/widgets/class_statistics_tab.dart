import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../statistics/domain/models/class_stats_model.dart';
import '../../../statistics/domain/models/weekly_stats_model.dart';
import '../../../statistics/presentation/cubit/student_stats_cubit.dart';
import '../../../statistics/presentation/cubit/student_stats_state.dart';
import '../../../statistics/presentation/cubit/teacher_stats_cubit.dart';
import '../../../statistics/presentation/cubit/teacher_stats_state.dart';
import '../../../statistics/presentation/widgets/app_bar_chart.dart';
import '../../../statistics/presentation/widgets/app_pie_chart.dart';
import '../../../statistics/presentation/widgets/app_progress_chart.dart';
import '../../../statistics/presentation/widgets/stat_metric_tile.dart';
import '../../../statistics/presentation/widgets/stats_section_card.dart';
import '../../../statistics/presentation/widgets/time_filter_selector.dart';

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
          final isLoading = state is TeacherStatsLoading;
          final hasData =
              state is TeacherStatsLoaded ||
              (state is TeacherStatsError &&
                  context.read<TeacherStatsCubit>().state
                      is TeacherStatsLoaded);

          final authState = context.read<AuthCubit>().state;
          final teacherId = authState is AuthAuthenticated
              ? authState.userId
              : '';

          final classStats = state is TeacherStatsLoaded
              ? state.classStats
              : (state is TeacherStatsLoading
                    ? state.classStats
                    : (state is TeacherStatsError ? state.classStats : null));

          return Column(
            children: [
              if (isLoading && hasData)
                const LinearProgressIndicator(minHeight: 2),
              if (!isLoading || !hasData) const SizedBox(height: 2),

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
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Text(message, textAlign: TextAlign.center),
                    ),
                  ),
                  _ => RefreshIndicator(
                    onRefresh: () =>
                        context.read<TeacherStatsCubit>().refreshClassStats(
                          classId: classId,
                          teacherId: teacherId,
                        ),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.m,
                        AppSpacing.m,
                        AppSpacing.m,
                        AppSpacing.xxl,
                      ),
                      child: _TeacherStatsBody(classStats: classStats),
                    ),
                  ),
                },
              ),
            ],
          );
        },
      );
    }

    return BlocBuilder<StudentStatsCubit, StudentStatsState>(
      builder: (context, state) {
        final isLoading = state is StudentStatsLoading;
        final hasData =
            state is StudentStatsLoaded ||
            (state is StudentStatsError && state.weeklyStats != null) ||
            (state is StudentStatsLoading && state.weeklyStats != null);

        final authState = context.read<AuthCubit>().state;
        final studentId = authState is AuthAuthenticated
            ? authState.userId
            : '';

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
                  classId: classId,
                );
              },
            ),

            Expanded(
              child: switch (state) {
                StudentStatsInitial() || StudentStatsLoading() when !hasData =>
                  const Center(child: CircularProgressIndicator()),
                StudentStatsError(:final message) when !hasData => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Text(message, textAlign: TextAlign.center),
                  ),
                ),
                _ => RefreshIndicator(
                  onRefresh: () => context
                      .read<StudentStatsCubit>()
                      .refreshStats(studentId: studentId, classId: classId),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.xxl,
                    ),
                    child: _StudentStatsBody(
                      weeklyStats: _getWeeklyStatsFromState(state),
                    ),
                  ),
                ),
              },
            ),
          ],
        );
      },
    );
  }

  WeeklyStatsModel? _getWeeklyStatsFromState(StudentStatsState state) {
    if (state is StudentStatsLoaded) return state.weeklyStats;
    if (state is StudentStatsLoading) return state.weeklyStats;
    if (state is StudentStatsError) return state.weeklyStats;
    return null;
  }
}

String _getDayLabel(DateTime date) {
  const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  return days[date.weekday - 1];
}

/// Cuerpo de estadísticas del alumno en la pestaña de clase.
class _StudentStatsBody extends StatelessWidget {
  const _StudentStatsBody({required this.weeklyStats});

  final WeeklyStatsModel? weeklyStats;

  @override
  Widget build(BuildContext context) {
    if (weeklyStats == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Actividad semanal ---
        StatsSectionCard(
          icon: Icons.bar_chart_rounded,
          title: context.l10n.weeklyActivityTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weeklyStats!.durationFormatted,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              AppBarChart(
                height: 150,
                data: weeklyStats!.dailyBreakdown
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

        // --- Distribución por tarea ---
        StatsSectionCard(
          icon: Icons.pie_chart_rounded,
          title: context.l10n.taskDistributionTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.sessionsCount(weeklyStats!.totalSessions),
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              if (weeklyStats!.taskBreakdown.isNotEmpty)
                AppPieChart(
                  radius: 70,
                  data: weeklyStats!.taskBreakdown
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.m,
                    ),
                    child: Text(
                      context.l10n.noTaskData,
                      style: context.bodyMediumOnSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cuerpo de estadísticas del docente en la pestaña de clase.
class _TeacherStatsBody extends StatelessWidget {
  const _TeacherStatsBody({required this.classStats});

  final ClassStatsModel? classStats;

  @override
  Widget build(BuildContext context) {
    if (classStats == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Tiempo total ---
        StatsSectionCard(
          icon: Icons.timer_outlined,
          title: context.l10n.totalTime,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classStats!.durationFormatted,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      '${context.l10n.averageDurationLabel}: ${classStats!.averageDurationPerStudentFormatted}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),

        // --- Sesiones y distribución ---
        StatsSectionCard(
          icon: Icons.event_note_rounded,
          title: context.l10n.totalSessions,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.sessionsCount(classStats!.totalSessions),
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              if (classStats!.taskBreakdown.isNotEmpty)
                AppPieChart(
                  radius: 70,
                  data: classStats!.taskBreakdown
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.m,
                    ),
                    child: Text(
                      context.l10n.noTaskData,
                      style: context.bodyMediumOnSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),

        // --- Alumnos activos ---
        StatsSectionCard(
          icon: Icons.people_rounded,
          title: context.l10n.activeStudents,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatMetricTile(
                    icon: Icons.people_rounded,
                    value: '${classStats!.totalStudents}',
                    label: context.l10n.studentsLabel,
                    color: context.colorScheme.primary,
                  ),
                  StatMetricTile(
                    icon: Icons.trending_up_rounded,
                    value: '${classStats!.activeStudents}',
                    label: context.l10n.classStatusActive,
                    subtitle: classStats!.activeStudentsPercentageFormatted,
                    color: context.colorScheme.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                context.l10n.ofTotalStudents(classStats!.totalStudents),
                style: context.bodySmallOnSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.m),
              Center(
                child: AppProgressChart(
                  progress: classStats!.activeStudentsPercentage / 100,
                  size: 120,
                  strokeWidth: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),

        // --- Desglose por tareas ---
        if (classStats!.taskBreakdown.isNotEmpty)
          StatsSectionCard(
            icon: Icons.assignment_rounded,
            title: context.l10n.workedTasks,
            child: Column(
              children: classStats!.taskBreakdown.map<Widget>((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.taskTitle,
                              style: context.titleMediumBold,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.small,
                          ),
                        ),
                        child: Text(
                          task.durationFormatted,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_card.dart';
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

          // Obtener teacherId para las acciones
          final authState = context.read<AuthCubit>().state;
          final teacherId = authState is AuthAuthenticated
              ? authState.userId
              : '';

          return Column(
            children: [
              // Barra de carga superior sutil
              if (isLoading && hasData)
                const LinearProgressIndicator(minHeight: 2),
              if (!isLoading || !hasData) const SizedBox(height: 2),

              // Selector de Filtro Temporal
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
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: _TeacherStatsBody(
                        classStats: state is TeacherStatsLoaded
                            ? state.classStats
                            : (state is TeacherStatsLoading
                                  ? state.classStats
                                  : (state is TeacherStatsError
                                        ? state.classStats
                                        : null)),
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

    return BlocBuilder<StudentStatsCubit, StudentStatsState>(
      builder: (context, state) {
        final isLoading = state is StudentStatsLoading;
        final hasData =
            state is StudentStatsLoaded ||
            (state is StudentStatsError && state.weeklyStats != null) ||
            (state is StudentStatsLoading && state.weeklyStats != null);

        // Obtener studentId para las acciones
        final authState = context.read<AuthCubit>().state;
        final studentId = authState is AuthAuthenticated
            ? authState.userId
            : '';

        return Column(
          children: [
            // Barra de carga superior sutil
            if (isLoading && hasData)
              const LinearProgressIndicator(minHeight: 2),
            if (!isLoading || !hasData) const SizedBox(height: 2),

            // Selector de Filtro Temporal para Estudiantes
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
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.classStatisticsTitle,
                          style: context.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.l),
                        if (_getWeeklyStatsFromState(state) != null) ...[
                          _StudentStatsBody(
                            weeklyStats: _getWeeklyStatsFromState(state)!,
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
    );
  }

  WeeklyStatsModel? _getWeeklyStatsFromState(StudentStatsState state) {
    if (state is StudentStatsLoaded) return state.weeklyStats;
    if (state is StudentStatsLoading) return state.weeklyStats;
    if (state is StudentStatsError) return state.weeklyStats;
    return null;
  }

  static String _getDayLabel(DateTime date) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[date.weekday - 1];
  }
}

/// Cuerpo de estadísticas del alumno extraído para reutilización.
class _StudentStatsBody extends StatelessWidget {
  const _StudentStatsBody({required this.weeklyStats});

  final WeeklyStatsModel weeklyStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomCard(
          title: context.l10n.totalTime,
          subtitle: context.l10n.totalTime,
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
                        label: ClassStatisticsTab._getDayLabel(
                          day.date.toDate(),
                        ),
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
          subtitle: context.l10n.totalSessions,
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
    );
  }
}

/// Cuerpo de estadísticas del docente extraído para reutilización.
class _TeacherStatsBody extends StatelessWidget {
  const _TeacherStatsBody({required this.classStats});

  final ClassStatsModel? classStats;

  @override
  Widget build(BuildContext context) {
    if (classStats == null) return const SizedBox.shrink();

    return Column(
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
                classStats!.durationFormatted,
                style: context.textTheme.headlineLarge?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.bold,
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
                      Icons.timer_outlined,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      '${context.l10n.averageDurationLabel}: ${classStats!.averageDurationPerStudentFormatted}',
                      style: context.bodyMediumOnSurfaceVariant?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
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
          subtitle: context.l10n.totalSessions,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.sessionsCount(classStats!.totalSessions),
                style: context.textTheme.headlineLarge?.copyWith(
                  color: context.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
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
                const Center(child: Text('Sin datos de tareas')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        CustomCard(
          title: context.l10n.activeStudents,
          subtitle: context.l10n.activeStudents,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.activeStudentsCount(classStats!.activeStudents),
                style: context.textTheme.headlineLarge?.copyWith(
                  color: context.colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'De un total de ${context.l10n.studentsCount(classStats!.totalStudents)}',
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
        if (classStats!.taskBreakdown.isNotEmpty)
          CustomCard(
            title: context.l10n.generalOverview,
            subtitle: context.l10n.generalOverview,
            child: Column(
              children: [
                ...classStats!.taskBreakdown.map((task) {
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
                                '${task.totalSessions} sesiones registradas',
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
                            style: context.bodyMediumOnSurfaceVariant?.copyWith(
                              color: context.colorScheme.onSecondaryContainer,
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
    );
  }
}

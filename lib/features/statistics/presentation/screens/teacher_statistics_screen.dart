import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_class_stats_model.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_cubit.dart';
import 'package:playing_tracker/features/statistics/presentation/cubit/teacher_stats_state.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/stat_metric_tile.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/stats_section_card.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/time_filter_selector.dart';
import 'package:playing_tracker/shared/widgets/custom_app_bar.dart';

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
                    child: _ErrorState(
                      message: message,
                      onRetry: () =>
                          context.read<TeacherStatsCubit>().refreshClassStats(
                            classId: classId,
                            teacherId: teacherId,
                          ),
                    ),
                  ),
                  _ => _StatsContent(
                    classStats: classStats,
                    classId: classId,
                    teacherId: teacherId,
                    isLoading: isLoading,
                    studentsStats: state is TeacherStatsLoaded
                        ? state.studentsStats
                        : (state is TeacherStatsLoading
                              ? state.studentsStats
                              : null),
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
    required this.studentsStats,
  });

  final ClassStatsModel? classStats;
  final String classId;
  final String teacherId;
  final bool isLoading;
  final List<StudentClassStatsModel>? studentsStats;

  @override
  Widget build(BuildContext context) {
    if (classStats == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: AppDurations.medium,
      opacity: isLoading ? 0.6 : 1.0,
      child: RefreshIndicator(
        onRefresh: () => context.read<TeacherStatsCubit>().refreshClassStats(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Ranking de alumnos ---
              if (studentsStats != null && studentsStats!.isNotEmpty)
                _StudentRankingSection(studentsStats: studentsStats!),
              if (studentsStats != null && studentsStats!.isEmpty)
                StatsSectionCard(
                  icon: Icons.people_rounded,
                  title: context.l10n.studentRankingTitle,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.m,
                      ),
                      child: Text(
                        context.l10n.noStudentsActivity,
                        style: context.bodyMediumOnSurfaceVariant,
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                                  color:
                                      context.colorScheme.onSecondaryContainer,
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

              const SizedBox(height: AppSpacing.m),

              // --- Resumen de la clase ---
              StatsSectionCard(
                icon: Icons.school_rounded,
                title: classStats!.className,
                child: Column(
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
                          subtitle:
                              classStats!.activeStudentsPercentageFormatted,
                          color: context.colorScheme.tertiary,
                        ),
                        StatMetricTile(
                          icon: Icons.event_note_rounded,
                          value: '${classStats!.totalSessions}',
                          label: context.l10n.sessionsLabel,
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
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Text(
                            '${context.l10n.totalTime}: ${classStats!.durationFormatted}',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentRankingSection extends StatelessWidget {
  const _StudentRankingSection({required this.studentsStats});

  final List<StudentClassStatsModel> studentsStats;

  @override
  Widget build(BuildContext context) {
    return StatsSectionCard(
      icon: Icons.leaderboard_rounded,
      title: context.l10n.studentRankingTitle,
      child: Column(
        children: List.generate(studentsStats.length, (index) {
          final student = studentsStats[index];
          final rank = index + 1;
          return _StudentRankRow(student: student, rank: rank);
        }),
      ),
    );
  }
}

class _StudentRankRow extends StatelessWidget {
  const _StudentRankRow({required this.student, required this.rank});

  final StudentClassStatsModel student;
  final int rank;

  String _rankLabel() {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '$rank.';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isActive = student.totalSessions > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              _rankLabel(),
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              student.studentName,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isActive
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          if (isActive) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                student.durationFormatted,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                context.l10n.sessionsLabelCount(student.totalSessions),
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ] else
            Text(
              student.durationFormatted,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
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
            context.l10n.loadingError,
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

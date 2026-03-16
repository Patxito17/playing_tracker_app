import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../domain/models/session_model.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';

/// Pantalla de historial de sesiones de estudio con diseño premium Material 3.
///
/// Muestra las sesiones con filtros por fecha, cards con jerarquía visual
/// clara y estados vacíos/error con el patrón de icono circular premium.
class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({required this.studentId, this.taskId, super.key});

  final String studentId;
  final String? taskId;

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().watchSessions(
      studentId: widget.studentId,
      taskId: widget.taskId,
    );
  }

  List<SessionModel> _filterSessions(List<SessionModel> sessions) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'today':
        return sessions.where((s) {
          final d = s.endTime.toDate();
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();
      case 'week':
        // Normalizar a medianoche del lunes para no excluir sesiones
        // anteriores a la hora actual en el mismo día.
        final todayMidnight = DateTime(now.year, now.month, now.day);
        final startOfWeek = todayMidnight.subtract(
          Duration(days: now.weekday - 1),
        );
        return sessions
            .where((s) => !s.endTime.toDate().isBefore(startOfWeek))
            .toList();
      case 'month':
        return sessions
            .where(
              (s) =>
                  s.endTime.toDate().year == now.year &&
                  s.endTime.toDate().month == now.month,
            )
            .toList();
      default:
        return sessions;
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  String _formatDurationReadable(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return remaining == 0 ? '$hours h' : '$hours h $remaining min';
  }

  String _formatDateTime(Timestamp timestamp) {
    final d = timestamp.toDate();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.taskId != null
            ? context.l10n.taskHistory
            : context.l10n.sessionHistoryTitle,
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading || state is HistoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryError) {
            return Center(child: _ErrorState(message: state.message));
          }

          if (state is HistoryEmpty) {
            return Center(
              child: _EmptyState(
                title: context.l10n.noSessions,
                subtitle: context.l10n.startFirstSession,
                icon: Icons.history_edu_outlined,
              ),
            );
          }

          if (state is! HistorySuccess) return const SizedBox.shrink();

          final filtered = _filterSessions(state.sessions);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HistoryCubit>().watchSessions(
                studentId: widget.studentId,
                taskId: widget.taskId,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.xxl,
              ),
              children: [
                // --- Filtros de fecha ---
                _DateFilterRow(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) =>
                      setState(() => _selectedFilter = filter),
                ),
                const SizedBox(height: AppSpacing.m),

                // --- Estado vacío tras filtrar ---
                if (filtered.isEmpty)
                  _EmptyState(
                    title: context.l10n.noFilteredSessions,
                    subtitle: context.l10n.adjustDateFilter,
                    icon: Icons.filter_list_off_outlined,
                  )
                else
                  ...filtered.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: _SessionCard(
                        session: session,
                        formatDuration: _formatDuration,
                        formatDurationReadable: _formatDurationReadable,
                        formatDateTime: _formatDateTime,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Fila de chips de filtro por fecha.
class _DateFilterRow extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _DateFilterRow({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.filterByDate,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.xs,
              children: [
                _buildChip(context, 'today', context.l10n.today),
                _buildChip(context, 'week', context.l10n.thisWeek),
                _buildChip(context, 'month', context.l10n.thisMonth),
                _buildChip(context, 'all', context.l10n.all),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String value, String label) {
    final selected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (s) => onFilterChanged(s ? value : 'all'),
      selectedColor: context.colorScheme.primaryContainer,
      checkmarkColor: context.colorScheme.onPrimaryContainer,
      labelStyle: selected
          ? context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onPrimaryContainer,
            )
          : context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
    );
  }
}

/// Card individual de sesión con diseño premium Material 3.
class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.formatDuration,
    required this.formatDurationReadable,
    required this.formatDateTime,
  });

  final SessionModel session;
  final String Function(int) formatDuration;
  final String Function(int) formatDurationReadable;
  final String Function(Timestamp) formatDateTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final taskTitle = session.taskTitle ?? context.l10n.practiceSession;
    final hasNotes = session.notes != null && session.notes!.isNotEmpty;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: colorScheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: título + badge de duración
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskTitle,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (session.className != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.class_outlined,
                              size: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              session.className!,
                              style: context.bodySmallOnSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                // Badge de duración
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        formatDurationReadable(session.totalDuration),
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: AppSpacing.l),

            // Fila de duración exacta
            _InfoRow(
              icon: Icons.access_time_outlined,
              label: context.l10n.sessionDuration,
              value: formatDuration(session.totalDuration),
            ),
            const SizedBox(height: AppSpacing.s),
            // Fila de fecha
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: context.l10n.sessionDate,
              value: formatDateTime(session.endTime),
            ),

            // Notas (si existen)
            if (hasNotes) ...[
              const SizedBox(height: AppSpacing.s),
              _InfoRow(
                icon: Icons.notes_outlined,
                label: context.l10n.sessionNotesLabel,
                value: session.notes!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fila de información con icono, etiqueta y valor.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: context.bodySmallOnSurfaceVariant,
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Estado vacío premium con icono circular.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer.withValues(
                alpha: 0.4,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: context.colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            style: context.titleLargeBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle,
            style: context.bodyMediumOnSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Estado de error.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

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
            context.l10n.errorLoadingHistory,
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
        ],
      ),
    );
  }
}

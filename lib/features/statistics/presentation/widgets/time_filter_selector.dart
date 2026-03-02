import 'package:flutter/material.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/statistics/domain/models/time_filter_enum.dart';

/// Widget selector de filtro temporal (Semana, Mes, 3 Meses, 9 Meses, Histórico).
class TimeFilterSelector extends StatelessWidget {
  const TimeFilterSelector({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final TimeFilter currentFilter;
  final ValueChanged<TimeFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: SegmentedButton<TimeFilter>(
        segments: [
          ButtonSegment(
            value: TimeFilter.thisWeek,
            label: Text(context.l10n.filterThisWeek),
            icon: const Icon(Icons.calendar_view_week),
          ),
          ButtonSegment(
            value: TimeFilter.thisMonth,
            label: Text(context.l10n.filterThisMonth),
            icon: const Icon(Icons.calendar_month),
          ),
          ButtonSegment(
            value: TimeFilter.last3Months,
            label: Text(context.l10n.filterLast3Months),
          ),
          ButtonSegment(
            value: TimeFilter.last9Months,
            label: Text(context.l10n.filterLast9Months),
          ),
          ButtonSegment(
            value: TimeFilter.allTime,
            label: Text(context.l10n.filterAllTime),
            icon: const Icon(Icons.history),
          ),
        ],
        selected: {currentFilter},
        onSelectionChanged: (Set<TimeFilter> selection) {
          onFilterChanged(selection.first);
        },
        showSelectedIcon: false,
      ),
    );
  }
}

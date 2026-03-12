import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Tarjeta para mostrar el progreso semanal del estudiante.
class HomeProgressCard extends StatelessWidget {
  final double progress; // 0.0 a 1.0
  final List<double> weeklyData;

  const HomeProgressCard({
    super.key,
    required this.progress,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.weeklyProgressTitle,
                style: context.titleLargeBold,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: context.titleMediumBold?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            minHeight: 8,
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(weeklyData.length, (index) {
              final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
              final day = days[index % days.length];
              final value = weeklyData[index];
              final isToday = (index + 1) == DateTime.now().weekday;

              return Column(
                children: [
                  Text(
                    day,
                    style: context.labelSmall?.copyWith(
                      color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: 4,
                    height: 32 * value + 4,
                    decoration: BoxDecoration(
                      color: isToday ? colorScheme.primary : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

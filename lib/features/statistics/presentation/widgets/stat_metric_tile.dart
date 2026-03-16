import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Metric tile: circular icon + bold value + optional subtitle + label.
///
/// Used in both student and teacher statistics screens to display
/// key metrics (time, sessions, streak, active students, etc.).
class StatMetricTile extends StatelessWidget {
  const StatMetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: context.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        Text(label, style: context.bodySmallOnSurfaceVariant),
      ],
    );
  }
}

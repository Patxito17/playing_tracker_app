import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Tarjeta compacta para mostrar estadísticas en el dashboard.
class HomeStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const HomeStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            value,
            style: context.titleLargeBold,
          ),
          Text(
            label,
            style: context.bodySmallOnSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

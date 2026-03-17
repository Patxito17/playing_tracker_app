import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Tarjeta para mostrar logros, medallas o avisos importantes de forma destacada.
class HomeAccomplishmentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? backgroundColor;

  const HomeAccomplishmentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final bgColor = backgroundColor ?? colorScheme.primary;
    final onBgColor = bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: onBgColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: onBgColor,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.titleMediumBold?.copyWith(
                    color: onBgColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.bodySmallOnSurfaceVariant?.copyWith(
                    color: onBgColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

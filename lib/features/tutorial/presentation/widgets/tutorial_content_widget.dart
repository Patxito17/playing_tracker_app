import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Widget reutilizable para el contenido visual de cada paso del tutorial.
///
/// Muestra un ícono opcional, un título en negrita y una descripción.
/// Usa exclusivamente tokens M3 del [ColorScheme] activo para adaptarse
/// automáticamente al tema claro/oscuro y al color semilla del usuario.
class TutorialContentWidget extends StatelessWidget {
  const TutorialContentWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon,
  });

  final String title;
  final String description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(height: AppSpacing.s),
          ],
          Text(
            title,
            style: context.titleMediumBold?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

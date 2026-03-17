import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Estado vacío reutilizable para screens de la feature de clases.
///
/// Soporta dos variantes visuales según [iconBackgroundColor]:
/// - **Prominente** (con círculo): pasa [iconBackgroundColor] y [iconColor]
///   para mostrar el ícono centrado en un círculo coloreado (120x120).
/// - **Simple** (sin círculo): omite [iconBackgroundColor]; el ícono
///   se muestra directamente con [iconColor] o `colorScheme.outline`.
class ClassEmptyState extends StatelessWidget {
  const ClassEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.library_music_rounded,
    this.iconSize = 80.0,
    this.iconColor,
    this.iconBackgroundColor,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  /// Tamaño del ícono. Cuando se usa con círculo se recomienda 56.
  final double iconSize;

  /// Color del ícono. Si null, usa `colorScheme.outline` (variante simple)
  /// o `colorScheme.primary` (variante prominente con círculo).
  final Color? iconColor;

  /// Color de fondo del círculo. Si null, no se dibuja el círculo.
  final Color? iconBackgroundColor;

  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final resolvedIconColor =
        iconColor ?? (iconBackgroundColor != null ? colorScheme.primary : colorScheme.outline);

    final iconWidget = Icon(icon, size: iconSize, color: resolvedIconColor);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.l,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconBackgroundColor != null)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: iconWidget,
            )
          else
            iconWidget,
          const SizedBox(height: AppSpacing.xl),
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
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? Icons.add_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

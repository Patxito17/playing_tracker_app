import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Card reutilizable para mostrar acciones rápidas en las pantallas Home.
class HomeQuickActionCard extends StatelessWidget {
  /// Icono principal de la acción.
  final IconData icon;

  /// Título descriptivo de la acción.
  final String title;

  /// Descripción breve que da contexto a la acción.
  final String description;

  /// Callback ejecutado al tocar la tarjeta.
  final VoidCallback onTap;

  /// Color opcional del fondo.
  final Color? backgroundColor;

  /// Color opcional del texto/icono.
  final Color? foregroundColor;

  const HomeQuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final effectiveForeground = foregroundColor ?? colorScheme.onSurface;

    return Semantics(
      button: true,
      label: title,
      hint: description,
      child: Card(
        color: backgroundColor ?? colorScheme.surface,
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: effectiveForeground),
                const SizedBox(height: AppSpacing.m),
                Text(
                  title,
                  style: context.titleMediumBold?.copyWith(
                    color: effectiveForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  description,
                  style: context.bodyMediumOnSurfaceVariant?.copyWith(
                    color: foregroundColor != null
                        ? effectiveForeground.withValues(alpha: 0.9)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

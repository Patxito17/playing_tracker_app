import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// Badge pill de estado para tareas.
///
/// Muestra un indicador visual con icono + texto en un contenedor pill
/// con fondo tintado y borde del mismo color.
/// Diseñado siguiendo Material 3 con tokens de color dinámicos.
class TaskStatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const TaskStatusBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

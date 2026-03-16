import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Fila de información con icono, etiqueta y valor.
///
/// Reutilizable en pantallas de detalle de tarea para mostrar metadatos
/// como tiempo estimado, fecha de creación y fecha límite.
class TaskInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  /// Color opcional para el valor. Si no se proporciona usa [onSurface].
  final Color? valueColor;

  const TaskInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.s),
        Text('$label: ', style: context.bodySmallOnSurfaceVariant),
        Flexible(
          child: Text(
            value,
            style: context.bodySmallBold?.copyWith(color: valueColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

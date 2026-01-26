import 'package:flutter/material.dart';

/// Widget reutilizable para indicador de progreso circular.
///
/// Muestra un porcentaje de completitud con un gráfico circular y texto central.
/// Se adapta automáticamente al tema claro/oscuro de la aplicación.
class AppProgressChart extends StatelessWidget {
  const AppProgressChart({
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    this.progressColor,
    this.backgroundColor,
    this.centerWidget,
    super.key,
  }) : assert(
         progress >= 0.0 && progress <= 1.0,
         'Progress must be between 0.0 and 1.0',
       );

  /// Progreso actual (0.0 a 1.0)
  final double progress;

  /// Tamaño del widget (diámetro)
  final double size;

  /// Grosor del arco de progreso
  final double strokeWidth;

  /// Color del progreso (si es null, usa el color primario del tema)
  final Color? progressColor;

  /// Color de fondo del círculo (si es null, usa el color surface variant)
  final Color? backgroundColor;

  /// Widget personalizado para mostrar en el centro
  /// Si es null, muestra el porcentaje por defecto
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveProgressColor = progressColor ?? colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainerHighest;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo de progreso
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: effectiveBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Contenido central
          centerWidget ??
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Completado',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

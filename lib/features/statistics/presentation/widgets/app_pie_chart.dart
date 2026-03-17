import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget reutilizable para gráficos circulares (Pie Chart).
///
/// Visualiza la distribución de tiempo por tarea.
/// Se adapta automáticamente al tema claro/oscuro de la aplicación.
class AppPieChart extends StatefulWidget {
  const AppPieChart({
    required this.data,
    this.title,
    this.radius = 100,
    this.centerText,
    super.key,
  });

  /// Datos del gráfico: cada entrada es (label, valor, color opcional).
  /// Por ejemplo: `[('Escalas', 45, Colors.blue), ('Estudios', 30, Colors.red)]`
  final List<({String label, double value, Color? color})> data;

  /// Título opcional del gráfico
  final String? title;

  /// Radio del gráfico circular
  final double radius;

  /// Texto opcional para mostrar en el centro del gráfico
  final String? centerText;

  @override
  State<AppPieChart> createState() => _AppPieChartState();
}

class _AppPieChartState extends State<AppPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Caso: sin datos
    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.radius * 2 + 100,
        child: Center(
          child: Text(
            'No hay datos disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    // Paleta de colores por defecto si no se especifica
    final defaultColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    // Calcular el total para obtener porcentajes
    final total = widget.data.fold<double>(0, (sum, item) => sum + item.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              widget.title!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        Row(
          children: [
            // Gráfico circular
            SizedBox(
              height: widget.radius * 2,
              width: widget.radius * 2,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: widget.centerText != null ? 40 : 0,
                  sections: List.generate(widget.data.length, (index) {
                    final isTouched = index == touchedIndex;
                    final radius = isTouched
                        ? widget.radius + 10
                        : widget.radius;
                    final item = widget.data[index];
                    final percentage = (item.value / total * 100)
                        .toStringAsFixed(1);
                    final color =
                        item.color ??
                        defaultColors[index % defaultColors.length];

                    return PieChartSectionData(
                      color: color,
                      value: item.value,
                      title: '$percentage%',
                      radius: radius,
                      titleStyle: TextStyle(
                        fontSize: isTouched ? 16 : 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Leyenda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.data.length, (index) {
                  final item = widget.data[index];
                  final color =
                      item.color ?? defaultColors[index % defaultColors.length];
                  final percentage = (item.value / total * 100).toStringAsFixed(
                    1,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.label,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        // Texto central (si se proporciona)
        if (widget.centerText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                widget.centerText!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
      ],
    );
  }
}

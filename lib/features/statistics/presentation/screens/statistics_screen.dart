import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../widgets/app_bar_chart.dart';
import '../widgets/app_pie_chart.dart';
import '../widgets/app_progress_chart.dart';

/// Pantalla de estadísticas (Integración de Gráficos - Sprint 6 Fase 2)
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Estadísticas'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            const CustomCard(
              title: 'Progreso Semanal',
              subtitle: 'Tiempo de estudio por día (minutos)',
              child: AppBarChart(
                height: 200,
                data: [
                  (label: 'Lun', value: 45),
                  (label: 'Mar', value: 30),
                  (label: 'Mie', value: 50),
                  (label: 'Jue', value: 20),
                  (label: 'Vie', value: 40),
                  (label: 'Sab', value: 15),
                  (label: 'Dom', value: 10),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            const CustomCard(
              title: 'Distribución por Tarea',
              subtitle: 'Reparto de tiempo en la última semana',
              child: AppPieChart(
                radius: 80,
                data: [
                  (label: 'Escalas', value: 40, color: Colors.blue),
                  (label: 'Repertorio', value: 35, color: Colors.green),
                  (label: 'Lectura', value: 15, color: Colors.orange),
                  (label: 'Teoría', value: 10, color: Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            const CustomCard(
              title: 'Objetivo Semanal',
              subtitle: 'Progreso hacia tu meta de 5 horas',
              child: Center(
                child: AppProgressChart(
                  progress: 0.65,
                  size: 150,
                  strokeWidth: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

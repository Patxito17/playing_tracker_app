import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/navigation_helper.dart';
import '../widgets/class_statistics_tab.dart';
import '../widgets/class_students_tab.dart';
import '../widgets/class_tasks_tab.dart';

/// Pantalla de detalle de clase para docente (Placeholder - Sprint 0)
///
/// Muestra la información de la clase con 3 tabs:
/// - Tareas: Lista de tareas con opción para crear nuevas
/// - Estudiantes: Lista de estudiantes con estadísticas
/// - Estadísticas: Estadísticas agregadas de la clase
///
/// La UI completa se implementará en Sprint 0 - Fase 7.
class TeacherClassDetailScreen extends StatelessWidget {
  final String classId;

  const TeacherClassDetailScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Clase'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Volver',
          ),
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.assignment), text: 'Tareas'),
              Tab(icon: Icon(Icons.people), text: 'Estudiantes'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Estadísticas'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  ClassTasksTab(classId: classId),
                  ClassStudentsTab(classId: classId),
                  ClassStatisticsTab(classId: classId, isTeacher: true),
                ],
              ),
            ),
            const NavigationHelper(),
          ],
        ),
      ),
    );
  }
}

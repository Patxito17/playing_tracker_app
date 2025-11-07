import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/custom_tab_bar.dart';
import '../widgets/class_statistics_tab.dart';
import '../widgets/class_students_tab.dart';
import '../widgets/class_tasks_tab.dart';

/// Pantalla de detalle de clase para docente
///
/// Muestra la información de la clase con 3 tabs:
/// - Tareas: Lista de tareas con opción para crear nuevas
/// - Estudiantes: Lista de estudiantes con estadísticas
/// - Estadísticas: Estadísticas agregadas de la clase
///
/// Sprint 0 - Fase 7: UI completa implementada con Material Design 3
class TeacherClassDetailScreen extends StatelessWidget {
  final String classId;

  const TeacherClassDetailScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(ClassDetailStrings.classDetailTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: CommonStrings.back,
          ),
          bottom: CustomTabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.assignment),
                text: ClassDetailStrings.tasksTab,
              ),
              Tab(
                icon: Icon(Icons.people),
                text: ClassDetailStrings.studentsTab,
              ),
              Tab(
                icon: Icon(Icons.bar_chart),
                text: ClassDetailStrings.statisticsTab,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ClassTasksTab(classId: classId),
            ClassStudentsTab(classId: classId),
            ClassStatisticsTab(classId: classId, isTeacher: true),
          ],
        ),
      ),
    );
  }
}

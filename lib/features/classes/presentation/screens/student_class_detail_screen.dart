import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/custom_tab_bar.dart';
import '../widgets/class_info_tab.dart';
import '../widgets/class_statistics_tab.dart';
import '../widgets/student_class_tasks_tab.dart';

/// Pantalla de detalle de clase para estudiante
///
/// Muestra la información de la clase con 3 tabs:
/// - Tareas: Lista de tareas asignadas con opción para iniciar sesión de estudio
/// - Información: Información detallada de la clase y del docente
/// - Estadísticas: Estadísticas individuales del estudiante
///
/// Sprint 0 - Fase 7: UI completa implementada con Material Design 3
class StudentClassDetailScreen extends StatelessWidget {
  final String classId;

  const StudentClassDetailScreen({super.key, required this.classId});

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
              Tab(icon: Icon(Icons.info), text: ClassDetailStrings.infoTab),
              Tab(
                icon: Icon(Icons.bar_chart),
                text: ClassDetailStrings.statisticsTab,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StudentClassTasksTab(classId: classId),
            ClassInfoTab(classId: classId),
            ClassStatisticsTab(classId: classId, isTeacher: false),
          ],
        ),
      ),
    );
  }
}

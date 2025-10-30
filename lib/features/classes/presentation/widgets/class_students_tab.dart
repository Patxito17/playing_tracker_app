import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../core/constants/app_constants.dart';

/// Tab de estudiantes de la clase (para docente)
///
/// Muestra todos los estudiantes de la clase con sus estadísticas.
/// Placeholder para Sprint 0 - Fase 7.
class ClassStudentsTab extends StatelessWidget {
  final String classId;

  const ClassStudentsTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    // Datos mock de estudiantes
    final mockStudents = [
      {'id': 'student1', 'name': 'Juan Pérez', 'sessions': 12, 'hours': 8.5},
      {'id': 'student2', 'name': 'María García', 'sessions': 15, 'hours': 12.0},
      {'id': 'student3', 'name': 'Carlos López', 'sessions': 8, 'hours': 5.5},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Estudiantes de la Clase',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.m),
          if (mockStudents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'No hay estudiantes en esta clase',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Los estudiantes pueden unirse con el código de acceso',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ...mockStudents.map((studentData) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: CustomCard(
                  title: studentData['name'] as String,
                  subtitle:
                      '${studentData['sessions']} sesiones • ${studentData['hours']} horas',
                  child: const SizedBox.shrink(),
                ),
              );
            }),
        ],
      ),
    );
  }
}

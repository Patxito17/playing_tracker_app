import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/navigation_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../config/routes/app_routes.dart';

/// Pantalla de lista de clases a las que pertenece el estudiante (Placeholder - Sprint 0)
///
/// Muestra todas las clases a las que pertenece el estudiante con BottomNavigationBar.
/// La UI completa se implementará en Sprint 0 - Fase 6.
class StudentClassesListScreen extends StatelessWidget {
  const StudentClassesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos mock de clases
    final mockClasses = [
      {'id': 'class1', 'name': 'Piano Nivel 1', 'teacher': 'Prof. García'},
      {'id': 'class2', 'name': 'Guitarra Avanzada', 'teacher': 'Prof. López'},
      {'id': 'class3', 'name': 'Violín Inicial', 'teacher': 'Prof. Martínez'},
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mis Clases',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go(AppRoutes.joinClass),
            tooltip: 'Unirse a Clase',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Clases',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  if (mockClasses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          children: [
                            Icon(
                              Icons.class_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Text(
                              'No estás en ninguna clase',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.s),
                            Text(
                              'Únete a una clase con un código',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...mockClasses.map((classData) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: CustomCard(
                          title: classData['name'] as String,
                          subtitle: 'Profesor: ${classData['teacher']}',
                          onTap: () => context.go(
                            '${AppRoutes.studentClassDetail}/${classData['id']}',
                          ),
                          child: const SizedBox.shrink(),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const NavigationHelper(),
        ],
      ),
      // BottomNavigationBar se maneja mediante ShellRoute en app_routes.dart
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.joinClass),
        icon: const Icon(Icons.add),
        label: const Text('Unirse a Clase'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../core/constants/app_constants.dart';

/// Tab de información de la clase (para estudiante)
///
/// Muestra información detallada de la clase: nombre, descripción, código de acceso, datos del docente.
/// Placeholder para Sprint 0 - Fase 7.
class ClassInfoTab extends StatelessWidget {
  final String classId;

  const ClassInfoTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    // Datos mock de la clase
    final className = 'Piano Nivel 1';
    final classDescription =
        'Curso de piano para principiantes. En este curso aprenderás los fundamentos del piano y desarrollarás habilidades básicas de lectura musical.';
    final classCode = 'ABC123';
    final teacherName = 'Prof. García';
    final teacherEmail = 'prof.garcia@ejemplo.com';
    final createdAt = 'Enero 2025';
    final studentsCount = 12;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            title: className,
            subtitle: 'Código de acceso: $classCode',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descripción',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  classDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          CustomCard(
            title: 'Información del Docente',
            subtitle: teacherName,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email: $teacherEmail',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          CustomCard(
            title: 'Información de la Clase',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creada: $createdAt',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Estudiantes: $studentsCount',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

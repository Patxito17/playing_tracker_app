import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Tab de información de la clase (para estudiante)
///
/// Muestra información detallada de la clase: nombre, descripción, código de acceso, datos del docente.
/// Sprint 0 - Fase 7: UI completa con Material Design 3 y funcionalidad de copiar código
class ClassInfoTab extends StatelessWidget {
  final String classId;

  const ClassInfoTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    // Datos mock de la clase
    final className = 'Piano Nivel 1';
    final classDescription =
        'Curso de piano para principiantes. En este curso aprenderás los fundamentos del piano y desarrollarás habilidades básicas de lectura musical.';
    final classCode = 'ABC234';
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
            subtitle: '${ClassDetailStrings.accessCode}: $classCode',
            trailingAction: IconButton(
              icon: const Icon(Icons.copy_outlined),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: classCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(CommonStrings.copied),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              tooltip: CommonStrings.copy,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ClassDetailStrings.classDescription,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(classDescription, style: context.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          CustomCard(
            title: ClassDetailStrings.teacherInfo,
            subtitle: teacherName,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ClassDetailStrings.email}: $teacherEmail',
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          CustomCard(
            title: ClassDetailStrings.classInfo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ClassDetailStrings.created}: $createdAt',
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  '${ClassDetailStrings.students}: $studentsCount',
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

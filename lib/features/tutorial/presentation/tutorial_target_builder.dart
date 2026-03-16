import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../domain/tutorial_keys.dart';
import 'widgets/tutorial_content_widget.dart';

/// Construye las listas de [TargetFocus] para el tutorial interactivo,
/// diferenciadas por rol (alumno / docente).
///
/// Todos los targets usan [ShapeLightFocus.RRect] con el radio de la app para
/// resaltar tarjetas rectangulares de forma consistente con el diseño M3.
class TutorialTargetBuilder {
  TutorialTargetBuilder._();

  /// Construye los 6 pasos del tutorial para el rol alumno.
  static List<TargetFocus> buildStudentTargets(
    BuildContext context,
    StudentTutorialKeys keys,
  ) {
    final l10n = context.l10n;
    return [
      _buildTarget(
        identify: 'student_greeting',
        key: keys.greetingHero,
        align: ContentAlign.bottom,
        title: l10n.tutorialStudentGreetingTitle,
        description: l10n.tutorialStudentGreetingDesc,
        icon: Icons.waving_hand_rounded,
      ),
      _buildTarget(
        identify: 'student_progress',
        key: keys.progressCard,
        align: ContentAlign.bottom,
        title: l10n.tutorialStudentProgressTitle,
        description: l10n.tutorialStudentProgressDesc,
        icon: Icons.bar_chart_rounded,
      ),
      _buildTarget(
        identify: 'student_streak',
        key: keys.accomplishmentCard,
        align: ContentAlign.bottom,
        title: l10n.tutorialStudentStreakTitle,
        description: l10n.tutorialStudentStreakDesc,
        icon: Icons.local_fire_department_rounded,
      ),
      _buildTarget(
        identify: 'student_classes',
        key: keys.classesCard,
        align: ContentAlign.top,
        title: l10n.tutorialStudentClassesTitle,
        description: l10n.tutorialStudentClassesDesc,
        icon: Icons.piano_rounded,
      ),
      _buildTarget(
        identify: 'student_tasks',
        key: keys.tasksCard,
        align: ContentAlign.top,
        title: l10n.tutorialStudentTasksTitle,
        description: l10n.tutorialStudentTasksDesc,
        icon: Icons.menu_book_rounded,
      ),
      _buildTarget(
        identify: 'student_enroll',
        key: keys.enrollCard,
        align: ContentAlign.top,
        title: l10n.tutorialStudentEnrollTitle,
        description: l10n.tutorialStudentEnrollDesc,
        icon: Icons.library_music_rounded,
      ),
    ];
  }

  /// Construye los 5 pasos del tutorial para el rol docente.
  static List<TargetFocus> buildTeacherTargets(
    BuildContext context,
    TeacherTutorialKeys keys,
  ) {
    final l10n = context.l10n;
    return [
      _buildTarget(
        identify: 'teacher_greeting',
        key: keys.greetingHero,
        align: ContentAlign.bottom,
        title: l10n.tutorialTeacherGreetingTitle,
        description: l10n.tutorialTeacherGreetingDesc,
        icon: Icons.waving_hand_rounded,
      ),
      _buildTarget(
        identify: 'teacher_classes',
        key: keys.classesCard,
        align: ContentAlign.bottom,
        title: l10n.tutorialTeacherClassesTitle,
        description: l10n.tutorialTeacherClassesDesc,
        icon: Icons.library_music_rounded,
      ),
      _buildTarget(
        identify: 'teacher_create_class',
        key: keys.createClass,
        align: ContentAlign.bottom,
        title: l10n.tutorialTeacherCreateClassTitle,
        description: l10n.tutorialTeacherCreateClassDesc,
        icon: Icons.add_rounded,
      ),
      _buildTarget(
        identify: 'teacher_tasks',
        key: keys.tasksGrid,
        align: ContentAlign.bottom,
        title: l10n.tutorialTeacherTasksTitle,
        description: l10n.tutorialTeacherTasksDesc,
        icon: Icons.assignment_rounded,
      ),
      _buildTarget(
        identify: 'teacher_stats',
        key: keys.statsGrid,
        align: ContentAlign.top,
        title: l10n.tutorialTeacherStatsTitle,
        description: l10n.tutorialTeacherStatsDesc,
        icon: Icons.analytics_rounded,
      ),
    ];
  }

  static TargetFocus _buildTarget({
    required String identify,
    required GlobalKey key,
    required ContentAlign align,
    required String title,
    required String description,
    IconData? icon,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      shape: ShapeLightFocus.RRect,
      radius: AppBorderRadius.large,
      enableOverlayTab: true,
      enableTargetTab: true,
      contents: [
        TargetContent(
          align: align,
          child: TutorialContentWidget(
            title: title,
            description: description,
            icon: icon,
          ),
        ),
      ],
    );
  }
}

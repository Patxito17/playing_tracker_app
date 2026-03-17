import 'package:flutter/material.dart';

/// Contenedor de [GlobalKey]s para los targets del tutorial del alumno.
///
/// Se instancia una vez en el [State] de [StudentHomeScreen] para garantizar
/// unicidad por widget tree y evitar colisiones entre reconstrucciones.
class StudentTutorialKeys {
  final greetingHero = GlobalKey(debugLabel: 'tut_s_greeting');
  final progressCard = GlobalKey(debugLabel: 'tut_s_progress');
  final accomplishmentCard = GlobalKey(debugLabel: 'tut_s_streak');
  final classesCard = GlobalKey(debugLabel: 'tut_s_classes');
  final tasksCard = GlobalKey(debugLabel: 'tut_s_tasks');
  final enrollCard = GlobalKey(debugLabel: 'tut_s_enroll');
}

/// Contenedor de [GlobalKey]s para los targets del tutorial del docente.
///
/// Se instancia una vez en el [State] de [TeacherHomeScreen].
class TeacherTutorialKeys {
  final greetingHero = GlobalKey(debugLabel: 'tut_t_greeting');
  final classesCard = GlobalKey(debugLabel: 'tut_t_classes');
  final createClass = GlobalKey(debugLabel: 'tut_t_create');
  final tasksGrid = GlobalKey(debugLabel: 'tut_t_tasks');
  final statsGrid = GlobalKey(debugLabel: 'tut_t_stats');
}

/// Claves para los items del NavigationBar del alumno (estáticas, únicas por app).
class StudentNavBarKeys {
  static final home = GlobalKey(debugLabel: 'nav_s_home');
  static final classes = GlobalKey(debugLabel: 'nav_s_classes');
  static final history = GlobalKey(debugLabel: 'nav_s_history');
  static final statistics = GlobalKey(debugLabel: 'nav_s_statistics');
  static final settings = GlobalKey(debugLabel: 'nav_s_settings');
}

/// Claves para los items del NavigationBar del docente (estáticas, únicas por app).
class TeacherNavBarKeys {
  static final home = GlobalKey(debugLabel: 'nav_t_home');
  static final classes = GlobalKey(debugLabel: 'nav_t_classes');
  static final statistics = GlobalKey(debugLabel: 'nav_t_statistics');
  static final settings = GlobalKey(debugLabel: 'nav_t_settings');
}

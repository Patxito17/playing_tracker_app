// import 'package:go_router/go_router.dart';
// import 'package:flutter/material.dart';

/// Configuración de rutas de la aplicación Playing Tracker
///
/// Utiliza go_router para navegación declarativa con rutas nombradas.
/// Incluye navegación condicional según el rol del usuario.
///
/// Sprint 0 - Fase 1: Archivo placeholder
/// TODO(Sprint 0 - Fase 4): Implementar GoRouter con todas las rutas
library;

class AppRoutes {
  /// Nombres de las rutas principales
  ///
  /// TODO: Definir constantes para todas las rutas
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String teacherHome = '/home/teacher';
  static const String studentHome = '/home/student';
  static const String createClass = '/classes/create';
  static const String joinClass = '/classes/join';
  static const String manageStudents = '/classes/manage';
  static const String taskList = '/tasks';
  static const String createTask = '/tasks/create';
  static const String taskDetail = '/tasks/:taskId';
  static const String timer = '/timer/:taskId';
  static const String statistics = '/statistics';

  /// Configuración de GoRouter
  ///
  /// TODO: Implementar GoRouter con:
  /// - Todas las rutas definidas
  /// - Navegación condicional por rol (AuthWrapper)
  /// - Shell navigation para layouts compartidos
  /// - Manejo de errores y rutas no encontradas
  // static GoRouter get router {
  //   return GoRouter(
  //     initialLocation: login,
  //     routes: [
  //       // Definir todas las rutas aquí
  //     ],
  //   );
  // }
}

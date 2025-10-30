import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/widgets/auth_wrapper.dart';
import '../../features/home/presentation/screens/teacher_home_screen.dart';
import '../../features/home/presentation/screens/student_home_screen.dart';
import '../../features/classes/presentation/screens/teacher_classes_list_screen.dart';
import '../../features/classes/presentation/screens/student_classes_list_screen.dart';
import '../../features/classes/presentation/screens/teacher_class_detail_screen.dart';
import '../../features/classes/presentation/screens/student_class_detail_screen.dart';
import '../../features/classes/presentation/screens/create_class_screen.dart';
import '../../features/classes/presentation/screens/join_class_screen.dart';
import '../../features/classes/presentation/screens/manage_students_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';
import '../../features/tasks/presentation/screens/create_task_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/sessions/presentation/screens/timer_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../../shared/widgets/error_screen.dart';

/// Configuración de rutas de la aplicación Playing Tracker
///
/// Utiliza go_router para navegación declarativa con rutas nombradas.
/// Incluye navegación condicional según el rol del usuario.
///
/// Sprint 0 - Fase 4: Implementación completa de GoRouter
class AppRoutes {
  /// Constantes de rutas principales
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Rutas de Home (redirigen a lista de clases)
  static const String teacherHome = '/home/teacher';
  static const String studentHome = '/home/student';

  // Rutas de Docente con BottomNavigationBar
  static const String teacherClassesList = '/home/teacher/classes';
  static const String teacherClassDetail = '/home/teacher/classes';
  static const String teacherStatistics = '/home/teacher/statistics';
  static const String teacherSettings = '/home/teacher/settings';

  // Rutas de Estudiante con BottomNavigationBar
  static const String studentClassesList = '/home/student/classes';
  static const String studentClassDetail = '/home/student/classes';
  static const String studentStatistics = '/home/student/statistics';
  static const String studentSettings = '/home/student/settings';

  // Rutas de Clases
  static const String createClass = '/classes/create';
  static const String joinClass = '/classes/join';
  static const String manageStudents = '/classes/manage';

  // Rutas de Tareas
  static const String taskList = '/tasks';
  static const String createTask = '/tasks/create';
  static const String taskDetail = '/tasks/:taskId';

  // Rutas de Sesiones
  static const String timer = '/timer/:taskId';

  // Rutas de Estadísticas (deprecated - usar teacherStatistics o studentStatistics)
  static const String statistics = '/statistics';

  /// Configuración de GoRouter
  ///
  /// Define todas las rutas de la aplicación con navegación condicional
  /// basada en el rol del usuario (mock en este sprint).
  static GoRouter get router {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // Navegación condicional según el rol mock
        final location = state.uri.path;

        // Si estamos en la ruta raíz, redirigir según el rol
        if (location == '/') {
          final role = AuthWrapper.mockRole;
          if (role == 'teacher') {
            return teacherHome;
          } else if (role == 'student') {
            return studentHome;
          } else {
            return login;
          }
        }

        // Permitir acceso a rutas de autenticación sin verificación
        if (location == login ||
            location == register ||
            location == forgotPassword) {
          return null;
        }

        // Para otras rutas, verificar si hay rol (mock)
        // En Sprint 2, esto se validará con Firebase Auth
        final role = AuthWrapper.mockRole;
        if (role == null && location != login) {
          return login;
        }

        return null; // No redirigir, continuar con la navegación normal
      },
      routes: [
        // Ruta raíz (manejada por redirect)
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),

        // Rutas de autenticación
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Rutas de home (redirigen a lista de clases)
        GoRoute(
          path: teacherHome,
          name: 'teacherHome',
          builder: (context, state) => const TeacherHomeScreen(),
        ),
        GoRoute(
          path: studentHome,
          name: 'studentHome',
          builder: (context, state) => const StudentHomeScreen(),
        ),

        // ShellRoute para docente con BottomNavigationBar
        ShellRoute(
          builder: (context, state, child) {
            final role = AuthWrapper.mockRole;
            final location = state.uri.path;

            // Determinar el índice del tab activo según la ruta
            int currentIndex = 0;
            if (location.startsWith(teacherStatistics)) {
              currentIndex = BottomNavTab.statistics.index;
            } else if (location.startsWith(teacherSettings)) {
              currentIndex = BottomNavTab.settings.index;
            } else {
              currentIndex = BottomNavTab.classes.index;
            }

            return Scaffold(
              body: child,
              bottomNavigationBar: CustomBottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {},
                role: role,
              ),
            );
          },
          routes: [
            GoRoute(
              path: teacherClassesList,
              name: 'teacherClassesList',
              builder: (context, state) => const TeacherClassesListScreen(),
            ),
            GoRoute(
              path: '$teacherClassDetail/:classId',
              name: 'teacherClassDetail',
              builder: (context, state) {
                final classId = state.pathParameters['classId'] ?? '';
                return TeacherClassDetailScreen(classId: classId);
              },
            ),
            GoRoute(
              path: teacherStatistics,
              name: 'teacherStatistics',
              builder: (context, state) => const StatisticsScreen(),
            ),
            GoRoute(
              path: teacherSettings,
              name: 'teacherSettings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),

        // ShellRoute para estudiante con BottomNavigationBar
        ShellRoute(
          builder: (context, state, child) {
            final role = AuthWrapper.mockRole;
            final location = state.uri.path;

            // Determinar el índice del tab activo según la ruta
            int currentIndex = 0;
            if (location.startsWith(studentStatistics)) {
              currentIndex = BottomNavTab.statistics.index;
            } else if (location.startsWith(studentSettings)) {
              currentIndex = BottomNavTab.settings.index;
            } else {
              currentIndex = BottomNavTab.classes.index;
            }

            return Scaffold(
              body: child,
              bottomNavigationBar: CustomBottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {},
                role: role,
              ),
            );
          },
          routes: [
            GoRoute(
              path: studentClassesList,
              name: 'studentClassesList',
              builder: (context, state) => const StudentClassesListScreen(),
            ),
            GoRoute(
              path: '$studentClassDetail/:classId',
              name: 'studentClassDetail',
              builder: (context, state) {
                final classId = state.pathParameters['classId'] ?? '';
                return StudentClassDetailScreen(classId: classId);
              },
            ),
            GoRoute(
              path: studentStatistics,
              name: 'studentStatistics',
              builder: (context, state) => const StatisticsScreen(),
            ),
            GoRoute(
              path: studentSettings,
              name: 'studentSettings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),

        // Rutas de clases (auxiliares)
        GoRoute(
          path: createClass,
          name: 'createClass',
          builder: (context, state) => const CreateClassScreen(),
        ),
        GoRoute(
          path: joinClass,
          name: 'joinClass',
          builder: (context, state) => const JoinClassScreen(),
        ),
        GoRoute(
          path: '$manageStudents/:classId',
          name: 'manageStudents',
          builder: (context, state) {
            final classId = state.pathParameters['classId'] ?? '';
            return ManageStudentsScreen(classId: classId);
          },
        ),

        // Rutas de tareas
        GoRoute(
          path: taskList,
          name: 'taskList',
          builder: (context, state) => const TaskListScreen(),
        ),
        GoRoute(
          path: createTask,
          name: 'createTask',
          builder: (context, state) => const CreateTaskScreen(),
        ),
        GoRoute(
          path: taskDetail,
          name: 'taskDetail',
          builder: (context, state) {
            final taskId = state.pathParameters['taskId'] ?? '';
            return TaskDetailScreen(taskId: taskId);
          },
        ),

        // Rutas de sesiones
        GoRoute(
          path: timer,
          name: 'timer',
          builder: (context, state) {
            final taskId = state.pathParameters['taskId'] ?? '';
            return TimerScreen(taskId: taskId);
          },
        ),

        // Rutas de estadísticas
        GoRoute(
          path: statistics,
          name: 'statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
      ],
      errorBuilder: (context, state) =>
          ErrorScreen(errorMessage: 'Ruta no encontrada: ${state.uri.path}'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/router/go_router_refresh_stream.dart';
import '../../features/auth/domain/enums/user_role.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/classes/domain/models/membership_model.dart';
import '../../features/classes/domain/repositories/class_repository.dart';
import '../../features/classes/presentation/cubit/class_cubit.dart';
import '../../features/classes/presentation/cubit/membership_cubit.dart';
import '../../features/classes/presentation/cubit/student_classes_cubit.dart';
import '../../features/classes/presentation/screens/create_class_screen.dart';
import '../../features/classes/presentation/screens/join_class_screen.dart';
import '../../features/classes/presentation/screens/manage_students_screen.dart';
import '../../features/classes/presentation/screens/student_class_detail_screen.dart';
import '../../features/classes/presentation/screens/student_classes_list_screen.dart';
import '../../features/classes/presentation/screens/teacher_class_detail_screen.dart';
import '../../features/classes/presentation/screens/teacher_classes_list_screen.dart';
import '../../features/home/presentation/screens/student_home_screen.dart';
import '../../features/home/presentation/screens/teacher_home_screen.dart';
import '../../features/sessions/data/repositories/session_repository_impl.dart';
import '../../features/sessions/data/services/session_service.dart';
import '../../features/sessions/presentation/cubit/history_cubit.dart';
import '../../features/sessions/presentation/cubit/session_cubit.dart';
import '../../features/sessions/presentation/screens/session_history_screen.dart';
import '../../features/sessions/presentation/screens/timer_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../../features/statistics/presentation/cubit/student_stats_cubit.dart';
import '../../features/statistics/presentation/cubit/teacher_stats_cubit.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/statistics/presentation/screens/student_statistics_screen.dart';
import '../../features/statistics/presentation/screens/teacher_statistics_screen.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/presentation/cubit/assignment_cubit.dart';
import '../../features/tasks/presentation/cubit/task_cubit.dart';
import '../../features/tasks/presentation/screens/assignment_list_screen.dart';
import '../../features/tasks/presentation/screens/create_task_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';
import '../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../../shared/widgets/error_screen.dart';

/// Configuración de rutas de la aplicación Playing Tracker
///
/// Utiliza go_router para navegación declarativa con rutas nombradas.
/// Incluye navegación condicional según el rol del usuario.
///
/// Sprint 2 - Fase 4: Implementación GoRouter reactiva con guards reales.
class AppRoutes {
  AppRoutes(this.authCubit);

  final AuthCubit authCubit;

  /// Constantes de rutas principales
  static const String splash = '/';
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
  static const String studentHistory = '/home/student/history';
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

  // Rutas de Asignaciones (Alumno)
  static const String assignmentList = '/assignments';

  // Rutas de Sesiones
  static const String timer = '/timer/:taskId';
  static const String sessionHistory = '/sessions/history';

  // Rutas de Estadísticas (deprecated - usar teacherStatistics o studentStatistics)
  static const String statistics = '/statistics';

  static const List<String> _publicRoutes = [login, register, forgotPassword];

  /// Configuración de GoRouter reactivo.
  late final GoRouter router = GoRouter(
    initialLocation: splash,
    refreshListenable: GoRouterRefreshStream(
      authCubit.stream.distinct((prev, next) {
        if (prev is AuthAuthenticated && next is AuthAuthenticated) {
          return prev.role == next.role;
        }
        return prev == next;
      }),
    ),
    redirect: (context, state) {
      final authState = authCubit.state;
      final location = state.uri.path;

      if (authState is AuthInitial || authState is AuthLoading) {
        final isPublicRoute = _publicRoutes.contains(location);
        return isPublicRoute || location == splash ? null : splash;
      }

      if (authState is AuthUnauthenticated) {
        if (location == splash || !_publicRoutes.contains(location)) {
          return login;
        }
        return null;
      }

      if (authState is AuthAuthenticated) {
        final home = authState.role == UserRole.teacher
            ? teacherHome
            : studentHome;

        if (location == splash || _publicRoutes.contains(location)) {
          return home;
        }

        final isTeacherPath = location.startsWith('/home/teacher');
        final isStudentPath = location.startsWith('/home/student');

        if (isTeacherPath && authState.role != UserRole.teacher) {
          return studentHome;
        }

        if (isStudentPath && authState.role != UserRole.student) {
          return teacherHome;
        }
      }

      return null;
    },
    routes: [
      // Splash / loader
      GoRoute(
        path: splash,
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
        builder: (context, state) => BlocProvider(
          create: (context) =>
              ForgotPasswordCubit(context.read<AuthRepository>()),
          child: const ForgotPasswordScreen(),
        ),
      ),

      // StatefulShellRoute para docente con BottomNavigationBar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: CustomBottomNavigationBar(
              navigationShell: navigationShell,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: teacherHome,
                name: 'teacherHome',
                builder: (context, state) => const TeacherHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: teacherClassesList,
                name: 'teacherClassesList',
                builder: (context, state) {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is! AuthAuthenticated ||
                      authState.role != UserRole.teacher) {
                    return const ErrorScreen(
                      errorMessage: 'No se pudo cargar las clases del docente.',
                    );
                  }
                  return BlocProvider(
                    create: (context) =>
                        ClassCubit(context.read<ClassRepository>())
                          ..watchClasses(teacherId: authState.userId),
                    child: const TeacherClassesListScreen(),
                  );
                },
              ),
              GoRoute(
                path: '$teacherClassDetail/:classId',
                name: 'teacherClassDetail',
                builder: (context, state) {
                  final classId = state.pathParameters['classId'] ?? '';
                  return BlocProvider(
                    create: (context) =>
                        MembershipCubit(context.read<ClassRepository>()),
                    child: TeacherClassDetailScreen(classId: classId),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'statistics',
                    name: 'teacherClassStatistics',
                    builder: (context, state) {
                      final classId = state.pathParameters['classId'] ?? '';
                      final authState = context.read<AuthCubit>().state;
                      final teacherId = authState is AuthAuthenticated
                          ? authState.userId
                          : '';

                      return BlocProvider(
                        create: (context) {
                          final repository = StatisticsRepositoryImpl();
                          final cubit = TeacherStatsCubit(repository);
                          cubit.loadClassStats(
                            classId: classId,
                            teacherId: teacherId,
                          );
                          return cubit;
                        },
                        child: TeacherStatisticsScreen(
                          classId: classId,
                          teacherId: teacherId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: teacherStatistics,
                name: 'teacherStatistics',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: teacherSettings,
                name: 'teacherSettings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // StatefulShellRoute para estudiante con BottomNavigationBar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: CustomBottomNavigationBar(
              navigationShell: navigationShell,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: studentHome,
                name: 'studentHome',
                builder: (context, state) => const StudentHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: studentClassesList,
                name: 'studentClassesList',
                builder: (context, state) => BlocProvider(
                  create: (context) =>
                      StudentClassesCubit(context.read<ClassRepository>()),
                  child: const StudentClassesListScreen(),
                ),
              ),
              GoRoute(
                path: '$studentClassDetail/:classId',
                name: 'studentClassDetail',
                builder: (context, state) {
                  final classId = state.pathParameters['classId'] ?? '';
                  final membership = state.extra is MembershipModel
                      ? state.extra as MembershipModel
                      : null;
                  return StudentClassDetailScreen(
                    classId: classId,
                    membership: membership,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: studentHistory,
                name: 'studentHistory',
                builder: (context, state) {
                  final authState = context.read<AuthCubit>().state;
                  final studentId = authState is AuthAuthenticated
                      ? authState.userId
                      : '';

                  // Crear las dependencias necesarias
                  final sessionService = SessionService();
                  final sessionRepository = SessionRepositoryImpl(
                    sessionService: sessionService,
                  );

                  return BlocProvider(
                    create: (context) => HistoryCubit(sessionRepository),
                    child: SessionHistoryScreen(studentId: studentId),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: studentStatistics,
                name: 'studentStatistics',
                builder: (context, state) {
                  final authState = context.read<AuthCubit>().state;
                  final studentId = authState is AuthAuthenticated
                      ? authState.userId
                      : '';

                  return BlocProvider(
                    create: (context) {
                      final repository = StatisticsRepositoryImpl();
                      final cubit = StudentStatsCubit(repository);
                      cubit.loadStats(studentId: studentId);
                      return cubit;
                    },
                    child: StudentStatisticsScreen(studentId: studentId),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: studentSettings,
                name: 'studentSettings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Rutas de clases (auxiliares)
      GoRoute(
        path: createClass,
        name: 'createClass',
        builder: (context, state) {
          final extraCubit = state.extra;
          if (extraCubit is ClassCubit) {
            return BlocProvider<ClassCubit>.value(
              value: extraCubit,
              child: const CreateClassScreen(),
            );
          }
          return BlocProvider(
            create: (context) => ClassCubit(context.read<ClassRepository>()),
            child: const CreateClassScreen(),
          );
        },
      ),
      GoRoute(
        path: joinClass,
        name: 'joinClass',
        builder: (context, state) {
          final extraCubit = state.extra;
          if (extraCubit is ClassCubit) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) =>
                      MembershipCubit(context.read<ClassRepository>()),
                ),
                BlocProvider<ClassCubit>.value(value: extraCubit),
              ],
              child: const JoinClassScreen(),
            );
          }
          return BlocProvider(
            create: (context) =>
                MembershipCubit(context.read<ClassRepository>()),
            child: const JoinClassScreen(),
          );
        },
      ),
      GoRoute(
        path: '$manageStudents/:classId',
        name: 'manageStudents',
        builder: (context, state) {
          final classId = state.pathParameters['classId'] ?? '';
          return BlocProvider(
            create: (context) =>
                MembershipCubit(context.read<ClassRepository>()),
            child: ManageStudentsScreen(classId: classId),
          );
        },
      ),

      // Rutas de tareas
      GoRoute(
        path: taskList,
        name: 'taskList',
        builder: (context, state) {
          final authState = context.read<AuthCubit>().state;
          if (authState is! AuthAuthenticated ||
              authState.role != UserRole.teacher) {
            return const ErrorScreen(
              errorMessage: 'No se pudieron cargar las tareas del docente.',
            );
          }
          return BlocProvider(
            create: (context) => TaskCubit(TaskRepositoryImpl()),
            child: const TaskListScreen(),
          );
        },
      ),
      GoRoute(
        path: createTask,
        name: 'createTask',
        builder: (context, state) {
          final extraCubit = state.extra;
          return MultiBlocProvider(
            providers: [
              if (extraCubit is TaskCubit)
                BlocProvider<TaskCubit>.value(value: extraCubit)
              else
                BlocProvider(
                  create: (context) => TaskCubit(TaskRepositoryImpl()),
                ),
              BlocProvider(
                create: (context) =>
                    ClassCubit(context.read<ClassRepository>()),
              ),
              BlocProvider(
                create: (context) =>
                    MembershipCubit(context.read<ClassRepository>()),
              ),
            ],
            child: const CreateTaskScreen(),
          );
        },
      ),
      GoRoute(
        path: taskDetail,
        name: 'taskDetail',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId'] ?? '';
          final extraCubit = state.extra;
          if (extraCubit is TaskCubit) {
            return BlocProvider<TaskCubit>.value(
              value: extraCubit,
              child: TaskDetailScreen(taskId: taskId),
            );
          }
          final authState = context.read<AuthCubit>().state;
          if (authState is! AuthAuthenticated ||
              authState.role != UserRole.teacher) {
            return const ErrorScreen(
              errorMessage: 'No se pudo cargar el detalle de la tarea.',
            );
          }
          return BlocProvider(
            create: (context) => TaskCubit(TaskRepositoryImpl()),
            child: TaskDetailScreen(taskId: taskId),
          );
        },
      ),

      // Rutas de asignaciones (alumno)
      GoRoute(
        path: assignmentList,
        name: 'assignmentList',
        builder: (context, state) {
          final authState = context.read<AuthCubit>().state;
          if (authState is! AuthAuthenticated ||
              authState.role != UserRole.student) {
            return const ErrorScreen(
              errorMessage:
                  'No se pudieron cargar las asignaciones del alumno.',
            );
          }
          return BlocProvider(
            create: (context) => AssignmentCubit(TaskRepositoryImpl()),
            child: const AssignmentListScreen(),
          );
        },
      ),

      // Rutas de sesiones
      GoRoute(
        path: timer,
        name: 'timer',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId'] ?? '';
          final extra = state.extra as Map<String, String?>?;

          // Crear las dependencias necesarias
          final sessionService = SessionService();
          final sessionRepository = SessionRepositoryImpl(
            sessionService: sessionService,
          );

          return BlocProvider(
            create: (context) => SessionCubit(sessionRepository),
            child: TimerScreen(
              taskId: taskId,
              studentId: extra?['studentId'] ?? '',
              teacherId: extra?['teacherId'] ?? '',
              taskTitle: extra?['taskTitle'] ?? 'Tarea',
              className: extra?['className'],
              classId: extra?['classId'],
            ),
          );
        },
      ),
      GoRoute(
        path: sessionHistory,
        name: 'sessionHistory',
        builder: (context, state) {
          final authState = context.read<AuthCubit>().state;
          final studentId = authState is AuthAuthenticated
              ? authState.userId
              : '';

          // Crear las dependencias necesarias
          final sessionService = SessionService();
          final sessionRepository = SessionRepositoryImpl(
            sessionService: sessionService,
          );

          return BlocProvider(
            create: (context) => HistoryCubit(sessionRepository),
            child: SessionHistoryScreen(studentId: studentId),
          );
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

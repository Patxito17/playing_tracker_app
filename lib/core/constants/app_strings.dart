/// Strings de la aplicación Playing Tracker
///
/// Este archivo actúa como punto de entrada centralizado (barrel file)
/// para todos los strings de la aplicación, exportándolos desde sus
/// respectivos archivos por funcionalidad/feature.
library;

// Core / Common
export 'common_strings.dart';
export 'validation_strings.dart';
export 'navigation_strings.dart';

// Features
export '../../features/auth/presentation/constants/auth_strings.dart';
export '../../features/classes/presentation/constants/classes_strings.dart';
export '../../features/classes/presentation/constants/class_detail_strings.dart';
export '../../features/classes/presentation/constants/student_strings.dart';
export '../../features/home/presentation/constants/home_strings.dart';
export '../../features/sessions/presentation/constants/session_strings.dart';
export '../../features/settings/presentation/constants/settings_strings.dart';
export '../../features/statistics/presentation/constants/statistics_strings.dart';
export '../../features/tasks/presentation/constants/task_strings.dart';

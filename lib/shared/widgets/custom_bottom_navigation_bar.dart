import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../../features/auth/domain/enums/user_role.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/tutorial/domain/tutorial_keys.dart';

/// BottomNavigationBar personalizado con Material Design 3
///
/// Proporciona navegación persistente con 4 tabs principales usando
/// StatefulNavigationShell para mantener el estado de cada tab independientemente:
/// - Inicio: Pantalla principal con acciones rápidas
/// - Clases: Lista de clases (según rol)
/// - Estadísticas: Estadísticas generales
/// - Configuración: Ajustes de la aplicación
///
/// **Ejemplo de uso con StatefulNavigationShell:**
/// ```dart
/// Scaffold(
///   body: navigationShell,
///   bottomNavigationBar: CustomBottomNavigationBar(
///     navigationShell: navigationShell,
///   ),
/// )
/// ```
class CustomBottomNavigationBar extends StatelessWidget {
  /// StatefulNavigationShell que gestiona el estado de cada branch
  final StatefulNavigationShell navigationShell;

  const CustomBottomNavigationBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isTeacher =
        authState is AuthAuthenticated && authState.role == UserRole.teacher;

    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) {
        // Cambiar al branch seleccionado manteniendo el estado
        navigationShell.goBranch(
          index,
          // Si el branch actual es el mismo, no hacer nada
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: [
        NavigationDestination(
          key: isTeacher ? TeacherNavBarKeys.home : StudentNavBarKeys.home,
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: context.l10n.homeTab,
        ),
        NavigationDestination(
          key: isTeacher
              ? TeacherNavBarKeys.classes
              : StudentNavBarKeys.classes,
          icon: const Icon(Icons.library_music_outlined),
          selectedIcon: const Icon(Icons.library_music),
          label: context.l10n.classesTab,
        ),
        if (isTeacher)
          NavigationDestination(
            key: TeacherNavBarKeys.statistics,
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: context.l10n.statisticsTab,
          ),
        // Solo mostrar Historial para alumnos
        if (!isTeacher) ...[
          NavigationDestination(
            key: StudentNavBarKeys.history,
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: context.l10n.historyTab,
          ),
          NavigationDestination(
            key: StudentNavBarKeys.statistics,
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: context.l10n.statisticsTab,
          ),
        ],
        NavigationDestination(
          key: isTeacher
              ? TeacherNavBarKeys.settings
              : StudentNavBarKeys.settings,
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: context.l10n.profileTab,
        ),
      ],
    );
  }
}

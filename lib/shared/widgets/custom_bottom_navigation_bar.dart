import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../../features/auth/domain/enums/user_role.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';

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
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: context.l10n.homeTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.class_outlined),
          selectedIcon: const Icon(Icons.class_),
          label: context.l10n.classesTab,
        ),
        // Solo mostrar Historial para alumnos, para coincidir con el
        // número de branches en StatefulShellRoute (4 para docente, 5 para alumno)
        if (!isTeacher)
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: context.l10n.historyTab,
          ),
        NavigationDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart),
          label: context.l10n.statisticsTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: context.l10n.settingsTab,
        ),
      ],
    );
  }
}

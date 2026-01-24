import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';

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
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: NavigationStrings.homeTab,
        ),
        NavigationDestination(
          icon: Icon(Icons.class_outlined),
          selectedIcon: Icon(Icons.class_),
          label: NavigationStrings.classesTab,
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: NavigationStrings.historyTab,
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: NavigationStrings.statisticsTab,
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: NavigationStrings.settingsTab,
        ),
      ],
    );
  }
}

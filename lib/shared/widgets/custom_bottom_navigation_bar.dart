import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Índices de tabs para BottomNavigationBar
enum BottomNavTab {
  /// Tab de Clases (índice 0)
  classes,

  /// Tab de Estadísticas (índice 1)
  statistics,

  /// Tab de Configuración (índice 2)
  settings,
}

/// Extensión para obtener el índice de BottomNavTab
extension BottomNavTabExtension on BottomNavTab {
  /// Obtiene el índice del tab
  int get index {
    switch (this) {
      case BottomNavTab.classes:
        return 0;
      case BottomNavTab.statistics:
        return 1;
      case BottomNavTab.settings:
        return 2;
    }
  }
}

/// BottomNavigationBar personalizado con Material Design 3
///
/// Proporciona navegación persistente con 3 tabs principales:
/// - Clases: Lista de clases (según rol)
/// - Estadísticas: Estadísticas generales
/// - Configuración: Ajustes de la aplicación
///
/// **Ejemplo de uso:**
/// ```dart
/// Scaffold(
///   body: child,
///   bottomNavigationBar: CustomBottomNavigationBar(
///     currentIndex: 0,
///     onTap: (index) => navigateToTab(index),
///   ),
/// )
/// ```
class CustomBottomNavigationBar extends StatelessWidget {
  /// Índice del tab actual
  final int currentIndex;

  /// Callback que se ejecuta al presionar un tab
  final ValueChanged<int> onTap;

  /// Rol del usuario para determinar las rutas de navegación
  final String? role;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.role,
  });

  /// Determina la ruta según el índice y el rol
  String _getRouteForIndex(int index, String? role) {
    final isTeacher = role == 'teacher';
    final prefix = isTeacher ? '/home/teacher' : '/home/student';

    switch (index) {
      case 0:
        return '$prefix/classes';
      case 1:
        return '$prefix/statistics';
      case 2:
        return '$prefix/settings';
      default:
        return '$prefix/classes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final route = _getRouteForIndex(index, role);
        context.go(route);
        onTap(index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.class_outlined),
          selectedIcon: Icon(Icons.class_),
          label: 'Clases',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Estadísticas',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Configuración',
        ),
      ],
    );
  }
}

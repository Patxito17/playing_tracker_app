import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

/// TabBar personalizado con Material Design 3
///
/// Encapsula un TabBar de Material Design 3 con estilos consistentes
/// usando los tokens del tema. Proporciona una interfaz uniforme para
/// tabs con iconos y texto.
///
/// **Ejemplo de uso:**
/// ```dart
/// DefaultTabController(
///   length: 3,
///   child: Scaffold(
///     appBar: AppBar(
///       bottom: CustomTabBar(
///         tabs: [
///           Tab(icon: Icon(Icons.assignment), text: 'Tareas'),
///           Tab(icon: Icon(Icons.people), text: 'Estudiantes'),
///           Tab(icon: Icon(Icons.bar_chart), text: 'Estadísticas'),
///         ],
///       ),
///     ),
///     body: TabBarView(...),
///   ),
/// )
/// ```
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// Lista de tabs a mostrar
  final List<Tab> tabs;

  /// Callback que se ejecuta cuando se selecciona un tab
  final ValueChanged<int>? onTap;

  /// Indica si el TabBar es scrollable
  final bool isScrollable;

  @override
  final Size preferredSize;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.onTap,
    this.isScrollable = false,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabs: tabs,
      onTap: onTap,
      isScrollable: isScrollable,
      labelColor: context.colorScheme.primary,
      unselectedLabelColor: context.colorScheme.onSurface.withValues(
        alpha: 0.6,
      ),
      indicatorColor: context.colorScheme.primary,
      indicatorWeight: 3.0,
      labelStyle: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.normal,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// AppBar personalizado con título, acciones configurables y navegación hacia atrás
///
/// Encapsula un AppBar de Material Design 3 con estilos consistentes y
/// navegación automática hacia atrás cuando es posible.
///
/// **Ejemplo de uso:**
/// ```dart
/// // AppBar básico con título
/// Scaffold(
///   appBar: CustomAppBar(title: 'Mi Pantalla'),
///   body: MyContent(),
/// )
///
/// // AppBar con acciones
/// Scaffold(
///   appBar: CustomAppBar(
///     title: 'Configuración',
///     actions: [
///       IconButton(
///         icon: Icon(Icons.save),
///         onPressed: () => saveSettings(),
///       ),
///     ],
///   ),
///   body: SettingsContent(),
/// )
///
/// // AppBar con título personalizado
/// Scaffold(
///   appBar: CustomAppBar(
///     customTitle: Row(
///       children: [
///         Icon(Icons.music_note),
///         SizedBox(width: 8),
///         Text('Playing Tracker'),
///       ],
///     ),
///   ),
///   body: MyContent(),
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título del AppBar
  final String? title;

  /// Título personalizado (si se proporciona, ignora title)
  final Widget? customTitle;

  /// Acciones del AppBar (iconos o widgets adicionales)
  final List<Widget>? actions;

  /// Callback personalizado para el botón de retroceso
  final VoidCallback? onBackPressed;

  /// Indica si se debe mostrar el botón de retroceso automáticamente
  final bool automaticallyImplyLeading;

  /// Color de fondo personalizado
  final Color? backgroundColor;

  /// Elevación del AppBar
  final double? elevation;

  @override
  final Size preferredSize;

  const CustomAppBar({
    super.key,
    this.title,
    this.customTitle,
    this.actions,
    this.onBackPressed,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // Determinar si se puede hacer pop del Router (go_router)
    final canPop = context.canPop();

    // Construir el widget de título
    Widget? titleWidget;
    if (customTitle != null) {
      titleWidget = customTitle;
    } else if (title != null) {
      titleWidget = Text(title!);
    }

    // Construir el leading (botón de retroceso)
    Widget? leading;
    if (automaticallyImplyLeading && canPop) {
      leading = IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => context.pop(),
        tooltip: AppLocalizations.of(context)!.back,
      );
    } else if (!automaticallyImplyLeading) {
      leading = const SizedBox.shrink();
    }

    return AppBar(
      title: titleWidget,
      leading: leading,
      automaticallyImplyLeading: false,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
    );
  }
}

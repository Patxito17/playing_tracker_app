import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';

/// AppBar personalizado premium para Playing Tracker.
///
/// Soporta:
/// - Logo corporativo o botón de retroceso automático.
/// - Título de texto o widget personalizado.
/// - Acciones personalizadas.
/// - Estética Material 3 dinámica.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título de texto del AppBar.
  final String? title;

  /// Widget de título personalizado (si se proporciona, ignora [title]).
  final Widget? customTitle;

  /// Acciones a mostrar a la derecha.
  final List<Widget>? actions;

  /// Indica si debe mostrar el logo de la app a la izquierda.
  /// Si es false, intentará mostrar el botón de retroceso si puede hacer pop.
  final bool showLogo;

  /// Si es true, el título se centrará.
  final bool centerTitle;

  /// Elevación del AppBar.
  final double elevation;

  /// Fondo personalizado. Si es null, usa transparente por defecto.
  final Color? backgroundColor;

  @override
  final Size preferredSize;

  const CustomAppBar({
    super.key,
    this.title,
    this.customTitle,
    this.actions,
    this.showLogo = false,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor = Colors.transparent,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final canPop = context.canPop();

    // Construcción del leading (izquierda)
    Widget? leading;
    if (showLogo) {
      leading = Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/images/logo.png', width: 24, height: 24),
        ),
      );
    } else if (canPop) {
      leading = IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: context.l10n.back,
        onPressed: () => context.pop(),
      );
    }

    // Construcción del título
    Widget? titleWidget;
    if (customTitle != null) {
      titleWidget = customTitle;
    } else if (title != null) {
      titleWidget = Text(
        title!,
        style: context.titleLargeBold?.copyWith(color: colorScheme.onSurface),
      );
    }

    return AppBar(
      leading: leading,
      title: titleWidget,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
    );
  }
}

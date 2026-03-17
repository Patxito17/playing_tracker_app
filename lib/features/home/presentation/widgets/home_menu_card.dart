import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Una tarjeta cuadrada para el menú principal con icono y etiqueta.
/// Inspirada en el diseño premium del dashboard.
class HomeMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Widget? customIcon;

  final bool fullWidth;

  const HomeMenuCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
    this.customIcon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final iconWidget = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: customIcon ??
            Icon(
              icon,
              size: 32,
              color: iconColor ?? colorScheme.primary,
            ),
      ),
    );

    final decoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppBorderRadius.large),
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );

    if (fullWidth) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Container(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.l,
          ),
          child: Row(
            children: [
              iconWidget,
              const SizedBox(width: AppSpacing.l),
              Text(
                label,
                style: context.titleMediumBold?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Container(
          decoration: decoration,
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: AppSpacing.m),
              Text(
                label,
                style: context.titleMediumBold?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

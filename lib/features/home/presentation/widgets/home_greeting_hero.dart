import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Widget para el saludo principal estilo "Hero" con degradado y decoración.
class HomeGreetingHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? topLabel;
  final Widget? badge;
  final IconData? backgroundIcon;
  final CrossAxisAlignment crossAxisAlignment;

  const HomeGreetingHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.topLabel,
    this.badge,
    this.backgroundIcon,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.15),
            colorScheme.primary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Stack(
          children: [
            // Icono de fondo decorativo
            if (backgroundIcon != null)
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  backgroundIcon,
                  size: 160,
                  color: colorScheme.primary.withValues(alpha: 0.05),
                ),
              ),
            // Contenido centrado
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (topLabel != null) ...[
                      Text(
                        topLabel!,
                        style: context.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.headlineMediumBold?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (badge != null) badge!,
                        Text(
                          subtitle,
                          style: context.bodyLargeOnSurfaceVariant?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.8,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

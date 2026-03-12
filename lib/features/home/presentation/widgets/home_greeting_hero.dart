import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Widget para el saludo principal estilo "Hero" con degradado y decoración.
class HomeGreetingHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? backgroundIcon;

  const HomeGreetingHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.4),
            colorScheme.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Stack(
          children: [
            // Contenido
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: context.bodyLargeOnSurfaceVariant?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                      ),
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

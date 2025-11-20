import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'home_quick_action_card.dart';

/// Tarjeta principal con mensaje de bienvenida y CTA.
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.titleLargeBold?.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    subtitle,
                    style: context.bodyMediumOnSurfaceVariant?.copyWith(
                      color: foregroundColor.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: foregroundColor,
                      foregroundColor: backgroundColor,
                    ),
                    child: Text(buttonLabel),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Icon(icon, size: 56, color: foregroundColor),
          ],
        ),
      ),
    );
  }
}

/// Sección reutilizable para mostrar un listado de acciones rápidas.
class HomeQuickActionsSection extends StatelessWidget {
  const HomeQuickActionsSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<HomeQuickActionConfig> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.titleLargeBold),
        const SizedBox(height: AppSpacing.s),
        Text(subtitle, style: context.bodyMediumOnSurfaceVariant),
        const SizedBox(height: AppSpacing.l),
        LayoutBuilder(
          builder: (context, constraints) {
            final isTwoColumns = constraints.maxWidth >= 600;
            final double targetWidth = isTwoColumns
                ? (constraints.maxWidth - AppSpacing.m) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.m,
              children: actions.map((action) {
                final card = HomeQuickActionCard(
                  icon: action.icon,
                  title: action.title,
                  description: action.description,
                  onTap: action.onTap,
                  backgroundColor: action.backgroundColor,
                  foregroundColor: action.foregroundColor,
                );
                return SizedBox(width: targetWidth, child: card);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Tarjeta informativa con mensaje contextual.
class HomeHighlightsCard extends StatelessWidget {
  const HomeHighlightsCard({
    super.key,
    required this.icon,
    required this.description,
  });

  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.colorScheme.primary),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    HomeStrings.highlightsTitle,
                    style: context.titleMediumBold,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(description, style: context.bodyMediumOnSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Configuración de cada acción rápida.
class HomeQuickActionConfig {
  HomeQuickActionConfig({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

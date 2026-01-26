import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Pantalla de configuración
///
/// Muestra opciones de configuración organizadas en secciones.
/// Sprint 0 - Fase 7: UI completa con Material Design 3
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.settingsTitle),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        children: [
          // Sección de Perfil
          _SettingsSection(
            title: context.l10n.profileSection,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(context.l10n.editProfile),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: editar perfil
                },
              ),
            ],
          ),
          // Sección de Notificaciones
          _SettingsSection(
            title: context.l10n.notificationsSection,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(context.l10n.notificationSettings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: configuración de notificaciones
                },
              ),
            ],
          ),
          // Sección de Apariencia
          _SettingsSection(
            title: context.l10n.appearanceSection,
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(context.l10n.themeSettings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: configuración de tema
                },
              ),
            ],
          ),
          // Sección de Cuenta
          _SettingsSection(
            title: context.l10n.accountSection,
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: context.colorScheme.error),
                title: Text(
                  context.l10n.logout,
                  style: TextStyle(color: context.colorScheme.error),
                ),
                onTap: () {
                  // Placeholder: cerrar sesión
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.inDevelopment,
                      style: context.titleSmallBold,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      context.l10n.futureFeatures,
                      style: context.bodySmallOnSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para agrupar opciones de configuración en secciones
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.l,
            AppSpacing.m,
            AppSpacing.s,
          ),
          child: Text(
            title,
            style: context.titleSmallBold?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(children: children),
        ),
      ],
    );
  }
}

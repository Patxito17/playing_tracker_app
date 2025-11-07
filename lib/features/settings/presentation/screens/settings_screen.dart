import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
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
      appBar: const CustomAppBar(title: SettingsStrings.settingsTitle),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        children: [
          // Sección de Perfil
          _SettingsSection(
            title: SettingsStrings.profileSection,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(SettingsStrings.editProfile),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: editar perfil
                },
              ),
            ],
          ),
          // Sección de Notificaciones
          _SettingsSection(
            title: SettingsStrings.notificationsSection,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(SettingsStrings.notificationSettings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: configuración de notificaciones
                },
              ),
            ],
          ),
          // Sección de Apariencia
          _SettingsSection(
            title: SettingsStrings.appearanceSection,
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(SettingsStrings.themeSettings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: configuración de tema
                },
              ),
            ],
          ),
          // Sección de Cuenta
          _SettingsSection(
            title: SettingsStrings.accountSection,
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: context.colorScheme.error),
                title: Text(
                  SettingsStrings.logout,
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
                      SettingsStrings.inDevelopment,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      SettingsStrings.futureFeatures,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
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
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/domain/enums/user_role.dart';
import '../../../classes/domain/repositories/class_repository.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

/// Pantalla de configuración avanzada
///
/// Permite al usuario personalizar idioma, tema, color y editar su perfil.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.settingsTitle),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return ListView(
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
                    onTap: () => _showEditProfileDialog(context),
                  ),
                ],
              ),

              // Sección de Apariencia
              _SettingsSection(
                title: context.l10n.appearanceSection,
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_6_outlined),
                    title: Text(context.l10n.themeSettings),
                    subtitle: Text(
                      _getThemeModeLabel(context, settingsState.themeMode),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showThemeSelector(context, settingsState.themeMode),
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(context.l10n.colorSettings),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showColorPicker(context, settingsState.seedColor),
                  ),
                ],
              ),

              // Sección de Idioma
              _SettingsSection(
                title: context.l10n.languageSection,
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(context.l10n.languageSettings),
                    subtitle: Text(
                      _getLocaleLabel(context, settingsState.locale),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showLanguageSelector(context, settingsState.locale),
                  ),
                ],
              ),

              // Sección de General
              _SettingsSection(
                title: context.l10n.generalSection,
                children: [
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(context.l10n.termsAndConditionsLink),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final locale =
                          settingsState.locale?.languageCode ??
                          Localizations.localeOf(context).languageCode;
                      final langSuffix = locale == 'es' ? 'es' : 'en';
                      context.push(
                        '/legal',
                        extra: {
                          'title': context.l10n.termsAndConditionsTitle,
                          'assetPath': 'assets/legal/terms_$langSuffix.md',
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(context.l10n.privacyPolicyLink),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final locale =
                          settingsState.locale?.languageCode ??
                          Localizations.localeOf(context).languageCode;
                      final langSuffix = locale == 'es' ? 'es' : 'en';
                      context.push(
                        '/legal',
                        extra: {
                          'title': context.l10n.privacyPolicyTitle,
                          'assetPath': 'assets/legal/privacy_$langSuffix.md',
                        },
                      );
                    },
                  ),
                ],
              ),

              // Sección de Cuenta
              _SettingsSection(
                title: context.l10n.accountSection,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: context.colorScheme.error,
                    ),
                    title: Text(
                      context.l10n.logout,
                      style: TextStyle(color: context.colorScheme.error),
                    ),
                    onTap: () => context.read<AuthCubit>().logout(),
                  ),
                ],
              ),

              // Footer con versión
              const SizedBox(height: AppSpacing.m),
              Center(
                child: Text(
                  context.l10n.versionLabel('1.0.0'),
                  style: context.bodySmallOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
            ],
          );
        },
      ),
    );
  }

  String _getThemeModeLabel(BuildContext context, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => context.l10n.themeLight,
      ThemeMode.dark => context.l10n.themeDark,
      ThemeMode.system => context.l10n.themeSystem,
    };
  }

  String _getLocaleLabel(BuildContext context, Locale? locale) {
    if (locale == null) return context.l10n.languageSystem;
    return switch (locale.languageCode) {
      'es' => context.l10n.languageSpanish,
      'en' => context.l10n.languageEnglish,
      _ => context.l10n.languageSystem,
    };
  }

  void _showThemeSelector(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.themeSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              dialogContext,
              ThemeMode.light,
              context.l10n.themeLight,
              currentMode,
            ),
            _buildThemeOption(
              context,
              dialogContext,
              ThemeMode.dark,
              context.l10n.themeDark,
              currentMode,
            ),
            _buildThemeOption(
              context,
              dialogContext,
              ThemeMode.system,
              context.l10n.themeSystem,
              currentMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    BuildContext dialogContext,
    ThemeMode mode,
    String label,
    ThemeMode currentMode,
  ) {
    return ListTile(
      title: Text(label),
      trailing: currentMode == mode ? const Icon(Icons.check) : null,
      onTap: () {
        context.read<SettingsCubit>().updateThemeMode(mode);
        Navigator.of(dialogContext).pop();
      },
    );
  }

  void _showLanguageSelector(BuildContext context, Locale? currentLocale) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.languageSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Opción: Automático (Sistema)
            _buildLocaleOption(
              context,
              dialogContext,
              null,
              context.l10n.languageSystem,
              currentLocale,
            ),
            _buildLocaleOption(
              context,
              dialogContext,
              const Locale('es'),
              context.l10n.languageSpanish,
              currentLocale,
            ),
            _buildLocaleOption(
              context,
              dialogContext,
              const Locale('en'),
              context.l10n.languageEnglish,
              currentLocale,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocaleOption(
    BuildContext context,
    BuildContext dialogContext,
    Locale? locale,
    String label,
    Locale? currentLocale,
  ) {
    final isSelected = locale == currentLocale;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        context.read<SettingsCubit>().updateLocale(locale);
        Navigator.of(dialogContext).pop();
      },
    );
  }

  void _showColorPicker(BuildContext context, Color? currentColor) {
    final colors = {
      context.l10n.colorBlue: const Color(0xFF1E88E5),
      context.l10n.colorPurple: const Color(0xFF9C27B0),
      context.l10n.colorGreen: const Color(0xFF43A047),
      context.l10n.colorOrange: const Color(0xFFFF9800),
      context.l10n.colorRed: const Color(0xFFF44336),
    };

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.colorSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: colors.entries.map((entry) {
            return ListTile(
              leading: CircleAvatar(backgroundColor: entry.value, radius: 16),
              title: Text(entry.key),
              trailing: currentColor == entry.value
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                context.read<SettingsCubit>().updateSeedColor(entry.value);
                Navigator.of(dialogContext).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final firstNameController = TextEditingController(
      text: authState.firstName,
    );
    final lastNameController = TextEditingController(text: authState.lastName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.editProfileTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: context.l10n.firstNameLabel,
                hintText: context.l10n.firstNameHint,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: context.l10n.lastNameLabel,
                hintText: context.l10n.lastNameHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final firstName = firstNameController.text.trim();
              final lastName = lastNameController.text.trim();

              if (firstName.isEmpty || lastName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.errorEmptyFields),
                    backgroundColor: context.colorScheme.error,
                  ),
                );
                return;
              }

              Navigator.of(dialogContext).pop();

              // Actualizar el perfil
              await context.read<AuthCubit>().updateProfile(
                firstName: firstName,
                lastName: lastName,
              );

              if (context.mounted) {
                final authState = context.read<AuthCubit>().state;
                if (authState is AuthAuthenticated) {
                  // Propagamos el cambio de nombre a las membresías existentes
                  // Lo hacemos de forma "silenciosa" para la UI principal, pero asegurando consistencia
                  try {
                    await context.read<ClassRepository>().updateUserReferences(
                      userId: authState.userId,
                      newName: '$firstName $lastName',
                      isTeacher: authState.role == UserRole.teacher,
                    );
                  } catch (e) {
                    // Logueamos pero no interrumpimos el flow del usuario
                    debugPrint('Error propagando nombre: $e');
                  }
                }
              }
            },
            child: Text(context.l10n.save),
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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/domain/enums/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
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
            padding: const EdgeInsets.only(
              top: AppSpacing.s,
              bottom: AppSpacing.xxl,
            ),
            children: [
              // Sección de Perfil
              _SettingsSection(
                title: context.l10n.profileSection,
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: context.colorScheme.primary,
                    title: context.l10n.editProfile,
                    onTap: () => _showEditProfileDialog(context),
                  ),
                ],
              ),

              // Sección de Apariencia
              _SettingsSection(
                title: context.l10n.appearanceSection,
                children: [
                  _SettingsTile(
                    icon: Icons.brightness_6_outlined,
                    iconColor: context.colorScheme.secondary,
                    title: context.l10n.themeSettings,
                    subtitle: _getThemeModeLabel(
                      context,
                      settingsState.themeMode,
                    ),
                    onTap: () =>
                        _showThemeSelector(context, settingsState.themeMode),
                  ),
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    iconColor: context.colorScheme.tertiary,
                    title: context.l10n.colorSettings,
                    subtitle: _getColorLabel(context, settingsState.seedColor),
                    trailing: settingsState.seedColor != null
                        ? _ColorDot(color: settingsState.seedColor!)
                        : null,
                    onTap: () =>
                        _showColorPicker(context, settingsState.seedColor),
                  ),
                ],
              ),

              // Sección de Idioma
              _SettingsSection(
                title: context.l10n.languageSection,
                children: [
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    iconColor: context.colorScheme.primary,
                    title: context.l10n.languageSettings,
                    subtitle: _getLocaleLabel(context, settingsState.locale),
                    onTap: () =>
                        _showLanguageSelector(context, settingsState.locale),
                  ),
                ],
              ),

              // Sección General
              _SettingsSection(
                title: context.l10n.generalSection,
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: context.colorScheme.secondary,
                    title: context.l10n.tutorialRepeatTitle,
                    subtitle: context.l10n.tutorialRepeatSubtitle,
                    onTap: () async {
                      final authState = context.read<AuthCubit>().state;
                      if (authState is! AuthAuthenticated) return;
                      final cubit = context.read<SettingsCubit>();
                      if (authState.role == UserRole.teacher) {
                        await cubit.resetTeacherTutorial();
                        if (context.mounted) context.go(AppRoutes.teacherHome);
                      } else {
                        await cubit.resetStudentTutorial();
                        if (context.mounted) context.go(AppRoutes.studentHome);
                      }
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    iconColor: context.colorScheme.onSurfaceVariant,
                    title: context.l10n.termsAndConditionsLink,
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
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: context.colorScheme.onSurfaceVariant,
                    title: context.l10n.privacyPolicyLink,
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
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    iconColor: context.colorScheme.error,
                    title: context.l10n.logout,
                    titleColor: context.colorScheme.error,
                    showTrailing: false,
                    onTap: () => context.read<AuthCubit>().logout(),
                  ),
                ],
              ),

              // Footer con versión
              const SizedBox(height: AppSpacing.l),
              Center(
                child: Text(
                  context.l10n.versionLabel('1.0.0'),
                  style: context.bodySmallOnSurfaceVariant,
                ),
              ),
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

  String _getColorLabel(BuildContext context, Color? color) {
    if (color == null) return context.l10n.themeSystem;
    return switch (color.toARGB32()) {
      0xFF1E88E5 => context.l10n.colorBlue,
      0xFF9C27B0 => context.l10n.colorPurple,
      0xFF43A047 => context.l10n.colorGreen,
      0xFFFF9800 => context.l10n.colorOrange,
      0xFFF44336 => context.l10n.colorRed,
      _ => context.l10n.colorBlue,
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
              Icons.light_mode_outlined,
              currentMode,
            ),
            _buildThemeOption(
              context,
              dialogContext,
              ThemeMode.dark,
              context.l10n.themeDark,
              Icons.dark_mode_outlined,
              currentMode,
            ),
            _buildThemeOption(
              context,
              dialogContext,
              ThemeMode.system,
              context.l10n.themeSystem,
              Icons.brightness_auto_outlined,
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
    IconData icon,
    ThemeMode currentMode,
  ) {
    final isSelected = currentMode == mode;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: context.colorScheme.primary)
          : null,
      selected: isSelected,
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
            _buildLocaleOption(
              context,
              dialogContext,
              null,
              context.l10n.languageSystem,
              Icons.brightness_auto_outlined,
              currentLocale,
            ),
            _buildLocaleOption(
              context,
              dialogContext,
              const Locale('es'),
              context.l10n.languageSpanish,
              Icons.language_rounded,
              currentLocale,
            ),
            _buildLocaleOption(
              context,
              dialogContext,
              const Locale('en'),
              context.l10n.languageEnglish,
              Icons.language_rounded,
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
    IconData icon,
    Locale? currentLocale,
  ) {
    final isSelected = locale == currentLocale;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: context.colorScheme.primary)
          : null,
      selected: isSelected,
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
            final isSelected = currentColor == entry.value;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: entry.value,
                radius: 16,
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              title: Text(entry.key),
              trailing: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: context.colorScheme.primary,
                    )
                  : null,
              selected: isSelected,
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

              await context.read<AuthCubit>().updateProfile(
                firstName: firstName,
                lastName: lastName,
              );

              if (context.mounted) {
                final updatedState = context.read<AuthCubit>().state;
                if (updatedState is AuthAuthenticated) {
                  try {
                    await context.read<ClassRepository>().updateUserReferences(
                      userId: updatedState.userId,
                      newName: '$firstName $lastName',
                      isTeacher: updatedState.role == UserRole.teacher,
                    );
                  } catch (e, stackTrace) {
                    log(
                      'Error propagando nombre tras actualización de perfil',
                      error: e,
                      stackTrace: stackTrace,
                      name: 'SettingsScreen',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.classGenericError),
                          backgroundColor: context.colorScheme.error,
                        ),
                      );
                    }
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

/// Sección de ajustes con título y lista de tiles en una Card M3.
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
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
            side: BorderSide(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          color: context.colorScheme.surfaceContainerLow,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children
                .expand(
                  (tile) => [
                    tile,
                    if (tile != children.last)
                      Divider(
                        height: 1,
                        indent: AppSpacing.m + 36 + AppSpacing.m,
                        endIndent: AppSpacing.m,
                        color:
                            context.colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                  ],
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// ListTile estilizado para ajustes con icono en contenedor redondeado.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.showTrailing = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final bool showTrailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: context.textTheme.bodyLarge?.copyWith(color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing ??
          (showTrailing
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: context.colorScheme.onSurfaceVariant,
                  size: 20,
                )
              : null),
      onTap: onTap,
    );
  }
}

/// Punto de color para mostrar el color seleccionado en el tile de paleta.
class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
    );
  }
}

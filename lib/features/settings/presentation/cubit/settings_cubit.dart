import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/settings/data/services/settings_service.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsService) : super(SettingsState.initial()) {
    _loadSettings();
  }

  final SettingsService _settingsService;

  void _loadSettings() {
    final themeMode = _settingsService.getThemeMode();
    final locale = _settingsService.getLocale();
    final seedColor = _settingsService.getSeedColor();

    emit(
      state.copyWith(
        themeMode: themeMode,
        locale: locale,
        seedColor: seedColor,
      ),
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _settingsService.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> updateLocale(Locale locale) async {
    await _settingsService.setLocale(locale);
    emit(state.copyWith(locale: locale));
  }

  Future<void> updateSeedColor(Color color) async {
    await _settingsService.setSeedColor(color);
    emit(state.copyWith(seedColor: color));
  }
}

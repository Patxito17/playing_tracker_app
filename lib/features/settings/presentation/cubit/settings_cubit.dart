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
    final locale = _settingsService.getLocale(); // Puede ser null (automático)
    final seedColor = _settingsService.getSeedColor();

    emit(
      state.copyWith(
        themeMode: themeMode,
        locale:
            locale, // null = automático, se pasa correctamente con el sentinel
        seedColor: seedColor,
      ),
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _settingsService.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  /// Actualiza el idioma seleccionado. Pasa [null] para activar la detección
  /// automática del idioma del sistema.
  Future<void> updateLocale(Locale? locale) async {
    await _settingsService.setLocale(locale);
    emit(state.copyWith(locale: locale));
  }

  Future<void> updateSeedColor(Color color) async {
    await _settingsService.setSeedColor(color);
    emit(state.copyWith(seedColor: color));
  }

  // ---------------------------------------------------------------------------
  // Tutorial de primera ejecución
  // ---------------------------------------------------------------------------

  bool isStudentTutorialDone() => _settingsService.isStudentTutorialDone();
  Future<void> markStudentTutorialDone() =>
      _settingsService.markStudentTutorialDone();
  Future<void> resetStudentTutorial() => _settingsService.resetStudentTutorial();

  bool isTeacherTutorialDone() => _settingsService.isTeacherTutorialDone();
  Future<void> markTeacherTutorialDone() =>
      _settingsService.markTeacherTutorialDone();
  Future<void> resetTeacherTutorial() => _settingsService.resetTeacherTutorial();
}

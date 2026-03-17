import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/settings/data/services/settings_service.dart';

import 'settings_state.dart';

/// Cubit responsable de gestionar las preferencias persistentes del usuario.
///
/// Coordina las operaciones de lectura y escritura de ajustes a través de
/// [SettingsService] (basado en `shared_preferences`) y emite un nuevo
/// [SettingsState] con cada cambio. Se inicializa cargando automáticamente
/// los valores guardados en disco al construirse.
///
/// Gestiona tres categorías de preferencias:
/// - **Apariencia**: modo de tema ([ThemeMode]) y color semilla ([Color]).
/// - **Idioma**: locale activo o detección automática del sistema.
/// - **Tutorial**: estado de completado del tutorial para cada rol (alumno/docente).
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsService) : super(SettingsState.initial()) {
    _loadSettings();
  }

  final SettingsService _settingsService;

  /// Carga los ajustes persistidos y emite el estado inicial hidratado.
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

  /// Persiste y aplica el modo de tema seleccionado por el usuario.
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

  /// Persiste y aplica el color semilla para la paleta de Material Design 3.
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
  Future<void> resetStudentTutorial() async {
    await _settingsService.resetStudentTutorial();
    emit(state.copyWith(tutorialResetVersion: state.tutorialResetVersion + 1));
  }

  bool isTeacherTutorialDone() => _settingsService.isTeacherTutorialDone();
  Future<void> markTeacherTutorialDone() =>
      _settingsService.markTeacherTutorialDone();
  Future<void> resetTeacherTutorial() async {
    await _settingsService.resetTeacherTutorial();
    emit(state.copyWith(tutorialResetVersion: state.tutorialResetVersion + 1));
  }
}

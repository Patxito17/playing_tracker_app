import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para persistir configuraciones locales (Tema, Idioma, Color).
class SettingsService {
  static const String _themeModeKey = 'settings_theme_mode';
  static const String _localeCodeKey = 'settings_locale_code';
  static const String _seedColorKey = 'settings_seed_color';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  /// Inicializa el servicio asincrónicamente.
  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  /// Lee el modo de tema guardado. Por defecto: [ThemeMode.system].
  ThemeMode getThemeMode() {
    final value = _prefs.getString(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Guarda el modo de tema.
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_themeModeKey, value);
  }

  /// Lee el código de idioma guardado. Retorna `null` si no hay ninguno
  /// guardado, lo que indica que se debe usar el idioma del sistema.
  Locale? getLocale() {
    final code = _prefs.getString(_localeCodeKey);
    if (code == null) return null;
    return Locale(code);
  }

  /// Guarda el código de idioma. Si [locale] es `null`, borra la preferencia
  /// para que la app use la detección automática del sistema.
  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_localeCodeKey);
    } else {
      await _prefs.setString(_localeCodeKey, locale.languageCode);
    }
  }

  /// Lee el color semilla guardado (valor int ARGB). Retorna null si no hay guardado (usar default).
  Color? getSeedColor() {
    final value = _prefs.getInt(_seedColorKey);
    if (value == null) return null;
    return Color(value);
  }

  /// Guarda el color semilla.
  Future<void> setSeedColor(Color color) async {
    await _prefs.setInt(_seedColorKey, color.toARGB32());
  }
}

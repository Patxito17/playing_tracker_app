import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Sentinel para distinguir "no se pasó locale" de "se pasó null explícitamente"
/// en el método [SettingsState.copyWith].
const _kNoLocale = Object();

class SettingsState extends Equatable {
  const SettingsState({required this.themeMode, this.locale, this.seedColor});

  final ThemeMode themeMode;

  /// Idioma seleccionado por el usuario. Si es `null`, la app usa el idioma
  /// del sistema operativo de forma automática.
  final Locale? locale;

  final Color? seedColor;

  factory SettingsState.initial() {
    return const SettingsState(
      themeMode: ThemeMode.system,
      locale: null, // null = detección automática del sistema
      seedColor: null,
    );
  }

  /// Permite actualizar campos de forma selectiva. Para borrar [locale]
  /// (establecer detección automática) pasa `locale: null` —se detecta
  /// con [clearLocale: true] para distinguirlo del caso "no cambiar".
  SettingsState copyWith({
    ThemeMode? themeMode,
    Object? locale = _kNoLocale,
    Color? seedColor,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale == _kNoLocale ? this.locale : locale as Locale?,
      seedColor: seedColor ?? this.seedColor,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, seedColor];
}

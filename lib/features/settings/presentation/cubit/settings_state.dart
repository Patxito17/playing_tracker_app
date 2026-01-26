import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.themeMode,
    required this.locale,
    this.seedColor,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final Color? seedColor;

  factory SettingsState.initial() {
    return const SettingsState(
      themeMode: ThemeMode.system,
      locale: Locale('es'),
      seedColor: null, // null usa el color por defecto del tema
    );
  }

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    Color? seedColor,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      seedColor: seedColor ?? this.seedColor,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, seedColor];
}

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Sentinel para distinguir "no se pasó locale" de "se pasó null explícitamente"
/// en el método [SettingsState.copyWith].
const _kNoLocale = Object();

/// Estado inmutable de ajustes de usuario gestionado por [SettingsCubit].
///
/// Agrupa las tres categorías de preferencias: apariencia (tema y color),
/// idioma y estado de tutoriales. Todas las modificaciones crean una nueva
/// instancia mediante [copyWith].
class SettingsState extends Equatable {
  const SettingsState({
    required this.themeMode,
    this.locale,
    this.seedColor,
    this.tutorialResetVersion = 0,
    this.studentTutorialDone = false,
    this.teacherTutorialDone = false,
  });

  /// Modo de tema activo (claro, oscuro o sistema).
  final ThemeMode themeMode;

  /// Idioma seleccionado por el usuario. Si es `null`, la app usa el idioma
  /// del sistema operativo de forma automática.
  final Locale? locale;

  /// Color semilla para generar la paleta de Material Design 3.
  /// Null significa usar el color semilla por defecto de la app.
  final Color? seedColor;

  /// Versión incrementada cada vez que se reinicia un tutorial desde Ajustes.
  /// Las pantallas de inicio escuchan este campo para re-disparar el tutorial.
  final int tutorialResetVersion;

  /// Indica si el tutorial del alumno ya fue completado.
  final bool studentTutorialDone;

  /// Indica si el tutorial del docente ya fue completado.
  final bool teacherTutorialDone;

  /// Estado inicial por defecto: tema del sistema, idioma automático y tutoriales pendientes.
  factory SettingsState.initial() {
    return const SettingsState(
      themeMode: ThemeMode.system,
      locale: null, // null = detección automática del sistema
      seedColor: null,
      tutorialResetVersion: 0,
      studentTutorialDone: false,
      teacherTutorialDone: false,
    );
  }

  /// Permite actualizar campos de forma selectiva. Para borrar [locale]
  /// (establecer detección automática) pasa `locale: null` —se detecta
  /// con `clearLocale: true` para distinguirlo del caso "no cambiar".
  SettingsState copyWith({
    ThemeMode? themeMode,
    Object? locale = _kNoLocale,
    Color? seedColor,
    int? tutorialResetVersion,
    bool? studentTutorialDone,
    bool? teacherTutorialDone,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale == _kNoLocale ? this.locale : locale as Locale?,
      seedColor: seedColor ?? this.seedColor,
      tutorialResetVersion:
          tutorialResetVersion ?? this.tutorialResetVersion,
      studentTutorialDone: studentTutorialDone ?? this.studentTutorialDone,
      teacherTutorialDone: teacherTutorialDone ?? this.teacherTutorialDone,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    locale,
    seedColor,
    tutorialResetVersion,
    studentTutorialDone,
    teacherTutorialDone,
  ];
}

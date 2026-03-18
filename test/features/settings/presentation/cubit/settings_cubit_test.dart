// Tests del SettingsCubit.
//
// Cubre: cambio de tema, cambio de idioma, color semilla, y gestión del estado
// del tutorial para alumno y docente (campos studentTutorialDone /
// teacherTutorialDone introducidos recientemente).
//
// Mecanismo general: se mockea SettingsService con mocktail y se verifica que
// SettingsCubit emite los estados correctos ante cada acción.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/settings/data/services/settings_service.dart';
import 'package:playing_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:playing_tracker/features/settings/presentation/cubit/settings_state.dart';

class _MockSettingsService extends Mock implements SettingsService {}

void main() {
  late _MockSettingsService mockService;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(const Locale('es'));
    registerFallbackValue(const Color(0xFF000000));
  });

  // Configura el mock con valores por defecto para todos los getters de lectura
  // que se invocan en el constructor de SettingsCubit (_loadSettings).
  setUp(() {
    mockService = _MockSettingsService();

    when(() => mockService.getThemeMode()).thenReturn(ThemeMode.system);
    when(() => mockService.getLocale()).thenReturn(null);
    when(() => mockService.getSeedColor()).thenReturn(null);
    when(() => mockService.isStudentTutorialDone()).thenReturn(false);
    when(() => mockService.isTeacherTutorialDone()).thenReturn(false);
  });

  group('SettingsCubit — inicialización', () {
    // Mecanismo: al construir el cubit, _loadSettings() lee todos los ajustes
    //            del servicio y emite un estado hidratado.
    // Entradas: servicio devuelve ThemeMode.dark, locale 'es', sin color semilla.
    // Salida esperada: estado con los valores recuperados.
    test(
      'carga ajustes persistidos al inicializarse',
      () {
        when(() => mockService.getThemeMode()).thenReturn(ThemeMode.dark);
        when(
          () => mockService.getLocale(),
        ).thenReturn(const Locale('es'));

        final cubit = SettingsCubit(mockService);
        addTearDown(cubit.close);

        expect(cubit.state.themeMode, ThemeMode.dark);
        expect(cubit.state.locale, const Locale('es'));
      },
    );

    // Mecanismo: sin ajustes guardados el cubit debe tener el estado inicial.
    // Entradas: todos los getters devuelven valores por defecto.
    // Salida esperada: themeMode == system, locale == null.
    test(
      'estado inicial es SettingsState.initial cuando no hay ajustes guardados',
      () {
        final cubit = SettingsCubit(mockService);
        addTearDown(cubit.close);

        expect(cubit.state.themeMode, ThemeMode.system);
        expect(cubit.state.locale, isNull);
        expect(cubit.state.seedColor, isNull);
        expect(cubit.state.studentTutorialDone, isFalse);
        expect(cubit.state.teacherTutorialDone, isFalse);
      },
    );
  });

  group('SettingsCubit — cambio de tema', () {
    // Mecanismo: updateThemeMode persiste y emite el nuevo ThemeMode.
    // Entradas: ThemeMode.light.
    // Salida esperada: estado emitido con themeMode == light.
    blocTest<SettingsCubit, SettingsState>(
      'emite estado con ThemeMode.light al llamar updateThemeMode(light)',
      setUp: () {
        when(
          () => mockService.setThemeMode(any()),
        ).thenAnswer((_) async {});
      },
      build: () => SettingsCubit(mockService),
      act: (cubit) => cubit.updateThemeMode(ThemeMode.light),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.themeMode, 'themeMode', ThemeMode.light),
      ],
      verify: (_) {
        verify(() => mockService.setThemeMode(ThemeMode.light)).called(1);
      },
    );

    // Mecanismo: cambio a dark mode.
    // Entradas: ThemeMode.dark.
    // Salida esperada: estado con themeMode == dark.
    blocTest<SettingsCubit, SettingsState>(
      'emite estado con ThemeMode.dark al llamar updateThemeMode(dark)',
      setUp: () {
        when(
          () => mockService.setThemeMode(any()),
        ).thenAnswer((_) async {});
      },
      build: () => SettingsCubit(mockService),
      act: (cubit) => cubit.updateThemeMode(ThemeMode.dark),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.themeMode, 'themeMode', ThemeMode.dark),
      ],
    );
  });

  group('SettingsCubit — cambio de idioma', () {
    // Mecanismo: updateLocale persiste y emite la nueva Locale.
    // Entradas: Locale('es').
    // Salida esperada: estado con locale == Locale('es').
    blocTest<SettingsCubit, SettingsState>(
      "emite estado con locale 'es' al llamar updateLocale(Locale('es'))",
      setUp: () {
        when(
          () => mockService.setLocale(any()),
        ).thenAnswer((_) async {});
      },
      build: () => SettingsCubit(mockService),
      act: (cubit) => cubit.updateLocale(const Locale('es')),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.locale, 'locale', const Locale('es')),
      ],
      verify: (_) {
        verify(() => mockService.setLocale(const Locale('es'))).called(1);
      },
    );

    // Mecanismo: desde locale='es', pasar null activa la detección automática.
    // Entradas: locale inicial == 'es' (simulado), llamada con null.
    // Salida esperada: el cubit persiste null y vuelve a locale == null.
    blocTest<SettingsCubit, SettingsState>(
      'emite estado con locale null (automático) al llamar updateLocale(null)',
      setUp: () {
        // Simula que el servicio tiene guardado el locale 'es' para que el estado
        // inicial sea Locale('es') y el cambio a null produzca una emisión.
        when(() => mockService.getLocale()).thenReturn(const Locale('es'));
        when(() => mockService.setLocale(any())).thenAnswer((_) async {});
        when(() => mockService.setLocale(null)).thenAnswer((_) async {});
      },
      build: () => SettingsCubit(mockService),
      act: (cubit) => cubit.updateLocale(null),
      expect: () => [
        isA<SettingsState>().having((s) => s.locale, 'locale', isNull),
      ],
      verify: (_) {
        verify(() => mockService.setLocale(null)).called(1);
      },
    );
  });

  group('SettingsCubit — color semilla', () {
    // Mecanismo: updateSeedColor persiste y emite el nuevo color.
    // Entradas: Colors.blue.
    // Salida esperada: estado con seedColor == Colors.blue.
    blocTest<SettingsCubit, SettingsState>(
      'emite estado con seedColor al llamar updateSeedColor',
      setUp: () {
        when(
          () => mockService.setSeedColor(any()),
        ).thenAnswer((_) async {});
      },
      build: () => SettingsCubit(mockService),
      act: (cubit) => cubit.updateSeedColor(Colors.blue),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.seedColor, 'seedColor', Colors.blue),
      ],
      verify: (_) {
        verify(() => mockService.setSeedColor(Colors.blue)).called(1);
      },
    );
  });

  group('SettingsCubit — tutorial alumno', () {
    // Mecanismo: markStudentTutorialDone persiste y emite studentTutorialDone = true.
    // Entradas: estado inicial con studentTutorialDone = false.
    // Salida esperada: estado con studentTutorialDone = true.
    blocTest<SettingsCubit, SettingsState>(
      'emite studentTutorialDone=true al llamar markStudentTutorialDone',
      setUp: () {
        when(
          () => mockService.markStudentTutorialDone(),
        ).thenAnswer((_) async {});
      },
      build: () => SettingsCubit(mockService),
      act: (cubit) => cubit.markStudentTutorialDone(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.studentTutorialDone, 'studentTutorialDone', true),
      ],
      verify: (_) {
        verify(() => mockService.markStudentTutorialDone()).called(1);
      },
    );

    // Mecanismo: resetStudentTutorial restablece el flag y lo marca como false.
    // Entradas: estado con studentTutorialDone = true (simulado).
    // Salida esperada: estado con studentTutorialDone = false,
    //                  tutorialResetVersion incrementado.
    blocTest<SettingsCubit, SettingsState>(
      'emite studentTutorialDone=false y tutorialResetVersion+1 al resetear tutorial alumno',
      setUp: () {
        when(() => mockService.isStudentTutorialDone()).thenReturn(true);
        when(
          () => mockService.resetStudentTutorial(),
        ).thenAnswer((_) async {});
      },
      build: () => SettingsCubit(mockService),
      act: (cubit) => cubit.resetStudentTutorial(),
      expect: () => [
        isA<SettingsState>()
            .having(
              (s) => s.studentTutorialDone,
              'studentTutorialDone',
              false,
            )
            .having(
              (s) => s.tutorialResetVersion,
              'tutorialResetVersion',
              1,
            ),
      ],
    );
  });

  group('SettingsCubit — tutorial docente', () {
    // Mecanismo: markTeacherTutorialDone persiste y emite teacherTutorialDone = true.
    // Entradas: estado inicial con teacherTutorialDone = false.
    // Salida esperada: estado con teacherTutorialDone = true.
    blocTest<SettingsCubit, SettingsState>(
      'emite teacherTutorialDone=true al llamar markTeacherTutorialDone',
      setUp: () {
        when(
          () => mockService.markTeacherTutorialDone(),
        ).thenAnswer((_) async {});
      },
      build: () => SettingsCubit(mockService),
      act: (cubit) => cubit.markTeacherTutorialDone(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.teacherTutorialDone, 'teacherTutorialDone', true),
      ],
      verify: (_) {
        verify(() => mockService.markTeacherTutorialDone()).called(1);
      },
    );

    // Mecanismo: resetTeacherTutorial restablece el flag y lo marca como false.
    // Entradas: estado con teacherTutorialDone = true (simulado).
    // Salida esperada: estado con teacherTutorialDone = false,
    //                  tutorialResetVersion incrementado.
    blocTest<SettingsCubit, SettingsState>(
      'emite teacherTutorialDone=false y tutorialResetVersion+1 al resetear tutorial docente',
      setUp: () {
        when(() => mockService.isTeacherTutorialDone()).thenReturn(true);
        when(
          () => mockService.resetTeacherTutorial(),
        ).thenAnswer((_) async {});
      },
      build: () => SettingsCubit(mockService),
      act: (cubit) => cubit.resetTeacherTutorial(),
      expect: () => [
        isA<SettingsState>()
            .having(
              (s) => s.teacherTutorialDone,
              'teacherTutorialDone',
              false,
            )
            .having(
              (s) => s.tutorialResetVersion,
              'tutorialResetVersion',
              1,
            ),
      ],
    );
  });

  group('SettingsCubit — helpers de lectura', () {
    // Mecanismo: los getters sincrónicos delegan en el estado actual.
    // Entradas: servicio devuelve true para ambos tutoriales.
    // Salida esperada: los getters del cubit devuelven true.
    test('isStudentTutorialDone devuelve el valor del estado actual', () {
      when(() => mockService.isStudentTutorialDone()).thenReturn(true);

      final cubit = SettingsCubit(mockService);
      addTearDown(cubit.close);

      expect(cubit.isStudentTutorialDone(), isTrue);
    });

    test('isTeacherTutorialDone devuelve el valor del estado actual', () {
      when(() => mockService.isTeacherTutorialDone()).thenReturn(true);

      final cubit = SettingsCubit(mockService);
      addTearDown(cubit.close);

      expect(cubit.isTeacherTutorialDone(), isTrue);
    });
  });
}

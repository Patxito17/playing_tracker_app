import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'core/extensions/context_extensions.dart';
import 'core/constants/app_constants.dart';

/// Punto de entrada de la aplicación Playing Tracker
///
/// Sprint 0 - Fase 2: Integración del sistema de tema Material Design 3
void main() {
  runApp(const PlayingTrackerApp());
}

/// Widget raíz de la aplicación
///
/// Gestiona el tema actual (claro/oscuro) y proporciona el MaterialApp
/// configurado con los temas de Material Design 3.
class PlayingTrackerApp extends StatefulWidget {
  const PlayingTrackerApp({super.key});

  @override
  State<PlayingTrackerApp> createState() => _PlayingTrackerAppState();
}

class _PlayingTrackerAppState extends State<PlayingTrackerApp> {
  /// Modo de tema actual (claro u oscuro)
  ///
  /// Este toggle es temporal y será reemplazado en futuros sprints
  /// con una configuración persistente usando SharedPreferences o similar.
  ThemeMode _themeMode = ThemeMode.light;

  /// Alterna entre tema claro y oscuro
  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playing Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: ThemeTestScreen(
        onToggleTheme: _toggleTheme,
        currentThemeMode: _themeMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Pantalla de prueba para verificar el tema Material Design 3
///
/// Muestra diferentes componentes M3 para validar que el tema
/// se aplica correctamente en ambos modos (claro y oscuro).
class ThemeTestScreen extends StatelessWidget {
  /// Callback para alternar el tema
  final VoidCallback onToggleTheme;

  /// Modo de tema actual
  final ThemeMode currentThemeMode;

  const ThemeTestScreen({
    super.key,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playing Tracker - Tema M3'),
        actions: [
          // Toggle temporal para cambiar entre tema claro y oscuro
          IconButton(
            icon: Icon(
              currentThemeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: onToggleTheme,
            tooltip: currentThemeMode == ThemeMode.light
                ? 'Cambiar a tema oscuro'
                : 'Cambiar a tema claro',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de tipografía
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipografía M3',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Display Large',
                      style: context.textTheme.displayLarge,
                    ),
                    Text(
                      'Headline Medium',
                      style: context.textTheme.headlineMedium,
                    ),
                    Text('Body Large', style: context.textTheme.bodyLarge),
                    Text('Label Small', style: context.textTheme.labelSmall),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.m),

            // Sección de botones M3
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Botones M3', style: context.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.m),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Filled Button'),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('Filled Tonal Button'),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Outlined Button'),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Text Button'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.m),

            // Sección de campos de texto M3
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campos de Texto M3',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Campo de texto',
                        hintText: 'Escribe algo aquí',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Campo con error',
                        errorText: 'Este campo tiene un error',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.m),

            // Sección de colores del tema
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paleta de Colores',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _ColorSwatch(
                      label: 'Primary',
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _ColorSwatch(
                      label: 'Secondary',
                      color: context.colorScheme.secondary,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _ColorSwatch(
                      label: 'Surface',
                      color: context.colorScheme.surface,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _ColorSwatch(
                      label: 'Error',
                      color: context.colorScheme.error,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget auxiliar para mostrar una muestra de color
class _ColorSwatch extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorSwatch({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
            border: Border.all(
              color: context.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: Text(label, style: context.textTheme.bodyMedium)),
      ],
    );
  }
}

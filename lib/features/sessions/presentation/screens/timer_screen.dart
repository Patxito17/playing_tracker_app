import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla de cronómetro para sesiones de estudio
///
/// Muestra un cronómetro grande y visible con controles para iniciar, pausar,
/// reiniciar y finalizar sesiones de estudio. Incluye información de la tarea actual.
///
/// Sprint 0 - Fase 9: UI completa con Material Design 3
class TimerScreen extends StatefulWidget {
  final String taskId;

  const TimerScreen({super.key, required this.taskId});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // Estado del cronómetro: idle, running, paused
  TimerState _timerState = TimerState.idle;
  int _elapsedSeconds = 0;

  // Datos mock de la tarea
  Map<String, dynamic> _getMockTaskData() {
    return {
      'id': widget.taskId,
      'title': 'Escala de Do Mayor',
      'description':
          'Practicar la escala de Do Mayor en todas las octavas. Enfocarse en mantener un tempo constante y una técnica correcta.',
      'estimatedTime': 30, // minutos
    };
  }

  /// Formatea los segundos en formato HH:MM:SS
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  /// Obtiene el texto del estado del cronómetro
  String _getStateText() {
    switch (_timerState) {
      case TimerState.idle:
        return SessionStrings.idle;
      case TimerState.running:
        return SessionStrings.running;
      case TimerState.paused:
        return SessionStrings.paused;
    }
  }

  /// Obtiene el color del estado del cronómetro
  Color _getStateColor() {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_timerState) {
      case TimerState.idle:
        return colorScheme.outline;
      case TimerState.running:
        return colorScheme.primary;
      case TimerState.paused:
        return colorScheme.secondary;
    }
  }

  /// Inicia el cronómetro
  void _startTimer() {
    setState(() {
      _timerState = TimerState.running;
    });
    // Placeholder: aquí iría la lógica real del cronómetro
  }

  /// Pausa el cronómetro
  void _pauseTimer() {
    setState(() {
      _timerState = TimerState.paused;
    });
    // Placeholder: aquí iría la lógica real del cronómetro
  }

  /// Reanuda el cronómetro
  void _resumeTimer() {
    setState(() {
      _timerState = TimerState.running;
    });
    // Placeholder: aquí iría la lógica real del cronómetro
  }

  /// Reinicia el cronómetro
  void _resetTimer() {
    setState(() {
      _timerState = TimerState.idle;
      _elapsedSeconds = 0;
    });
    // Placeholder: aquí iría la lógica real del cronómetro
  }

  /// Finaliza la sesión y navega de vuelta
  void _finishSession() {
    // Placeholder: aquí se guardaría la sesión en la base de datos
    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskData = _getMockTaskData();
    final estimatedTime = taskData['estimatedTime'] as int;

    return Scaffold(
      appBar: const CustomAppBar(title: SessionStrings.timerTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cronómetro grande y visible
            CustomCard(
              child: Column(
                children: [
                  // Tiempo transcurrido
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: context.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Estado del cronómetro
                  Chip(
                    label: Text(_getStateText()),
                    backgroundColor: _getStateColor().withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: _getStateColor(),
                      fontWeight: FontWeight.w600,
                    ),
                    avatar: Icon(
                      _getStateIcon(),
                      size: 16,
                      color: _getStateColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            // Información de la tarea actual
            CustomCard(
              title: SessionStrings.currentTask,
              subtitle: taskData['title'] as String,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s),
                  _InfoRow(
                    icon: Icons.description_outlined,
                    label: SessionStrings.taskName,
                    value: taskData['title'] as String,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: SessionStrings.estimatedTimeLabel,
                    value: '$estimatedTime ${TaskStrings.minutes}',
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _InfoRow(
                    icon: Icons.timer_outlined,
                    label: SessionStrings.elapsedTime,
                    value: _formatTime(_elapsedSeconds),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Controles del cronómetro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón iniciar/reanudar
                if (_timerState == TimerState.idle)
                  CustomButton(
                    label: SessionStrings.start,
                    variant: CustomButtonVariant.filled,
                    icon: Icons.play_arrow,
                    onPressed: _startTimer,
                  )
                else if (_timerState == TimerState.paused)
                  CustomButton(
                    label: SessionStrings.resume,
                    variant: CustomButtonVariant.filled,
                    icon: Icons.play_arrow,
                    onPressed: _resumeTimer,
                  ),
                // Botón pausar (solo cuando está corriendo)
                if (_timerState == TimerState.running) ...[
                  const SizedBox(width: AppSpacing.m),
                  CustomButton(
                    label: SessionStrings.pause,
                    variant: CustomButtonVariant.outlined,
                    icon: Icons.pause,
                    onPressed: _pauseTimer,
                  ),
                ],
                // Botón reiniciar (cuando está pausado o corriendo)
                if (_timerState != TimerState.idle) ...[
                  const SizedBox(width: AppSpacing.m),
                  CustomButton(
                    label: SessionStrings.reset,
                    variant: CustomButtonVariant.outlined,
                    icon: Icons.refresh,
                    onPressed: _resetTimer,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            // Botón finalizar sesión
            CustomButton(
              label: SessionStrings.finish,
              variant: CustomButtonVariant.filled,
              icon: Icons.check_circle_outline,
              onPressed: _finishSession,
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el icono del estado del cronómetro
  IconData _getStateIcon() {
    switch (_timerState) {
      case TimerState.idle:
        return Icons.timer_outlined;
      case TimerState.running:
        return Icons.play_circle_outline;
      case TimerState.paused:
        return Icons.pause_circle_outline;
    }
  }
}

/// Estados del cronómetro
enum TimerState { idle, running, paused }

/// Widget para mostrar una fila de información
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.s),
        Text(
          '$label: ',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

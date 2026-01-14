import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../cubit/session_cubit.dart';
import '../cubit/session_state.dart';

/// Pantalla de cronómetro para sesiones de práctica.
///
/// Características:
/// - Integración completa con [SessionCubit]
/// - Diseño circular con progress indicator animado
/// - Botones de control grandes e intuitivos
/// - Formato de tiempo adaptativo (MM:SS o HH:MM:SS)
/// - Input para notas al finalizar
/// - Animaciones suaves y feedback visual
class TimerScreen extends StatefulWidget {
  final String taskId;
  final String studentId;
  final String teacherId;
  final String taskTitle;

  const TimerScreen({
    super.key,
    required this.taskId,
    required this.studentId,
    required this.teacherId,
    required this.taskTitle,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final _notesController = TextEditingController();
  bool _showNotesInput = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Formatea segundos en MM:SS o HH:MM:SS según la duración
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _handleStart(BuildContext context) async {
    await context.read<SessionCubit>().startSession(
      taskId: widget.taskId,
      studentId: widget.studentId,
      teacherId: widget.teacherId,
    );
  }

  void _handlePause(BuildContext context) {
    context.read<SessionCubit>().pauseSession();
  }

  void _handleResume(BuildContext context) {
    context.read<SessionCubit>().resumeSession();
  }

  Future<void> _handleStop(BuildContext context) async {
    final confirmed = await _showStopConfirmation(context);
    if (confirmed == true && context.mounted) {
      await context.read<SessionCubit>().stopSession();
      if (context.mounted) {
        context.pop();
      }
    }
  }

  Future<void> _handleSave(BuildContext context) async {
    // Pausar el cronómetro mientras el usuario escribe notas
    context.read<SessionCubit>().pauseSession();

    setState(() {
      _showNotesInput = true;
    });
  }

  Future<void> _confirmSave(BuildContext context) async {
    await context.read<SessionCubit>().saveSession(
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  Future<bool?> _showStopConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar sesión?'),
        content: const Text(
          'Perderás todo el progreso de esta sesión de práctica. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
            ),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listener: (context, state) {
        if (state is SessionSuccess) {
          // Mostrar diálogo de éxito premium
          _showSuccessDialog(context, state.duration, state.message);
        } else if (state is SessionError) {
          // Error al guardar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final duration = _getDuration(state);
        final isRunning = state is SessionRunning;
        final isPaused = state is SessionPaused;
        final isIdle = state is SessionInitial;
        final isSaving = state is SessionSaving;

        return PopScope(
          canPop: isIdle,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && (isRunning || isPaused)) {
              await _handleStop(context);
            }
          },
          child: Scaffold(
            appBar: const CustomAppBar(title: SessionStrings.timerTitle),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título de la tarea
                  Text(
                    widget.taskTitle,
                    style: context.headlineMediumBold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Progress circular con tiempo
                  _CircularTimer(
                    duration: duration,
                    isRunning: isRunning,
                    pulseAnimation: _pulseController,
                    formatTime: _formatTime,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Input de notas (si está visible)
                  if (_showNotesInput && !isSaving) ...[
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notas de la sesión (opcional)',
                        hintText: 'Escribe aquí tus observaciones...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.medium,
                          ),
                        ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                  ],

                  // Botones de control
                  if (isSaving)
                    const Center(child: CircularProgressIndicator())
                  else if (_showNotesInput)
                    _buildSaveButtons(context)
                  else
                    _buildControlButtons(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _getDuration(SessionState state) {
    if (state is SessionRunning) return state.duration;
    if (state is SessionPaused) return state.duration;
    if (state is SessionSaving) return state.duration;
    return 0;
  }

  Widget _buildControlButtons(BuildContext context, SessionState state) {
    final isIdle = state is SessionInitial;
    final isRunning = state is SessionRunning;
    final isPaused = state is SessionPaused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón principal (Start/Pause/Resume)
        if (isIdle)
          _BigButton(
            label: SessionStrings.start,
            icon: Icons.play_arrow_rounded,
            color: context.colorScheme.primary,
            onPressed: () => _handleStart(context),
          )
        else if (isRunning)
          _BigButton(
            label: SessionStrings.pause,
            icon: Icons.pause_rounded,
            color: context.colorScheme.tertiary,
            onPressed: () => _handlePause(context),
          )
        else if (isPaused)
          _BigButton(
            label: SessionStrings.resume,
            icon: Icons.play_arrow_rounded,
            color: context.colorScheme.primary,
            onPressed: () => _handleResume(context),
          ),

        if (!isIdle) ...[
          const SizedBox(height: AppSpacing.m),

          // Botones secundarios
          Row(
            children: [
              // Botón Stop
              Expanded(
                flex: 3,
                child: CustomButton(
                  label: 'Descartar',
                  icon: Icons.close_rounded,
                  variant: CustomButtonVariant.outlined,
                  onPressed: () => _handleStop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              // Botón Save
              Expanded(
                flex: 5,
                child: CustomButton(
                  label: 'Guardar sesión',
                  icon: Icons.check_rounded,
                  variant: CustomButtonVariant.filled,
                  onPressed: () => _handleSave(context),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: 'Cancelar',
            variant: CustomButtonVariant.outlined,
            onPressed: () {
              setState(() {
                _showNotesInput = false;
                _notesController.clear();
              });
            },
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          flex: 2,
          child: CustomButton(
            label: 'Confirmar y guardar',
            icon: Icons.save_rounded,
            variant: CustomButtonVariant.filled,
            onPressed: () => _confirmSave(context),
          ),
        ),
      ],
    );
  }

  /// Muestra un diálogo de éxito premium con el resumen de la sesión
  void _showSuccessDialog(BuildContext context, int duration, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: context.colorScheme.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text('¡Sesión Guardada!', style: context.titleLargeBold),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.bodyMediumOnSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.l),
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: context.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    'Tiempo practicado: ${_formatTime(duration)}',
                    style: context.titleMediumBold?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                context.pop(); // Volver a la pantalla anterior
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              ),
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón grande para acciones principales
class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _BigButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(red: math.min(color.r + 0.1, 1.0)),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.l,
              horizontal: AppSpacing.xl,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.white),
                const SizedBox(width: AppSpacing.m),
                Text(
                  label,
                  style: context.titleLargeBold?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget circular con progress indicator y tiempo
class _CircularTimer extends StatelessWidget {
  final int duration;
  final bool isRunning;
  final Animation<double> pulseAnimation;
  final String Function(int) formatTime;

  const _CircularTimer({
    required this.duration,
    required this.isRunning,
    required this.pulseAnimation,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          final scale = isRunning ? 1.0 + (pulseAnimation.value * 0.05) : 1.0;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primaryContainer,
                    context.colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress indicator circular
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: isRunning ? null : 0,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation(
                        context.colorScheme.primary,
                      ),
                      backgroundColor: context.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),

                  // Tiempo en el centro
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(duration),
                        style: context.displayLargeBold?.copyWith(
                          fontSize: 48,
                          color: context.colorScheme.onPrimaryContainer,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          isRunning
                              ? 'En progreso...'
                              : duration > 0
                              ? 'Pausado'
                              : 'Listo para empezar',
                          key: ValueKey(
                            isRunning
                                ? 'running'
                                : duration > 0
                                ? 'paused'
                                : 'idle',
                          ),
                          style: context.bodyMediumOnSurface?.copyWith(
                            color: context.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

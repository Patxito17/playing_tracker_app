import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../cubit/session_cubit.dart';
import '../cubit/session_state.dart';

/// Pantalla de cronómetro para sesiones de práctica.
///
/// Características:
/// - Integración completa con [SessionCubit]
/// - Diseño circular con progress indicator animado y pulse
/// - Botones de control grandes con gradiente Material 3
/// - Formato de tiempo adaptativo (MM:SS o HH:MM:SS)
/// - Input para notas al finalizar
/// - Wakelock para mantener la pantalla encendida
class TimerScreen extends StatefulWidget {
  final String taskId;
  final String studentId;
  final String teacherId;
  final String taskTitle;
  final String? className;
  final String? classId;

  const TimerScreen({
    super.key,
    required this.taskId,
    required this.studentId,
    required this.teacherId,
    required this.taskTitle,
    this.className,
    this.classId,
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
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
      classId: widget.classId,
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
      if (context.mounted) context.pop();
    }
  }

  Future<void> _handleSave(BuildContext context) async {
    context.read<SessionCubit>().pauseSession();
    setState(() => _showNotesInput = true);
  }

  Future<void> _confirmSave(BuildContext context) async {
    await context.read<SessionCubit>().saveSession(
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      taskTitle: widget.taskTitle,
      className: widget.className,
    );
  }

  Future<bool?> _showStopConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.discardSessionTitle),
        content: Text(context.l10n.discardSessionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
            ),
            child: Text(context.l10n.discardAction),
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
          _showSuccessDialog(context, state.duration, state.message);
        } else if (state is SessionError) {
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
            appBar: CustomAppBar(title: context.l10n.timerTitle),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.m,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nombre de la tarea
                    Text(
                      widget.taskTitle,
                      style: context.headlineMediumBold,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.className != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.className!,
                        style: context.bodyMediumOnSurfaceVariant,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),

                    // Cronómetro circular
                    _CircularTimer(
                      duration: duration,
                      isRunning: isRunning,
                      pulseAnimation: _pulseController,
                      formatTime: _formatTime,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Input de notas
                    if (_showNotesInput && !isSaving) ...[
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: context.l10n.notesLabel,
                          hintText: context.l10n.notesHint,
                          prefixIcon: const Icon(Icons.notes_outlined),
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
        // Botón principal
        if (isIdle)
          _BigButton(
            label: context.l10n.timerStart,
            icon: Icons.play_arrow_rounded,
            color: context.colorScheme.primary,
            onColor: context.colorScheme.onPrimary,
            onPressed: () => _handleStart(context),
          )
        else if (isRunning)
          _BigButton(
            label: context.l10n.timerPause,
            icon: Icons.pause_rounded,
            color: context.colorScheme.tertiary,
            onColor: context.colorScheme.onTertiary,
            onPressed: () => _handlePause(context),
          )
        else if (isPaused)
          _BigButton(
            label: context.l10n.timerResume,
            icon: Icons.play_arrow_rounded,
            color: context.colorScheme.primary,
            onColor: context.colorScheme.onPrimary,
            onPressed: () => _handleResume(context),
          ),

        if (!isIdle) ...[
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _handleStop(context),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(context.l10n.discardAction),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colorScheme.error,
                    side: BorderSide(
                      color: context.colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                flex: 5,
                child: FilledButton.icon(
                  onPressed: () => _handleSave(context),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(context.l10n.save),
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
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _showNotesInput = false;
                _notesController.clear();
              });
            },
            child: Text(context.l10n.cancel),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () => _confirmSave(context),
            icon: const Icon(Icons.save_rounded),
            label: Text(context.l10n.confirmAndSaveAction),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    int duration,
    String message,
  ) {
    showDialog<void>(
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
                color: context.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: context.colorScheme.onPrimaryContainer,
                size: 64,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(context.l10n.sessionSavedTitle, style: context.titleLargeBold),
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.m,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
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
                    context.l10n.timePracticedLabel(_formatTime(duration)),
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
                Navigator.of(context).pop();
                context.pop();
              },
              child: Text(context.l10n.continueAction),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón grande con gradiente para acciones principales del cronómetro.
class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color onColor;
  final VoidCallback onPressed;

  const _BigButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onColor,
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
            blurRadius: 16,
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
                Icon(icon, size: 32, color: onColor),
                const SizedBox(width: AppSpacing.m),
                Text(
                  label,
                  style: context.titleLargeBold?.copyWith(color: onColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cronómetro circular animado con estado visual.
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
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                        duration: AppDurations.medium,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            ),
                        child: Text(
                          isRunning
                              ? context.l10n.runningStatus
                              : duration > 0
                              ? context.l10n.pausedStatus
                              : context.l10n.readyToStartStatus,
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

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/sessions/domain/repositories/session_repository.dart';
import 'package:playing_tracker/features/sessions/domain/utils/timer_ticker.dart';
import 'package:playing_tracker/features/sessions/presentation/cubit/session_state.dart';

/// Cubit que gestiona el cronómetro de sesiones de práctica.
///
/// Características principales:
/// - Control del cronómetro (start, pause, resume, stop)
/// - Integración con [TimerTicker] para emisión de ticks
/// - Manejo del ciclo de vida de la app (background/foreground)
/// - Persistencia de sesiones en Firebase
/// - Pausa automática cuando la app va a background para seguridad del alumno
///
/// Ejemplo de uso:
/// ```dart
/// final cubit = SessionCubit(repository);
///
/// // Iniciar una sesión
/// await cubit.startSession(
///   taskId: 'task-123',
///   studentId: 'student-456',
///   teacherId: 'teacher-789',
/// );
///
/// // Pausar
/// cubit.pauseSession();
///
/// // Reanudar
/// cubit.resumeSession();
///
/// // Guardar
/// await cubit.saveSession(notes: 'Práctica de escalas');
/// ```
final class SessionCubit extends Cubit<SessionState>
    with WidgetsBindingObserver {
  SessionCubit(this._repository, {TimerTicker? ticker})
    : _ticker = ticker ?? TimerTicker(),
      super(const SessionInitial()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final SessionRepository _repository;
  final TimerTicker _ticker;
  StreamSubscription<int>? _tickerSubscription;

  /// Inicia una nueva sesión de práctica.
  ///
  /// [taskId] es el identificador de la tarea a practicar.
  /// [studentId] es el identificador del estudiante.
  /// [teacherId] es el identificador del docente dueño de la tarea.
  /// [notes] son notas opcionales para la sesión.
  ///
  /// Si ya hay una sesión activa, no hace nada.
  Future<void> startSession({
    required String taskId,
    required String studentId,
    required String teacherId,
    String? classId,
    String? notes,
  }) async {
    // Validaciones
    if (taskId.trim().isEmpty ||
        studentId.trim().isEmpty ||
        teacherId.trim().isEmpty) {
      emit(
        const SessionError(
          message: 'Los IDs de tarea, estudiante y docente son obligatorios',
        ),
      );
      return;
    }

    // Si ya hay una sesión activa, no permitir iniciar otra
    final currentState = state;
    if (currentState is SessionRunning || currentState is SessionPaused) {
      emit(
        const SessionError(
          message: 'Ya hay una sesión activa. Detén la sesión actual primero.',
        ),
      );
      return;
    }

    try {
      // Resetear el ticker
      _ticker.start(reset: true);

      // Suscribirse a los ticks
      await _tickerSubscription?.cancel();
      _tickerSubscription = _ticker.tick.listen(_onTick);

      // Emitir estado inicial con duración 0
      emit(
        SessionRunning(
          taskId: taskId,
          studentId: studentId,
          teacherId: teacherId,
          classId: classId,
          duration: 0,
          notes: notes,
        ),
      );

      log('SessionCubit: Sesión iniciada para tarea $taskId');
    } catch (error, stackTrace) {
      log(
        'SessionCubit: Error al iniciar sesión',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        SessionError(message: 'No fue posible iniciar la sesión', cause: error),
      );
    }
  }

  /// Pausa la sesión actual.
  ///
  /// Detiene el ticker pero mantiene la duración actual.
  /// La sesión puede reanudarse con [resumeSession].
  void pauseSession() {
    final currentState = state;
    if (currentState is! SessionRunning) {
      return;
    }

    _ticker.pause();

    emit(
      SessionPaused(
        taskId: currentState.taskId,
        studentId: currentState.studentId,
        teacherId: currentState.teacherId,
        classId: currentState.classId,
        duration: currentState.duration,
        notes: currentState.notes,
      ),
    );

    log('SessionCubit: Sesión pausada en ${currentState.duration}s');
  }

  /// Reanuda una sesión pausada.
  ///
  /// Solo funciona si el estado actual es [SessionPaused].
  void resumeSession() {
    final currentState = state;
    if (currentState is! SessionPaused) {
      return;
    }

    _ticker.start(reset: false);

    emit(
      SessionRunning(
        taskId: currentState.taskId,
        studentId: currentState.studentId,
        teacherId: currentState.teacherId,
        classId: currentState.classId,
        duration: currentState.duration,
        notes: currentState.notes,
      ),
    );

    log('SessionCubit: Sesión reanudada desde ${currentState.duration}s');
  }

  /// Detiene la sesión sin guardarla.
  ///
  /// Cancela el ticker y vuelve al estado inicial.
  /// La sesión se pierde y no se guarda en Firebase.
  Future<void> stopSession() async {
    _ticker.stop();
    await _tickerSubscription?.cancel();
    _tickerSubscription = null;

    emit(const SessionInitial());
    log('SessionCubit: Sesión detenida sin guardar');
  }

  /// Guarda la sesión actual en Firebase.
  ///
  /// [notes] son notas opcionales a agregar/actualizar en la sesión.
  /// [taskTitle] es el título de la tarea (campo denormalizado).
  /// [className] es el nombre de la clase (campo denormalizado).
  ///
  /// Detiene el cronómetro, crea un [SessionModel] y lo persiste
  /// usando el [SessionRepository].
  Future<void> saveSession({
    String? notes,
    String? taskTitle,
    String? className,
  }) async {
    final currentState = state;

    // Solo se puede guardar desde Running o Paused
    if (currentState is! SessionRunning && currentState is! SessionPaused) {
      emit(
        const SessionError(message: 'No hay una sesión activa para guardar'),
      );
      return;
    }

    // Obtener datos del estado actual
    final String taskId;
    final String studentId;
    final String teacherId;
    final String? classId;
    final int duration;
    String? sessionNotes;

    if (currentState is SessionRunning) {
      taskId = currentState.taskId;
      studentId = currentState.studentId;
      teacherId = currentState.teacherId;
      classId = currentState.classId;
      duration = currentState.duration;
      sessionNotes = notes ?? currentState.notes;
    } else if (currentState is SessionPaused) {
      taskId = currentState.taskId;
      studentId = currentState.studentId;
      teacherId = currentState.teacherId;
      classId = currentState.classId;
      duration = currentState.duration;
      sessionNotes = notes ?? currentState.notes;
    } else {
      emit(const SessionError(message: 'Estado inválido'));
      return;
    }

    // Validar que haya al menos 1 segundo de duración
    if (duration < 1) {
      emit(
        const SessionError(
          message: 'La sesión debe durar al menos 1 segundo para guardarse',
        ),
      );
      return;
    }

    emit(SessionSaving(duration: duration));

    try {
      // Detener el ticker
      _ticker.stop();
      await _tickerSubscription?.cancel();
      _tickerSubscription = null;

      // Crear el modelo de sesión
      final now = Timestamp.now();
      final startTime = Timestamp.fromDate(
        DateTime.now().subtract(Duration(seconds: duration)),
      );

      final session = SessionModel(
        id: '${studentId}_${taskId}_${now.millisecondsSinceEpoch}',
        studentId: studentId,
        taskId: taskId,
        teacherId: teacherId,
        classId: classId,
        startTime: startTime,
        endTime: now,
        totalDuration: duration,
        pausedDuration: 0, // Por ahora no manejamos pausa interna
        dateLogged: now,
        monthBucket: SessionModel.generateMonthBucket(now),
        notes: sessionNotes,
        taskTitle: taskTitle,
        className: className,
        status: SessionStatus.completed,
        createdAt: now,
      );

      // Guardar en el repositorio
      await _repository.createSession(session);

      // Emitir éxito
      emit(
        SessionSuccess(
          duration: duration,
          message: 'Sesión guardada exitosamente',
        ),
      );

      log('SessionCubit: Sesión guardada exitosamente - ${duration}s');
    } on SessionRepositoryException catch (error) {
      log('SessionCubit: Error del repositorio al guardar', error: error);
      emit(SessionError(message: error.message, cause: error));
    } catch (error, stackTrace) {
      log(
        'SessionCubit: Error inesperado al guardar',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        SessionError(message: 'No fue posible guardar la sesión', cause: error),
      );
    }
  }

  /// Callback cuando el ticker emite un nuevo segundo.
  void _onTick(int elapsedSeconds) {
    final currentState = state;
    if (currentState is SessionRunning) {
      emit(currentState.copyWith(duration: elapsedSeconds));
    }
  }

  /// Manejo del ciclo de vida de la app.
  ///
  /// Cuando la app va a background, pausa automáticamente la sesión.
  /// Cuando vuelve a foreground, la sesión permanece pausada para que el
  /// alumno la reanude manualmente.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);

    final currentState = state;

    // Solo manejar ciclo de vida si hay una sesión activa
    if (currentState is! SessionRunning && currentState is! SessionPaused) {
      return;
    }

    switch (lifecycleState) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // App va a background - guardar timestamp
        _handleAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        // App vuelve a foreground - recalcular tiempo
        _handleAppForegrounded();
        break;
      case AppLifecycleState.hidden:
        // Estado hidden (nuevo en Flutter 3.13+)
        _handleAppBackgrounded();
        break;
    }
  }

  /// Maneja cuando la app va a background.
  ///
  /// Si la sesión está corriendo, la pausa automáticamente y cambia el estado
  /// a [SessionPaused]. Esto evita que los alumnos pierdan tiempo accidentalmente
  /// si olvidan pausar antes de salir de la app.
  void _handleAppBackgrounded() {
    final currentState = state;

    if (currentState is SessionRunning) {
      // Pausar automáticamente el ticker
      _ticker.pause();

      // Cambiar el estado a pausado
      emit(
        SessionPaused(
          taskId: currentState.taskId,
          studentId: currentState.studentId,
          teacherId: currentState.teacherId,
          classId: currentState.classId,
          duration: currentState.duration,
          notes: currentState.notes,
        ),
      );

      log(
        'SessionCubit: App en background - pausando automáticamente en ${currentState.duration}s',
      );
    }
    // Si ya estaba pausada, no hacer nada (mantener el estado)
  }

  /// Maneja cuando la app vuelve a foreground.
  ///
  /// La sesión permanece en estado pausado y requiere que el usuario
  /// presione manualmente el botón "Reanudar" para continuar.
  /// Esto garantiza que solo se cuente el tiempo real de práctica.
  void _handleAppForegrounded() {
    log(
      'SessionCubit: App de vuelta a foreground. '
      'La sesión permanece pausada y requiere reanudación manual.',
    );

    // La sesión siempre permanece pausada al volver de background
    // El usuario debe presionar "Reanudar" manualmente para continuar
    // No se agrega tiempo en background a la duración
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    await _tickerSubscription?.cancel();
    _ticker.dispose();
    return super.close();
  }
}

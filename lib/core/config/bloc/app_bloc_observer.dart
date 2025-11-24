import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Métricas agregadas de los Cubits/Blocs activos en la app.
@immutable
class BlocMetrics {
  const BlocMetrics({this.changes = 0, this.transitions = 0, this.errors = 0});

  final int changes;
  final int transitions;
  final int errors;

  BlocMetrics copyWith({int? changes, int? transitions, int? errors}) {
    return BlocMetrics(
      changes: changes ?? this.changes,
      transitions: transitions ?? this.transitions,
      errors: errors ?? this.errors,
    );
  }

  @override
  String toString() =>
      'BlocMetrics(changes: $changes, transitions: $transitions, errors: $errors)';
}

/// Registro in-memory para exponer un snapshot de las métricas.
final class BlocMetricsRecorder {
  BlocMetricsRecorder._();

  static final BlocMetricsRecorder instance = BlocMetricsRecorder._();

  BlocMetrics _metrics = const BlocMetrics();

  BlocMetrics get snapshot => _metrics;

  void incrementChange() =>
      _update(_metrics.copyWith(changes: _metrics.changes + 1));

  void incrementTransition() =>
      _update(_metrics.copyWith(transitions: _metrics.transitions + 1));

  void incrementError() =>
      _update(_metrics.copyWith(errors: _metrics.errors + 1));

  void _update(BlocMetrics next) {
    _metrics = next;
  }
}

/// Observer global que registra transiciones y errores relevantes.
final class AppBlocObserver extends BlocObserver {
  AppBlocObserver({BlocMetricsRecorder? recorder})
    : _recorder = recorder ?? BlocMetricsRecorder.instance;

  final BlocMetricsRecorder _recorder;

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('Bloc creado: ${bloc.runtimeType}', name: _logName);
  }

  @override
  void onChange(BlocBase bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _recorder.incrementChange();
    log(
      '[Change ${_recorder.snapshot.changes}] ${bloc.runtimeType}: '
      '${change.currentState.runtimeType} → ${change.nextState.runtimeType}',
      name: _logName,
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _recorder.incrementTransition();
    log(
      '[Transition ${_recorder.snapshot.transitions}] ${bloc.runtimeType}: '
      '${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}',
      name: _logName,
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _recorder.incrementError();
    log(
      '[Error ${_recorder.snapshot.errors}] ${bloc.runtimeType}: $error',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

const _logName = 'BlocObserver';

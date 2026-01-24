import 'dart:async';

/// Clase auxiliar que emite ticks periódicos para implementar un cronómetro.
///
/// El `TimerTicker` genera un stream que emite eventos cada segundo,
/// permitiendo implementar cronómetros y temporizadores de forma reactiva.
///
/// Características principales:
/// - Emisión de ticks cada segundo (configurable)
/// - Stream broadcast para múltiples suscriptores
/// - Control mediante start/stop
/// - Limpieza automática de recursos
///
/// Ejemplo de uso:
/// ```dart
/// final ticker = TimerTicker();
///
/// // Escuchar los ticks
/// final subscription = ticker.tick.listen((elapsed) {
///   print('Segundos transcurridos: $elapsed');
/// });
///
/// // Detener el ticker
/// ticker.dispose();
/// subscription.cancel();
/// ```
class TimerTicker {
  /// Crea una instancia de [TimerTicker].
  ///
  /// El parámetro [tickInterval] permite configurar el intervalo entre ticks.
  /// Por defecto es de 1 segundo.
  TimerTicker({Duration tickInterval = const Duration(seconds: 1)})
    : _tickInterval = tickInterval;

  final Duration _tickInterval;
  StreamController<int>? _controller;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isActive = false;

  /// Stream que emite el número de segundos transcurridos.
  ///
  /// Cada tick incrementa el contador de segundos y emite el nuevo valor.
  /// El stream es broadcast, permitiendo múltiples suscriptores.
  Stream<int> get tick {
    _controller ??= StreamController<int>.broadcast(
      onListen: _onListen,
      onCancel: _onCancel,
    );
    return _controller!.stream;
  }

  /// Indica si el ticker está actualmente activo (emitiendo ticks).
  bool get isActive => _isActive;

  /// Número de segundos transcurridos desde el inicio.
  int get elapsed => _elapsedSeconds;

  /// Inicia o reanuda la emisión de ticks.
  ///
  /// Si el ticker ya está activo, no hace nada.
  /// Si [reset] es true, reinicia el contador a 0.
  void start({bool reset = false}) {
    if (_isActive) return;

    if (reset) {
      _elapsedSeconds = 0;
    }

    _isActive = true;
    _startTimer();
  }

  /// Pausa la emisión de ticks sin reiniciar el contador.
  ///
  /// El contador mantiene su valor actual y puede reanudarse con [start].
  void pause() {
    if (!_isActive) return;

    _isActive = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Detiene el ticker y reinicia el contador a 0.
  ///
  /// Equivalente a llamar [pause] seguido de reset del contador.
  void stop() {
    pause();
    _elapsedSeconds = 0;
  }

  /// Libera todos los recursos utilizados por el ticker.
  ///
  /// Después de llamar a dispose(), el ticker no puede volver a usarse.
  /// Es importante llamar a este método para evitar memory leaks.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
    _isActive = false;
  }

  /// Inicia el timer interno que emite los ticks.
  void _startTimer() {
    _timer = Timer.periodic(_tickInterval, (_) {
      _elapsedSeconds++;
      _controller?.add(_elapsedSeconds);
    });
  }

  /// Callback cuando se agrega el primer suscriptor al stream.
  void _onListen() {
    // Si el ticker estaba activo cuando se creó el primer listener,
    // asegurarse de que el timer esté corriendo
    if (_isActive && _timer == null) {
      _startTimer();
    }
  }

  /// Callback cuando se cancela el último suscriptor del stream.
  void _onCancel() {
    // Opcional: podrías pausar automáticamente cuando no hay listeners
    // Por ahora, mantenemos el ticker corriendo independientemente
  }
}

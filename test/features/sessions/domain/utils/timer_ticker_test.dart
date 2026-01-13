import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/sessions/domain/utils/timer_ticker.dart';

void main() {
  group('TimerTicker', () {
    late TimerTicker ticker;

    setUp(() {
      ticker = TimerTicker();
    });

    tearDown(() {
      ticker.dispose();
    });

    group('Constructor', () {
      test('crea un ticker con intervalo por defecto de 1 segundo', () {
        expect(ticker, isNotNull);
        expect(ticker.isActive, isFalse);
        expect(ticker.elapsed, 0);
      });

      test('crea un ticker con intervalo personalizado', () {
        final customTicker = TimerTicker(
          tickInterval: const Duration(milliseconds: 500),
        );
        expect(customTicker, isNotNull);
        customTicker.dispose();
      });
    });

    group('Estado inicial', () {
      test('isActive es false al inicio', () {
        expect(ticker.isActive, isFalse);
      });

      test('elapsed es 0 al inicio', () {
        expect(ticker.elapsed, 0);
      });
    });

    group('start()', () {
      test('activa el ticker', () {
        ticker.start();
        expect(ticker.isActive, isTrue);
      });

      test('no hace nada si ya está activo', () {
        ticker.start();
        final firstActive = ticker.isActive;
        ticker.start();
        expect(ticker.isActive, firstActive);
      });

      test('emite ticks en el stream', () async {
        final ticks = <int>[];
        final subscription = ticker.tick.listen(ticks.add);

        ticker.start();

        // Esperar 2.5 segundos para recibir ~2 ticks
        await Future.delayed(const Duration(milliseconds: 2500));

        expect(ticks.length, greaterThanOrEqualTo(2));
        expect(ticks.length, lessThanOrEqualTo(3));
        expect(ticks, [1, 2]); // O [1, 2, 3] dependiendo del timing

        await subscription.cancel();
      });

      test('reinicia el contador cuando reset es true', () async {
        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));
        ticker.pause();

        final elapsedBeforeReset = ticker.elapsed;
        expect(elapsedBeforeReset, greaterThan(0));

        ticker.start(reset: true);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(ticker.elapsed, lessThan(elapsedBeforeReset));
      });

      test('no reinicia el contador cuando reset es false', () async {
        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));
        ticker.pause();

        final elapsedBeforeContinue = ticker.elapsed;
        ticker.start(reset: false);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(ticker.elapsed, greaterThanOrEqualTo(elapsedBeforeContinue));
      });
    });

    group('pause()', () {
      test('desactiva el ticker', () async {
        ticker.start();
        await Future.delayed(const Duration(milliseconds: 500));
        ticker.pause();

        expect(ticker.isActive, isFalse);
      });

      test('mantiene el contador actual', () async {
        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));

        final elapsedBeforePause = ticker.elapsed;
        ticker.pause();

        expect(ticker.elapsed, elapsedBeforePause);
      });

      test('detiene la emisión de ticks', () async {
        final ticks = <int>[];
        final subscription = ticker.tick.listen(ticks.add);

        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));

        ticker.pause();
        final ticksAtPause = ticks.length;

        // Esperar más tiempo después de pausar
        await Future.delayed(const Duration(milliseconds: 1500));

        // No deberían haber más ticks
        expect(ticks.length, ticksAtPause);

        await subscription.cancel();
      });

      test('no hace nada si el ticker no está activo', () {
        ticker.pause();
        expect(ticker.isActive, isFalse);
      });
    });

    group('stop()', () {
      test('desactiva el ticker', () async {
        ticker.start();
        await Future.delayed(const Duration(milliseconds: 500));
        ticker.stop();

        expect(ticker.isActive, isFalse);
      });

      test('reinicia el contador a 0', () async {
        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));

        ticker.stop();

        expect(ticker.elapsed, 0);
      });
    });

    group('Stream tick', () {
      test('es broadcast y permite múltiples suscriptores', () async {
        final ticks1 = <int>[];
        final ticks2 = <int>[];

        final subscription1 = ticker.tick.listen(ticks1.add);
        final subscription2 = ticker.tick.listen(ticks2.add);

        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));

        expect(ticks1.length, greaterThan(0));
        expect(ticks2.length, greaterThan(0));
        expect(ticks1, equals(ticks2));

        await subscription1.cancel();
        await subscription2.cancel();
      });

      test('emite valores incrementales', () async {
        final ticks = <int>[];
        final subscription = ticker.tick.listen(ticks.add);

        ticker.start();
        await Future.delayed(const Duration(milliseconds: 3500));

        // Verificar que los valores son secuenciales
        for (int i = 0; i < ticks.length - 1; i++) {
          expect(ticks[i + 1], equals(ticks[i] + 1));
        }

        await subscription.cancel();
      });

      test('continúa desde el valor actual al reanudar', () async {
        final ticks = <int>[];
        final subscription = ticker.tick.listen(ticks.add);

        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));

        final lastTickBeforePause = ticks.isNotEmpty ? ticks.last : 0;
        ticker.pause();

        await Future.delayed(const Duration(milliseconds: 1000));

        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));

        // El primer tick después de reanudar debe ser mayor que el último antes de pausar
        final firstTickAfterResume = ticks.firstWhere(
          (tick) => tick > lastTickBeforePause,
          orElse: () => -1,
        );

        expect(firstTickAfterResume, greaterThan(lastTickBeforePause));

        await subscription.cancel();
      });
    });

    group('dispose()', () {
      test('cierra el stream controller', () async {
        final subscription = ticker.tick.listen((_) {});
        ticker.start();

        await Future.delayed(const Duration(milliseconds: 500));

        ticker.dispose();

        // Verificar que el stream está cerrado esperando su finalización
        await expectLater(subscription.asFuture(), completes);
      });

      test('cancela el timer interno', () async {
        ticker.start();
        await Future.delayed(const Duration(milliseconds: 500));

        ticker.dispose();

        expect(ticker.isActive, isFalse);
      });

      test('puede llamarse múltiples veces de forma segura', () {
        ticker.dispose();
        expect(() => ticker.dispose(), returnsNormally);
      });
    });

    group('Intervalos personalizados', () {
      test('emite ticks con intervalo personalizado', () async {
        final fastTicker = TimerTicker(
          tickInterval: const Duration(milliseconds: 100),
        );

        final ticks = <int>[];
        final subscription = fastTicker.tick.listen(ticks.add);

        fastTicker.start();
        await Future.delayed(const Duration(milliseconds: 550));

        // Con intervalo de 100ms, en 550ms deberían haber ~5 ticks
        expect(ticks.length, greaterThanOrEqualTo(4));
        expect(ticks.length, lessThanOrEqualTo(6));

        await subscription.cancel();
        fastTicker.dispose();
      });
    });

    group('Casos límite', () {
      test('puede pausar y reanudar múltiples veces', () async {
        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));

        ticker.pause();
        await Future.delayed(const Duration(milliseconds: 500));

        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));

        ticker.pause();
        await Future.delayed(const Duration(milliseconds: 500));

        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1500));

        expect(ticker.elapsed, greaterThan(0));
      });

      test('mantiene estado consistente después de stop y start', () async {
        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1000));

        ticker.stop();
        expect(ticker.elapsed, 0);
        expect(ticker.isActive, isFalse);

        ticker.start();
        await Future.delayed(const Duration(milliseconds: 1000));

        expect(ticker.elapsed, greaterThan(0));
        expect(ticker.isActive, isTrue);
      });
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';

/// Overlay modal que bloquea la interacción mientras muestra un indicador de carga
///
/// Implementa accesibilidad completa mediante:
/// - `Semantics(liveRegion: true)`: TalkBack/VoiceOver anuncia el inicio de carga.
/// - `ExcludeSemantics`: bloquea la navegación semántica al contenido subyacente.
/// - Anuncio de "Carga completada" al desaparecer (vía [showLoadingOverlay]).
///
/// **Ejemplo como widget en Stack:**
/// ```dart
/// Stack(
///   children: [
///     MyContent(),
///     if (isLoading) LoadingOverlay(message: 'Cargando...'),
///   ],
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Mensaje opcional a mostrar debajo del indicador
  final String? message;

  /// Color de fondo del overlay (por defecto usa el del tema con opacidad)
  final Color? backgroundColor;

  const LoadingOverlay({super.key, this.message, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final overlayColor =
        backgroundColor ?? context.colorScheme.surface.withValues(alpha: 0.8);
    final loadingLabel = message ?? 'Cargando';

    return Semantics(
      // liveRegion: true → TalkBack/VoiceOver anunciará este nodo
      // automáticamente cuando aparezca sin que el usuario lo enfoque.
      liveRegion: true,
      label: loadingLabel,
      child: AbsorbPointer(
        child: Container(
          color: overlayColor,
          child: ExcludeSemantics(
            // ExcludeSemantics bloquea la navegación semántica hacia
            // el contenido detrás del overlay mientras carga.
            // El nodo padre (Semantics arriba) sigue siendo anunciable.
            excluding: false, // El propio spinner no necesita ser navegable.
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicador de carga
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colorScheme.primary,
                    ),
                  ),

                  // Mensaje opcional
                  if (message != null) ...[
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      message!,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Muestra un overlay de carga modal sobre la pantalla actual
///
/// Acepta un [Future] opcional. Cuando el Future termina, se cierra el overlay
/// y se anuncia "Carga completada" a los lectores de pantalla vía
/// [SemanticsService.sendAnnouncement], guiando al usuario de herramienta asistiva.
///
/// **Ejemplo básico:**
/// ```dart
/// await showLoadingOverlay(
///   context,
///   message: 'Guardando...',
///   completionMessage: 'Guardado completado',
///   future: saveData(),
/// );
/// ```
///
/// **Ejemplo sin Future (cierre manual):**
/// ```dart
/// showLoadingOverlay(context, message: 'Cargando...');
/// await doWork();
/// hideLoadingOverlay(context);
/// ```
Future<T?> showLoadingOverlay<T>(
  BuildContext context, {
  String? message,
  String? completionMessage,
  Color? backgroundColor,
  Future<T>? future,
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (_) =>
        LoadingOverlay(message: message, backgroundColor: backgroundColor),
  );

  if (future != null) {
    T? result;
    try {
      result = await future;
    } finally {
      if (context.mounted) {
        hideLoadingOverlay(context);
        // Anunciar al lector de pantalla que la carga ha terminado.
        // sendAnnouncement requiere el FlutterView obtenido via View.of(context).
        final announcement = completionMessage ?? 'Carga completada';
        SemanticsService.sendAnnouncement(
          View.of(context),
          announcement,
          TextDirection.ltr,
        );
      }
    }
    return result;
  }
  return null;
}

/// Oculta el overlay de carga si está visible
///
/// **Ejemplo de uso:**
/// ```dart
/// hideLoadingOverlay(context);
/// ```
void hideLoadingOverlay(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';

/// Overlay modal que bloquea la interacción mientras muestra un indicador de carga
///
/// Muestra un overlay que cubre toda la pantalla con un indicador de carga
/// y opcionalmente un mensaje. Bloquea toda la interacción mientras está visible.
///
/// **Ejemplo de uso:**
/// ```dart
/// // Mostrar overlay simple
/// showLoadingOverlay(context);
///
/// // Mostrar overlay con mensaje
/// showLoadingOverlay(context, message: 'Cargando datos...');
///
/// // Ocultar overlay (normalmente se hace automáticamente con Navigator.pop)
/// Navigator.of(context).pop();
/// ```
///
/// También se puede usar como widget dentro de un Stack:
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

    return AbsorbPointer(
      child: Container(
        color: overlayColor,
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
    );
  }
}

/// Muestra un overlay de carga modal sobre la pantalla actual
///
/// **Ejemplo de uso:**
/// ```dart
/// // Mostrar overlay
/// showLoadingOverlay(context, message: 'Guardando...');
///
/// // Realizar operación asíncrona
/// await saveData();
///
/// // Ocultar overlay
/// Navigator.of(context).pop();
/// ```
///
/// **Nota:** Recuerda llamar `Navigator.of(context).pop()` cuando termines
/// la operación para ocultar el overlay.
void showLoadingOverlay(
  BuildContext context, {
  String? message,
  Color? backgroundColor,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) =>
        LoadingOverlay(message: message, backgroundColor: backgroundColor),
  );
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

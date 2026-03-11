import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';

/// Variantes de botón disponibles en Material Design 3
enum CustomButtonVariant {
  /// Botón con fondo sólido (FilledButton)
  filled,

  /// Botón con borde (OutlinedButton)
  outlined,

  /// Botón de texto plano (TextButton)
  text,
}

/// Botón personalizado que encapsula los estilos Material Design 3
///
/// Proporciona una API consistente para crear botones con diferentes variantes
/// y estados. Soporta tres variantes M3: filled, outlined y text.
///
/// **Ejemplo de uso:**
/// ```dart
/// // Botón filled con texto
/// CustomButton(
///   label: 'Enviar',
///   onPressed: () => print('Enviado'),
///   variant: CustomButtonVariant.filled,
/// )
///
/// // Botón outlined con icono y texto
/// CustomButton(
///   label: 'Cancelar',
///   icon: Icons.cancel,
///   onPressed: () => print('Cancelado'),
///   variant: CustomButtonVariant.outlined,
/// )
///
/// // Botón de texto en estado loading
/// CustomButton(
///   label: 'Cargando...',
///   isLoading: true,
///   variant: CustomButtonVariant.text,
/// )
/// ```
class CustomButton extends StatelessWidget {
  /// Texto del botón
  final String label;

  /// Callback que se ejecuta al presionar el botón
  final VoidCallback? onPressed;

  /// Variante del botón (filled, outlined, text)
  final CustomButtonVariant variant;

  /// Icono opcional del botón (IconData)
  final IconData? icon;

  /// Widget prefix opcional (por ejemplo logo de Google como imagen)
  final Widget? prefixWidget;

  /// Indica si el botón está en estado de carga
  final bool isLoading;

  /// Indica si el botón está habilitado
  final bool isEnabled;

  /// Tamaño del botón
  final ButtonStyle? style;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CustomButtonVariant.filled,
    this.icon,
    this.prefixWidget,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
  });

  /// Determina si el botón debe estar deshabilitado
  bool get _isDisabled => !isEnabled || isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    // Determinar el widget base según la variante
    Widget button;

    switch (variant) {
      case CustomButtonVariant.filled:
        button = _buildFilledButton(context);
        break;
      case CustomButtonVariant.outlined:
        button = _buildOutlinedButton(context);
        break;
      case CustomButtonVariant.text:
        button = _buildTextButton(context);
        break;
    }

    // Envolver en Semantics para accesibilidad
    return Semantics(
      button: true,
      enabled: !_isDisabled,
      label: isLoading ? 'Cargando...' : label,
      child: button,
    );
  }

  /// Construye un FilledButton con los estilos configurados
  Widget _buildFilledButton(BuildContext context) {
    return FilledButton(
      onPressed: _isDisabled ? null : onPressed,
      style: style ??
          FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
      child: _buildButtonContent(context),
    );
  }

  /// Construye un OutlinedButton con los estilos configurados
  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: _isDisabled ? null : onPressed,
      style: style ??
          OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
      child: _buildButtonContent(context),
    );
  }

  /// Construye un TextButton con los estilos configurados
  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: _isDisabled ? null : onPressed,
      style: style ??
          TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
      child: _buildButtonContent(context),
    );
  }

  /// Construye el contenido del botón (icono + texto o solo texto)
  Widget _buildButtonContent(BuildContext context) {
    // Si está cargando, mostrar solo el indicador de carga
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor(context)),
        ),
      );
    }

    // Si hay prefixWidget o icon, mostrar widget + texto
    if (prefixWidget != null || icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixWidget != null)
            prefixWidget!
          else if (icon != null)
            Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.s),
          Text(label),
        ],
      );
    }

    // Solo texto
    return Text(label);
  }

  /// Obtiene el color del indicador de carga según la variante
  Color _getLoadingColor(BuildContext context) {
    switch (variant) {
      case CustomButtonVariant.filled:
        // En filled button, el texto es blanco/negro según el tema
        return context.colorScheme.onPrimary;
      case CustomButtonVariant.outlined:
      case CustomButtonVariant.text:
        // En outlined y text, usar el color primario
        return context.colorScheme.primary;
    }
  }
}

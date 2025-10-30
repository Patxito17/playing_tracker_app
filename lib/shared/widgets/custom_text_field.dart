import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/extensions/context_extensions.dart';

/// Campo de texto personalizado con estilos Material Design 3 y validación visual
///
/// Encapsula un TextField con estilos M3 preconfigurados y soporte para
/// validación visual. Los estilos se basan en el inputDecorationTheme del tema.
///
/// **Ejemplo de uso:**
/// ```dart
/// // Campo de texto básico
/// CustomTextField(
///   label: 'Nombre',
///   hint: 'Ingresa tu nombre',
///   onChanged: (value) => print(value),
/// )
///
/// // Campo de email con validación
/// CustomTextField(
///   label: 'Email',
///   hint: 'usuario@ejemplo.com',
///   keyboardType: TextInputType.emailAddress,
///   errorText: 'Email inválido',
///   onChanged: (value) => validateEmail(value),
/// )
///
/// // Campo de contraseña
/// CustomTextField(
///   label: 'Contraseña',
///   obscureText: true,
///   textCapitalization: TextCapitalization.none,
///   onChanged: (value) => updatePassword(value),
/// )
/// ```
class CustomTextField extends StatelessWidget {
  /// Label del campo (título visible)
  final String? label;

  /// Hint text (texto de ayuda cuando está vacío)
  final String? hint;

  /// Texto de error a mostrar
  final String? errorText;

  /// Texto inicial del campo
  final String? initialValue;

  /// Callback que se ejecuta cuando cambia el texto
  final ValueChanged<String>? onChanged;

  /// Callback que se ejecuta al presionar el botón de acción del teclado
  final ValueChanged<String>? onSubmitted;

  /// Tipo de teclado a mostrar
  final TextInputType? keyboardType;

  /// Capitalización del texto
  final TextCapitalization textCapitalization;

  /// Indica si el texto debe estar oculto (para contraseñas)
  final bool obscureText;

  /// Indica si el campo está habilitado
  final bool enabled;

  /// Controlador del texto (opcional)
  final TextEditingController? controller;

  /// Acción del botón del teclado
  final TextInputAction? textInputAction;

  /// Validadores personalizados
  final List<String? Function(String?)>? validators;

  /// Sufijo opcional (icono o widget adicional)
  final Widget? suffix;

  /// Prefijo opcional (icono o widget adicional)
  final Widget? prefix;

  /// Máximo número de líneas
  final int? maxLines;

  /// Máximo número de caracteres
  final int? maxLength;

  /// Focus node opcional
  final FocusNode? focusNode;

  /// Indica si el campo es de solo lectura
  final bool readOnly;

  /// Formatters personalizados
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.obscureText = false,
    this.enabled = true,
    this.controller,
    this.textInputAction,
    this.validators,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar si hay error (errorText no nulo y no vacío)
    final hasError = errorText != null && errorText!.isNotEmpty;

    // Crear o usar el controller existente
    final textController =
        controller ??
        (initialValue != null
            ? TextEditingController(text: initialValue)
            : null);

    // Construir el InputDecoration con estilos M3
    final decoration = InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: hasError ? errorText : null,
      errorMaxLines: 2,
      enabled: enabled,
      suffixIcon: hasError
          ? Icon(Icons.error_outline, color: context.colorScheme.error)
          : suffix,
      prefixIcon: prefix,
      counterText: maxLength != null ? null : '',
    );

    return Semantics(
      textField: true,
      label: label ?? hint ?? 'Campo de texto',
      hint: hint,
      value: hasError ? errorText : null,
      enabled: enabled,
      readOnly: readOnly,
      child: TextField(
        controller: textController,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        enabled: enabled,
        readOnly: readOnly,
        textInputAction: textInputAction,
        maxLines: maxLines,
        maxLength: maxLength,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        decoration: decoration,
        style: context.textTheme.bodyLarge,
      ),
    );
  }
}

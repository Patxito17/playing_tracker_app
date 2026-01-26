import 'package:flutter/widgets.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/core/utils/access_code_generator.dart';

/// Valida campos relacionados con clases/membresías en formularios de la UI.
///
/// Este helper centraliza la lógica de validación requerida por las pantallas
/// de la fase 6 (unión de alumnos) para evitar duplicar expresiones regulares
/// o mensajes de error en los widgets.

/// Normaliza un código de acceso eliminando espacios y usando mayúsculas.
///
/// [rawValue] Texto ingresado por el usuario.
/// Retorna el valor listo para ser enviado al backend.
String normalizeAccessCode(String rawValue) => rawValue.trim().toUpperCase();

/// Valida el campo de código de acceso y retorna un mensaje legible si falla.
///
/// [value] Texto introducido por el usuario en el formulario.
/// Retorna `null` cuando el código es válido según las reglas del proyecto.
String? validateAccessCodeField(BuildContext context, String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return context.l10n.fieldRequired(context.l10n.accessCodeLabel);
  }

  if (!isValidAccessCode(trimmed.toUpperCase())) {
    return context.l10n.accessCodeInvalidFormat;
  }

  return null;
}

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Enum que representa el tipo de adjunto asociado a una tarea.
///
/// Actualmente solo se admite:
/// - [link]: Enlace externo (videos de YouTube, recursos web)
///
/// Este enum utiliza serialización JSON para almacenamiento en Firestore.
enum AttachmentType {
  /// Enlace externo - videos, recursos web, tutoriales
  @JsonValue('link')
  link;

  /// Retorna el nombre para mostrar en la interfaz de usuario
  String get displayName {
    switch (this) {
      case AttachmentType.link:
        return 'Enlace';
    }
  }

  /// Retorna el icono asociado al tipo de adjunto para uso en UI
  IconData get icon {
    switch (this) {
      case AttachmentType.link:
        return Icons.link;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Enum que representa el tipo de archivo adjunto asociado a una tarea.
///
/// Los tipos disponibles son:
/// - [pdf]: Archivo PDF (partituras, documentos, teoría)
/// - [audio]: Archivo de audio (referencias, ejemplos, backing tracks)
/// - [link]: Enlace externo (videos de YouTube, recursos web)
///
/// Este enum utiliza serialización JSON para almacenamiento en Firestore.
///
/// Ejemplo de uso:
/// ```dart
/// final AttachmentType tipo = AttachmentType.pdf;
/// print(tipo.displayName); // Output: "PDF"
/// final icon = tipo.icon; // IconData para mostrar icono de PDF
/// ```
enum AttachmentType {
  /// Archivo PDF - documentos, partituras, material teórico
  @JsonValue('pdf')
  pdf,

  /// Archivo de audio - referencias, ejemplos, backing tracks
  @JsonValue('audio')
  audio,

  /// Enlace externo - videos, recursos web, tutoriales
  @JsonValue('link')
  link;

  /// Retorna el nombre para mostrar en la interfaz de usuario
  String get displayName {
    switch (this) {
      case AttachmentType.pdf:
        return 'PDF';
      case AttachmentType.audio:
        return 'Audio';
      case AttachmentType.link:
        return 'Enlace';
    }
  }

  /// Retorna el icono asociado al tipo de adjunto para uso en UI
  IconData get icon {
    switch (this) {
      case AttachmentType.pdf:
        return Icons.picture_as_pdf;
      case AttachmentType.audio:
        return Icons.audiotrack;
      case AttachmentType.link:
        return Icons.link;
    }
  }
}

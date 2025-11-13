import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/features/tasks/domain/enums/attachment_type.dart';

part 'attachment_model.g.dart';

/// Modelo que representa un archivo adjunto asociado a una tarea.
///
/// Los archivos adjuntos pueden ser de diferentes tipos:
/// - PDF: Partituras, documentos, material teórico
/// - Audio: Referencias musicales, ejemplos, backing tracks
/// - Link: Enlaces a videos, recursos web, tutoriales
///
/// Este modelo es inmutable y se serializa a/desde JSON para almacenamiento en Firestore.
///
/// Ejemplo de uso:
/// ```dart
/// final attachment = AttachmentModel(
///   name: 'Partitura - Sonata No. 1',
///   url: 'https://storage.ejemplo.com/partituras/sonata1.pdf',
///   type: AttachmentType.pdf,
/// );
///
/// // Serializar a JSON
/// final json = attachment.toJson();
///
/// // Deserializar desde JSON
/// final attachmentFromJson = AttachmentModel.fromJson(json);
/// ```
@JsonSerializable()
class AttachmentModel {
  /// Nombre descriptivo del archivo adjunto
  final String name;

  /// URL completa donde se encuentra almacenado el archivo
  final String url;

  /// Tipo de archivo adjunto (pdf, audio, link)
  final AttachmentType type;

  /// Constructor del modelo de adjunto
  const AttachmentModel({
    required this.name,
    required this.url,
    required this.type,
  });

  /// Crea una instancia desde un mapa JSON
  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$AttachmentModelToJson(this);

  /// Crea una copia del modelo con los campos especificados modificados
  AttachmentModel copyWith({String? name, String? url, AttachmentType? type}) {
    return AttachmentModel(
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          url == other.url &&
          type == other.type;

  @override
  int get hashCode => name.hashCode ^ url.hashCode ^ type.hashCode;

  @override
  String toString() => 'AttachmentModel(name: $name, url: $url, type: $type)';
}

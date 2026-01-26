import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/features/tasks/domain/enums/attachment_type.dart';

part 'attachment_model.g.dart';

/// Modelo que representa un adjunto (enlace) asociado a una tarea.
///
/// Los adjuntos actualmente son únicamente enlaces externos:
/// - Link: Enlaces a videos, recursos web, tutoriales
///
/// Este modelo es inmutable y se serializa a/desde JSON para almacenamiento en Firestore.
///
/// Ejemplo de uso:
/// ```dart
/// final attachment = AttachmentModel(
///   name: 'Video tutorial',
///   url: 'https://www.youtube.com/watch?v=...',
///   type: AttachmentType.link,
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
  /// Nombre descriptivo del enlace adjunto
  final String name;

  /// URL completa del enlace
  final String url;

  /// Tipo de adjunto (siempre link)
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

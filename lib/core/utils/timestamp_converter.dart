import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converter personalizado para serializar y deserializar objetos Timestamp de Firestore.
///
/// Este converter permite que json_serializable maneje correctamente los campos
/// de tipo Timestamp en los modelos que se almacenan en Firestore.
///
/// Uso:
/// ```dart
/// @JsonSerializable()
/// class MiModelo {
///   @TimestampConverter()
///   final Timestamp createdAt;
///
///   const MiModelo({required this.createdAt});
/// }
/// ```
class TimestampConverter implements JsonConverter<Timestamp, Object> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Object json) {
    // Si ya es un Timestamp, devolverlo directamente
    if (json is Timestamp) {
      return json;
    }

    // Si es un Map con segundos y nanosegundos (formato típico de Firestore)
    if (json is Map<String, dynamic>) {
      final seconds = json['_seconds'] as int? ?? json['seconds'] as int?;
      final nanoseconds =
          json['_nanoseconds'] as int? ?? json['nanoseconds'] as int?;

      if (seconds == null || nanoseconds == null) {
        throw ArgumentError(
          'No se puede convertir $json a Timestamp. '
          'Faltan campos requeridos (seconds: $seconds, nanoseconds: $nanoseconds).',
        );
      }

      return Timestamp(seconds, nanoseconds);
    }

    // Si es un número (milisegundos desde epoch)
    if (json is int) {
      return Timestamp.fromMillisecondsSinceEpoch(json);
    }

    // Fallback: intentar parsear como milisegundos
    throw ArgumentError(
      'No se puede convertir $json a Timestamp. Tipo recibido: ${json.runtimeType}',
    );
  }

  @override
  Object toJson(Timestamp timestamp) {
    // Convertir a milisegundos para almacenamiento en JSON
    // Firestore maneja automáticamente Timestamp en sus operaciones
    return timestamp;
  }
}

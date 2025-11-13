import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';
import 'package:playing_tracker/features/tasks/domain/models/attachment_model.dart';

part 'task_model.g.dart';

/// Modelo que representa la definición maestra de una tarea musical.
///
/// Las tareas son creadas por docentes y definen el trabajo que los alumnos
/// deben realizar. Una tarea puede incluir:
/// - Título y descripción detallada
/// - Duración sugerida de práctica en segundos
/// - Archivos adjuntos (partituras, audios, enlaces)
/// - Fecha de vencimiento opcional
///
/// Las tareas se almacenan en la colección `tasks` de Firestore y luego
/// se asignan a alumnos específicos mediante la colección `assignments`.
///
/// Ejemplo de uso:
/// ```dart
/// final task = TaskModel(
///   id: 'task_uuid_123',
///   title: 'Escalas de Do Mayor',
///   description: 'Practicar escalas en 2 octavas, ascendente y descendente',
///   createdBy: 'teacher_uid_456',
///   durationSuggested: 1800, // 30 minutos en segundos
///   attachments: [
///     AttachmentModel(
///       name: 'Partitura escalas',
///       url: 'https://ejemplo.com/escalas.pdf',
///       type: AttachmentType.pdf,
///     ),
///   ],
///   createdAt: Timestamp.now(),
///   updatedAt: Timestamp.now(),
///   dueDate: Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
///   isActive: true,
/// );
///
/// // Serializar a JSON para Firestore
/// final json = task.toJson();
///
/// // Deserializar desde JSON
/// final taskFromJson = TaskModel.fromJson(json);
/// ```
@JsonSerializable(explicitToJson: true)
class TaskModel {
  /// Identificador único de la tarea
  final String id;

  /// Título descriptivo de la tarea
  final String title;

  /// Descripción detallada de la tarea (opcional)
  final String? description;

  /// ID del docente que creó la tarea
  final String createdBy;

  /// Duración sugerida de práctica en segundos
  final int durationSuggested;

  /// Lista de archivos adjuntos asociados a la tarea
  final List<AttachmentModel> attachments;

  /// Fecha y hora de creación de la tarea
  @TimestampConverter()
  final Timestamp createdAt;

  /// Fecha y hora de la última actualización de la tarea
  @TimestampConverter()
  final Timestamp updatedAt;

  /// Fecha de vencimiento de la tarea (opcional)
  @TimestampConverter()
  final Timestamp? dueDate;

  /// Indica si la tarea está activa (true) o archivada (false)
  final bool isActive;

  /// Constructor del modelo de tarea
  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdBy,
    required this.durationSuggested,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.isActive = true,
  });

  /// Crea una instancia desde un mapa JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  /// Retorna la duración sugerida formateada en formato legible
  String get durationFormatted {
    final hours = durationSuggested ~/ 3600;
    final minutes = (durationSuggested % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? "$minutes min" : ""}';
    }
    return '$minutes min';
  }

  /// Crea una copia del modelo con los campos especificados modificados
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    int? durationSuggested,
    List<AttachmentModel>? attachments,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? dueDate,
    bool? isActive,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      durationSuggested: durationSuggested ?? this.durationSuggested,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          createdBy == other.createdBy &&
          durationSuggested == other.durationSuggested &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          dueDate == other.dueDate &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      createdBy.hashCode ^
      durationSuggested.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      dueDate.hashCode ^
      isActive.hashCode;

  @override
  String toString() =>
      'TaskModel(id: $id, title: $title, '
      'duration: $durationFormatted, isActive: $isActive)';
}

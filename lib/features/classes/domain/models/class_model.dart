import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';

part 'class_model.g.dart';

/// Modelo que representa una clase o grupo creado por un docente.
///
/// Las clases permiten a los docentes:
/// - Organizar alumnos en grupos
/// - Asignar tareas específicas a la clase
/// - Ver estadísticas grupales de progreso
/// - Gestionar membresías de alumnos
///
/// Cada clase tiene un código de acceso único de 6 caracteres alfanuméricos
/// que los alumnos utilizan para unirse a la clase.
///
/// Se almacena en la colección `classes` de Firestore con un ID único global.
///
/// Ejemplo de uso:
/// ```dart
/// final classModel = ClassModel(
///   id: 'class_uuid_123',
///   name: 'Piano Nivel Intermedio',
///   description: 'Clase de piano para alumnos de nivel intermedio',
///   ownerTeacherId: 'teacher_uid_456',
///   accessCode: 'ABC234',
///   createdAt: Timestamp.now(),
///   updatedAt: Timestamp.now(),
///   isActive: true,
/// );
///
/// // Serializar a JSON para Firestore
/// final json = classModel.toJson();
///
/// // Deserializar desde JSON
/// final classFromJson = ClassModel.fromJson(json);
/// ```
@JsonSerializable()
class ClassModel {
  /// Identificador único de la clase
  final String id;

  /// Nombre descriptivo de la clase
  final String name;

  /// Descripción opcional de la clase (objetivos, nivel, etc.)
  final String? description;

  /// ID del docente propietario de la clase
  final String ownerTeacherId;

  /// Código de acceso único de 6 caracteres para que alumnos se unan
  final String accessCode;

  /// Fecha y hora de creación de la clase
  @TimestampConverter()
  final Timestamp createdAt;

  /// Fecha y hora de la última actualización de la clase
  @TimestampConverter()
  final Timestamp updatedAt;

  /// Indica si la clase está activa (true) o archivada (false)
  final bool isActive;

  /// Constructor del modelo de clase
  const ClassModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerTeacherId,
    required this.accessCode,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Crea una instancia desde un mapa JSON
  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$ClassModelToJson(this);

  /// Crea una copia del modelo con los campos especificados modificados
  ClassModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerTeacherId,
    String? accessCode,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isActive,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerTeacherId: ownerTeacherId ?? this.ownerTeacherId,
      accessCode: accessCode ?? this.accessCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Indica si la clase puede recibir alumnos (alias semántico de [isActive]).
  bool get canJoin => isActive;

  /// Indica si la clase fue archivada o deshabilitada por el docente.
  bool get isArchived => !isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          ownerTeacherId == other.ownerTeacherId &&
          accessCode == other.accessCode &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      ownerTeacherId.hashCode ^
      accessCode.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isActive.hashCode;

  @override
  String toString() =>
      'ClassModel(id: $id, name: $name, '
      'accessCode: $accessCode, isActive: $isActive)';
}

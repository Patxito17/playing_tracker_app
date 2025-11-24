import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';

part 'membership_model.g.dart';

/// Modelo que representa la relación de pertenencia entre un alumno y una clase.
///
/// Este modelo implementa la relación N:M entre alumnos y clases:
/// - Un alumno puede pertenecer a múltiples clases
/// - Una clase puede tener múltiples alumnos
///
/// Incluye campos denormalizados para optimizar consultas:
/// - teacherId: ID del docente dueño de la clase (evita joins)
/// - className: Nombre de la clase (para mostrar en listas sin joins)
///
/// Se almacena en la colección `memberships` de Firestore con un ID único.
///
/// Casos de uso:
/// - Listar todas las clases de un alumno
/// - Listar todos los alumnos de una clase
/// - Verificar si un alumno pertenece a una clase específica
///
/// Ejemplo de uso:
/// ```dart
/// final membership = MembershipModel(
///   id: 'membership_uuid_123',
///   classId: 'class_uuid_456',
///   studentId: 'student_uid_789',
///   teacherId: 'teacher_uid_012',
///   className: 'Piano Nivel Intermedio',
///   joinedAt: Timestamp.now(),
///   isActive: true,
/// );
///
/// // Serializar a JSON para Firestore
/// final json = membership.toJson();
///
/// // Deserializar desde JSON
/// final membershipFromJson = MembershipModel.fromJson(json);
/// ```
@JsonSerializable()
class MembershipModel {
  /// Identificador único de la membresía
  final String id;

  /// ID de la clase a la que pertenece el alumno
  final String classId;

  /// ID del alumno que pertenece a la clase
  final String studentId;

  /// ID del docente dueño de la clase (campo denormalizado)
  final String teacherId;

  /// Nombre de la clase (campo denormalizado para optimizar consultas)
  final String className;

  /// Fecha y hora en que el alumno se unió a la clase
  @TimestampConverter()
  final Timestamp joinedAt;

  /// Fecha y hora de la última actualización de la membresía
  @TimestampConverter()
  final Timestamp updatedAt;

  /// Indica si la membresía está activa (true) o el alumno ha sido removido (false)
  final bool isActive;

  /// Constructor del modelo de membresía
  const MembershipModel({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.teacherId,
    required this.className,
    required this.joinedAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Crea una instancia desde un mapa JSON
  factory MembershipModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$MembershipModelToJson(this);

  /// Crea una copia del modelo con los campos especificados modificados
  MembershipModel copyWith({
    String? id,
    String? classId,
    String? studentId,
    String? teacherId,
    String? className,
    Timestamp? joinedAt,
    Timestamp? updatedAt,
    bool? isActive,
  }) {
    return MembershipModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      className: className ?? this.className,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Indica si la membresía representa un alumno actualmente activo.
  bool get isActiveMember => isActive;

  /// Determina si el alumno fue removido o la membresía está suspendida.
  bool get isInactiveMember => !isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembershipModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          classId == other.classId &&
          studentId == other.studentId &&
          teacherId == other.teacherId &&
          className == other.className &&
          joinedAt == other.joinedAt &&
          updatedAt == other.updatedAt &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      classId.hashCode ^
      studentId.hashCode ^
      teacherId.hashCode ^
      className.hashCode ^
      joinedAt.hashCode ^
      updatedAt.hashCode ^
      isActive.hashCode;

  @override
  String toString() =>
      'MembershipModel(id: $id, className: $className, '
      'studentId: $studentId, isActive: $isActive, updatedAt: $updatedAt)';
}

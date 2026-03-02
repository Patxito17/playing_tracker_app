import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';

part 'teacher_model.g.dart';

/// Modelo que representa el perfil de un docente en el sistema.
///
/// Los docentes pueden:
/// - Crear y gestionar clases
/// - Asignar tareas a estudiantes
/// - Visualizar progreso y estadísticas de sus alumnos
/// - Generar códigos de acceso para que estudiantes se unan a clases
///
/// Este modelo se almacena en la colección `teachers` de Firestore,
/// usando el UID de Firebase Authentication como ID del documento.
///
/// Ejemplo de uso:
/// ```dart
/// final teacher = TeacherModel(
///   id: 'uid_firebase_auth',
///   firstName: 'María',
///   lastName: 'García',
///   email: 'maria.garcia@ejemplo.com',
///   createdAt: Timestamp.now(),
///   updatedAt: Timestamp.now(),
///   isActive: true,
/// );
///
/// // Serializar a JSON para Firestore
/// final json = teacher.toJson();
///
/// // Deserializar desde JSON
/// final teacherFromJson = TeacherModel.fromJson(json);
/// ```
@JsonSerializable()
class TeacherModel {
  /// Identificador único del docente (UID de Firebase Authentication)
  final String id;

  /// Nombre(s) del docente
  final String firstName;

  /// Apellido(s) del docente
  final String lastName;

  /// Correo electrónico del docente (usado para autenticación)
  final String email;

  /// Fecha y hora de creación del perfil
  @TimestampConverter()
  final Timestamp createdAt;

  /// Fecha y hora de la última actualización del perfil
  @TimestampConverter()
  final Timestamp updatedAt;

  /// Indica si el perfil está activo (true) o inactivo/eliminado (false)
  final bool isActive;

  /// Versión de los Términos y Condiciones aceptada por el docente (e.g. "1.0").
  /// Null si el usuario fue creado antes del versionado legal.
  final String? acceptedTermsVersion;

  /// Fecha y hora en que el docente aceptó los Términos y Condiciones.
  @TimestampConverter()
  final Timestamp? acceptedTermsAt;

  /// Constructor del modelo de docente
  const TeacherModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.acceptedTermsVersion,
    this.acceptedTermsAt,
  });

  /// Crea una instancia desde un mapa JSON
  factory TeacherModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$TeacherModelToJson(this);

  /// Retorna el nombre completo del docente
  String get fullName => '$firstName $lastName';

  /// Crea una copia del modelo con los campos especificados modificados
  TeacherModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isActive,
    String? acceptedTermsVersion,
    Timestamp? acceptedTermsAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      acceptedTermsVersion: acceptedTermsVersion ?? this.acceptedTermsVersion,
      acceptedTermsAt: acceptedTermsAt ?? this.acceptedTermsAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isActive == other.isActive &&
          acceptedTermsVersion == other.acceptedTermsVersion &&
          acceptedTermsAt == other.acceptedTermsAt;

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      email.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isActive.hashCode ^
      acceptedTermsVersion.hashCode ^
      acceptedTermsAt.hashCode;

  @override
  String toString() =>
      'TeacherModel(id: $id, fullName: $fullName, '
      'email: $email, isActive: $isActive)';
}

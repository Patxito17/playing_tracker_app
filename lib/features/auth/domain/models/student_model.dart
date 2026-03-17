import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';
import 'package:playing_tracker/features/auth/domain/models/user_profile.dart';

part 'student_model.g.dart';

/// Modelo que representa el perfil de un alumno en el sistema.
///
/// Los alumnos pueden:
/// - Unirse a clases mediante códigos de acceso
/// - Ver tareas asignadas por sus docentes
/// - Registrar sesiones de estudio con cronómetro
/// - Visualizar su propio progreso y estadísticas
///
/// Este modelo incluye campos agregados (denormalizados) para optimizar
/// consultas de estadísticas sin necesidad de calcularlas en tiempo real:
/// - totalSessionsCount: Número total de sesiones registradas
/// - totalDurationLogged: Tiempo total de estudio en segundos
/// - lastSessionDate: Fecha de la última sesión registrada
///
/// Se almacena en la colección `students` de Firestore,
/// usando el UID de Firebase Authentication como ID del documento.
///
/// Ejemplo de uso:
/// ```dart
/// final student = StudentModel(
///   id: 'uid_firebase_auth',
///   firstName: 'Carlos',
///   lastName: 'Rodríguez',
///   email: 'carlos.rodriguez@ejemplo.com',
///   createdAt: Timestamp.now(),
///   updatedAt: Timestamp.now(),
///   isActive: true,
///   totalSessionsCount: 15,
///   totalDurationLogged: 54000, // 15 horas en segundos
///   lastSessionDate: Timestamp.now(),
/// );
///
/// // Serializar a JSON para Firestore
/// final json = student.toJson();
///
/// // Deserializar desde JSON
/// final studentFromJson = StudentModel.fromJson(json);
/// ```
@JsonSerializable()
class StudentModel implements UserProfile {
  /// Identificador único del alumno (UID de Firebase Authentication)
  @override
  final String id;

  /// Nombre(s) del alumno
  @override
  final String firstName;

  /// Apellido(s) del alumno
  @override
  final String lastName;

  /// Correo electrónico del alumno (usado para autenticación)
  @override
  final String email;

  /// Fecha y hora de creación del perfil
  @TimestampConverter()
  final Timestamp createdAt;

  /// Fecha y hora de la última actualización del perfil
  @TimestampConverter()
  final Timestamp updatedAt;

  /// Indica si el perfil está activo (true) o inactivo/eliminado (false)
  final bool isActive;

  /// Número total de sesiones de estudio registradas por el alumno (agregado)
  final int totalSessionsCount;

  /// Tiempo total de estudio registrado en segundos (agregado)
  final int totalDurationLogged;

  /// Fecha y hora de la última sesión de estudio registrada (agregado, nullable)
  @TimestampConverter()
  final Timestamp? lastSessionDate;

  /// Versión de los Términos y Condiciones aceptada por el alumno (e.g. "1.0").
  /// Null si el usuario fue creado antes del versionado legal.
  final String? acceptedTermsVersion;

  /// Fecha y hora en que el alumno aceptó los Términos y Condiciones.
  @TimestampConverter()
  final Timestamp? acceptedTermsAt;

  /// Constructor del modelo de alumno
  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.totalSessionsCount = 0,
    this.totalDurationLogged = 0,
    this.lastSessionDate,
    this.acceptedTermsVersion,
    this.acceptedTermsAt,
  });

  /// Crea una instancia desde un mapa JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$StudentModelToJson(this);

  /// Retorna el nombre completo del alumno
  @override
  String get fullName => '$firstName $lastName';

  /// Crea una copia del modelo con los campos especificados modificados
  StudentModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isActive,
    int? totalSessionsCount,
    int? totalDurationLogged,
    Timestamp? lastSessionDate,
    String? acceptedTermsVersion,
    Timestamp? acceptedTermsAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      totalSessionsCount: totalSessionsCount ?? this.totalSessionsCount,
      totalDurationLogged: totalDurationLogged ?? this.totalDurationLogged,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      acceptedTermsVersion: acceptedTermsVersion ?? this.acceptedTermsVersion,
      acceptedTermsAt: acceptedTermsAt ?? this.acceptedTermsAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isActive == other.isActive &&
          totalSessionsCount == other.totalSessionsCount &&
          totalDurationLogged == other.totalDurationLogged &&
          lastSessionDate == other.lastSessionDate &&
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
      totalSessionsCount.hashCode ^
      totalDurationLogged.hashCode ^
      lastSessionDate.hashCode ^
      acceptedTermsVersion.hashCode ^
      acceptedTermsAt.hashCode;

  @override
  String toString() =>
      'StudentModel(id: $id, fullName: $fullName, '
      'email: $email, isActive: $isActive, '
      'totalSessions: $totalSessionsCount, '
      'totalDuration: $totalDurationLogged)';
}

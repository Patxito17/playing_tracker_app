import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';

part 'assignment_model.g.dart';

/// Modelo que representa la asignación de una tarea a un alumno específico.
///
/// Este modelo actúa como el vínculo entre una tarea (TaskModel) y un alumno,
/// rastreando el progreso individual de cada alumno en cada tarea asignada.
///
/// Características principales:
/// - ID compuesto: `${taskId}_${studentId}` para garantizar unicidad
/// - Estado de progreso (pending, inProgress, completed)
/// - Contadores de sesiones y duración total registrada
/// - Campos denormalizados para optimizar consultas
///
/// Los contadores se actualizan automáticamente cuando el alumno registra
/// sesiones de estudio para esta tarea.
///
/// Se almacena en la colección `assignments` de Firestore.
///
/// Ejemplo de uso:
/// ```dart
/// final assignment = AssignmentModel(
///   id: 'task_123_student_456', // Clave compuesta
///   taskId: 'task_123',
///   studentId: 'student_456',
///   teacherId: 'teacher_789',
///   status: TaskStatus.inProgress,
///   assignedAt: Timestamp.now(),
///   completedAt: null,
///   sessionsCount: 3,
///   totalDurationLogged: 5400, // 1.5 horas en segundos
///   lastSessionDate: Timestamp.now(),
/// );
///
/// // Serializar a JSON para Firestore
/// final json = assignment.toJson();
///
/// // Deserializar desde JSON
/// final assignmentFromJson = AssignmentModel.fromJson(json);
/// ```
@JsonSerializable()
class AssignmentModel {
  /// Identificador único compuesto: ${taskId}_${studentId}
  final String id;

  /// ID de la tarea asignada
  final String taskId;

  /// ID del alumno al que se asignó la tarea
  final String studentId;

  /// ID del docente que creó/asignó la tarea (campo denormalizado)
  final String teacherId;

  /// Estado actual de la asignación (pending, inProgress, completed)
  final TaskStatus status;

  /// Fecha y hora en que se asignó la tarea al alumno
  @TimestampConverter()
  final Timestamp assignedAt;

  /// Fecha y hora en que el alumno completó la tarea (nullable)
  @TimestampConverter()
  final Timestamp? completedAt;

  /// Número total de sesiones de estudio registradas para esta tarea (agregado)
  final int sessionsCount;

  /// Tiempo total de estudio registrado en segundos (agregado)
  final int totalDurationLogged;

  /// Fecha y hora de la última sesión registrada (agregado, nullable)
  @TimestampConverter()
  final Timestamp? lastSessionDate;

  /// Constructor del modelo de asignación
  const AssignmentModel({
    required this.id,
    required this.taskId,
    required this.studentId,
    required this.teacherId,
    required this.status,
    required this.assignedAt,
    this.completedAt,
    this.sessionsCount = 0,
    this.totalDurationLogged = 0,
    this.lastSessionDate,
  });

  /// Crea una instancia desde un mapa JSON
  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$AssignmentModelToJson(this);

  /// Genera un ID compuesto a partir del taskId y studentId
  static String generateId(String taskId, String studentId) =>
      '${taskId}_$studentId';

  /// Retorna la duración total formateada en formato legible
  String get durationFormatted {
    final hours = totalDurationLogged ~/ 3600;
    final minutes = (totalDurationLogged % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? "$minutes min" : ""}';
    }
    return '$minutes min';
  }

  /// Indica si la asignación ha sido completada
  bool get isCompleted => status == TaskStatus.completed;

  /// Indica si la asignación está en progreso
  bool get isInProgress => status == TaskStatus.inProgress;

  /// Indica si la asignación está pendiente de iniciar
  bool get isPending => status == TaskStatus.pending;

  /// Crea una copia del modelo con los campos especificados modificados
  AssignmentModel copyWith({
    String? id,
    String? taskId,
    String? studentId,
    String? teacherId,
    TaskStatus? status,
    Timestamp? assignedAt,
    Timestamp? completedAt,
    int? sessionsCount,
    int? totalDurationLogged,
    Timestamp? lastSessionDate,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      totalDurationLogged: totalDurationLogged ?? this.totalDurationLogged,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          taskId == other.taskId &&
          studentId == other.studentId &&
          teacherId == other.teacherId &&
          status == other.status &&
          assignedAt == other.assignedAt &&
          completedAt == other.completedAt &&
          sessionsCount == other.sessionsCount &&
          totalDurationLogged == other.totalDurationLogged &&
          lastSessionDate == other.lastSessionDate;

  @override
  int get hashCode =>
      id.hashCode ^
      taskId.hashCode ^
      studentId.hashCode ^
      teacherId.hashCode ^
      status.hashCode ^
      assignedAt.hashCode ^
      completedAt.hashCode ^
      sessionsCount.hashCode ^
      totalDurationLogged.hashCode ^
      lastSessionDate.hashCode;

  @override
  String toString() =>
      'AssignmentModel(id: $id, status: $status, '
      'sessions: $sessionsCount, duration: $durationFormatted)';
}

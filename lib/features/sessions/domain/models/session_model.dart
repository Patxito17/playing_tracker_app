import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:playing_tracker/core/utils/timestamp_converter.dart';

part 'session_model.g.dart';

/// Estados posibles de una sesión de práctica
enum SessionStatus {
  /// Sesión no iniciada
  idle,

  /// Sesión en progreso
  running,

  /// Sesión pausada temporalmente
  paused,

  /// Sesión completada y guardada
  completed,
}

/// Modelo que representa un registro atómico de sesión de estudio.
///
/// Cada sesión representa un período continuo de práctica/estudio que un alumno
/// registra para una tarea específica usando el cronómetro de la aplicación.
///
/// Características principales:
/// - Registro inmutable (no se puede editar después de crear)
/// - Incluye tiempos de inicio, fin, total y pausa
/// - Campo monthBucket para optimizar queries de métricas mensuales
/// - Campos denormalizados para evitar joins
///
/// El campo monthBucket tiene formato "YYYY-MM" y se usa para:
/// - Consultas eficientes de estadísticas mensuales
/// - Gráficos de progreso por mes
/// - Reportes agregados por período
///
/// Se almacena en la colección `sessions` de Firestore.
///
/// Ejemplo de uso:
/// ```dart
/// final session = SessionModel(
///   id: 'session_uuid_123',
///   studentId: 'student_456',
///   taskId: 'task_789',
///   teacherId: 'teacher_012',
///   startTime: Timestamp.fromDate(DateTime(2025, 11, 13, 10, 0)),
///   endTime: Timestamp.fromDate(DateTime(2025, 11, 13, 10, 45)),
///   totalDuration: 2700, // 45 minutos en segundos
///   pausedDuration: 300, // 5 minutos de pausa
///   dateLogged: Timestamp.fromDate(DateTime(2025, 11, 13)),
///   monthBucket: '2025-11',
///   notes: 'Sesión enfocada en escalas',
///   status: SessionStatus.completed,
///   createdAt: Timestamp.now(),
/// );
///
/// // Serializar a JSON para Firestore
/// final json = session.toJson();
///
/// // Deserializar desde JSON
/// final sessionFromJson = SessionModel.fromJson(json);
/// ```
@JsonSerializable()
class SessionModel {
  /// Identificador único de la sesión
  final String id;

  /// ID del alumno que registró la sesión
  final String studentId;

  /// ID de la tarea para la cual se registró la sesión
  final String taskId;

  /// ID del docente dueño de la tarea (campo denormalizado)
  final String teacherId;

  /// Fecha y hora de inicio de la sesión
  @TimestampConverter()
  final Timestamp startTime;

  /// Fecha y hora de finalización de la sesión
  @TimestampConverter()
  final Timestamp endTime;

  /// Duración total efectiva de estudio en segundos (sin pausas)
  final int totalDuration;

  /// Duración total de pausas en segundos
  final int pausedDuration;

  /// Fecha en que se registró la sesión (sin hora, para agrupación)
  @TimestampConverter()
  final Timestamp dateLogged;

  /// Mes de la sesión en formato "YYYY-MM" para queries de métricas
  final String monthBucket;

  /// Notas opcionales del alumno sobre la sesión
  final String? notes;

  /// Estado de la sesión
  final SessionStatus status;

  /// Fecha y hora de creación del registro en Firestore
  @TimestampConverter()
  final Timestamp createdAt;

  /// Constructor del modelo de sesión
  const SessionModel({
    required this.id,
    required this.studentId,
    required this.taskId,
    required this.teacherId,
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
    this.pausedDuration = 0,
    required this.dateLogged,
    required this.monthBucket,
    this.notes,
    this.status = SessionStatus.completed,
    required this.createdAt,
  });

  /// Crea una instancia desde un mapa JSON
  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  /// Genera el monthBucket a partir de un Timestamp (formato: "YYYY-MM")
  static String generateMonthBucket(Timestamp timestamp) {
    final date = timestamp.toDate();
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    return '$year-$month';
  }

  /// Retorna la duración total formateada en formato legible
  String get durationFormatted {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final seconds = totalDuration % 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? "$minutes min" : ""}';
    } else if (minutes > 0) {
      return '$minutes min ${seconds > 0 ? "$seconds s" : ""}';
    }
    return '$seconds s';
  }

  /// Retorna la duración de pausa formateada
  String get pausedDurationFormatted {
    final minutes = pausedDuration ~/ 60;
    final seconds = pausedDuration % 60;

    if (minutes > 0) {
      return '$minutes min ${seconds > 0 ? "$seconds s" : ""}';
    }
    return '$seconds s';
  }

  /// Crea una copia del modelo con los campos especificados modificados
  SessionModel copyWith({
    String? id,
    String? studentId,
    String? taskId,
    String? teacherId,
    Timestamp? startTime,
    Timestamp? endTime,
    int? totalDuration,
    int? pausedDuration,
    Timestamp? dateLogged,
    String? monthBucket,
    String? notes,
    SessionStatus? status,
    Timestamp? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      taskId: taskId ?? this.taskId,
      teacherId: teacherId ?? this.teacherId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDuration: totalDuration ?? this.totalDuration,
      pausedDuration: pausedDuration ?? this.pausedDuration,
      dateLogged: dateLogged ?? this.dateLogged,
      monthBucket: monthBucket ?? this.monthBucket,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          taskId == other.taskId &&
          teacherId == other.teacherId &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          totalDuration == other.totalDuration &&
          pausedDuration == other.pausedDuration &&
          dateLogged == other.dateLogged &&
          monthBucket == other.monthBucket &&
          notes == other.notes &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      studentId.hashCode ^
      taskId.hashCode ^
      teacherId.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      totalDuration.hashCode ^
      pausedDuration.hashCode ^
      dateLogged.hashCode ^
      monthBucket.hashCode ^
      notes.hashCode ^
      status.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'SessionModel(id: $id, taskId: $taskId, '
      'duration: $durationFormatted, date: $monthBucket)';
}

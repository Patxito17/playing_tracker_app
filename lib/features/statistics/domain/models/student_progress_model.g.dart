// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentProgressModel _$StudentProgressModelFromJson(
  Map<String, dynamic> json,
) => StudentProgressModel(
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String,
  totalDuration: (json['totalDuration'] as num).toInt(),
  totalSessions: (json['totalSessions'] as num).toInt(),
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  lastSessionDate: _$JsonConverterFromJson<Object, Timestamp>(
    json['lastSessionDate'],
    const TimestampConverter().fromJson,
  ),
  totalTasks: (json['totalTasks'] as num).toInt(),
  completedTasks: (json['completedTasks'] as num).toInt(),
  averageSessionDuration: (json['averageSessionDuration'] as num?)?.toInt(),
);

Map<String, dynamic> _$StudentProgressModelToJson(
  StudentProgressModel instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'totalDuration': instance.totalDuration,
  'totalSessions': instance.totalSessions,
  'currentStreak': instance.currentStreak,
  'longestStreak': instance.longestStreak,
  'lastSessionDate': _$JsonConverterToJson<Object, Timestamp>(
    instance.lastSessionDate,
    const TimestampConverter().toJson,
  ),
  'totalTasks': instance.totalTasks,
  'completedTasks': instance.completedTasks,
  'averageSessionDuration': instance.averageSessionDuration,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignmentModel _$AssignmentModelFromJson(Map<String, dynamic> json) =>
    AssignmentModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      teacherId: json['teacherId'] as String,
      taskTitle: json['taskTitle'] as String?,
      taskDescription: json['taskDescription'] as String?,
      durationSuggested: (json['durationSuggested'] as num?)?.toInt(),
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      assignedAt: const TimestampConverter().fromJson(
        json['assignedAt'] as Object,
      ),
      completedAt: _$JsonConverterFromJson<Object, Timestamp>(
        json['completedAt'],
        const TimestampConverter().fromJson,
      ),
      sessionsCount: (json['sessionsCount'] as num?)?.toInt() ?? 0,
      totalDurationLogged: (json['totalDurationLogged'] as num?)?.toInt() ?? 0,
      lastSessionDate: _$JsonConverterFromJson<Object, Timestamp>(
        json['lastSessionDate'],
        const TimestampConverter().fromJson,
      ),
      isActive: json['isActive'] as bool? ?? true,
      dueDate: _$JsonConverterFromJson<Object, Timestamp>(
        json['dueDate'],
        const TimestampConverter().fromJson,
      ),
    );

Map<String, dynamic> _$AssignmentModelToJson(AssignmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'studentId': instance.studentId,
      'classId': instance.classId,
      'teacherId': instance.teacherId,
      'taskTitle': instance.taskTitle,
      'taskDescription': instance.taskDescription,
      'durationSuggested': instance.durationSuggested,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'assignedAt': const TimestampConverter().toJson(instance.assignedAt),
      'completedAt': _$JsonConverterToJson<Object, Timestamp>(
        instance.completedAt,
        const TimestampConverter().toJson,
      ),
      'sessionsCount': instance.sessionsCount,
      'totalDurationLogged': instance.totalDurationLogged,
      'lastSessionDate': _$JsonConverterToJson<Object, Timestamp>(
        instance.lastSessionDate,
        const TimestampConverter().toJson,
      ),
      'isActive': instance.isActive,
      'dueDate': _$JsonConverterToJson<Object, Timestamp>(
        instance.dueDate,
        const TimestampConverter().toJson,
      ),
    };

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.completed: 'completed',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

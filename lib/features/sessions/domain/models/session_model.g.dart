// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  taskId: json['taskId'] as String,
  teacherId: json['teacherId'] as String,
  startTime: const TimestampConverter().fromJson(json['startTime'] as Object),
  endTime: const TimestampConverter().fromJson(json['endTime'] as Object),
  totalDuration: (json['totalDuration'] as num).toInt(),
  pausedDuration: (json['pausedDuration'] as num?)?.toInt() ?? 0,
  dateLogged: const TimestampConverter().fromJson(json['dateLogged'] as Object),
  monthBucket: json['monthBucket'] as String,
  notes: json['notes'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'taskId': instance.taskId,
      'teacherId': instance.teacherId,
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'endTime': const TimestampConverter().toJson(instance.endTime),
      'totalDuration': instance.totalDuration,
      'pausedDuration': instance.pausedDuration,
      'dateLogged': const TimestampConverter().toJson(instance.dateLogged),
      'monthBucket': instance.monthBucket,
      'notes': instance.notes,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskStatsModel _$TaskStatsModelFromJson(Map<String, dynamic> json) =>
    TaskStatsModel(
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      totalDuration: (json['totalDuration'] as num).toInt(),
      totalSessions: (json['totalSessions'] as num).toInt(),
      suggestedDuration: (json['suggestedDuration'] as num?)?.toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      lastSessionDate: json['lastSessionDate'] == null
          ? null
          : DateTime.parse(json['lastSessionDate'] as String),
    );

Map<String, dynamic> _$TaskStatsModelToJson(TaskStatsModel instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'taskTitle': instance.taskTitle,
      'totalDuration': instance.totalDuration,
      'totalSessions': instance.totalSessions,
      'suggestedDuration': instance.suggestedDuration,
      'isCompleted': instance.isCompleted,
      'lastSessionDate': instance.lastSessionDate?.toIso8601String(),
    };

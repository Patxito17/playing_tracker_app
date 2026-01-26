// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassStatsModel _$ClassStatsModelFromJson(Map<String, dynamic> json) =>
    ClassStatsModel(
      classId: json['classId'] as String,
      className: json['className'] as String,
      totalStudents: (json['totalStudents'] as num).toInt(),
      activeStudents: (json['activeStudents'] as num).toInt(),
      totalDuration: (json['totalDuration'] as num).toInt(),
      totalSessions: (json['totalSessions'] as num).toInt(),
      taskBreakdown:
          (json['taskBreakdown'] as List<dynamic>?)
              ?.map((e) => TaskStatsModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ClassStatsModelToJson(ClassStatsModel instance) =>
    <String, dynamic>{
      'classId': instance.classId,
      'className': instance.className,
      'totalStudents': instance.totalStudents,
      'activeStudents': instance.activeStudents,
      'totalDuration': instance.totalDuration,
      'totalSessions': instance.totalSessions,
      'taskBreakdown': instance.taskBreakdown,
    };

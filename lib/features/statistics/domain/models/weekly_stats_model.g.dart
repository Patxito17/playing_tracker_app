// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyStatsModel _$WeeklyStatsModelFromJson(Map<String, dynamic> json) =>
    WeeklyStatsModel(
      weekStart: const TimestampConverter().fromJson(
        json['weekStart'] as Object,
      ),
      weekEnd: const TimestampConverter().fromJson(json['weekEnd'] as Object),
      totalDuration: (json['totalDuration'] as num).toInt(),
      totalSessions: (json['totalSessions'] as num).toInt(),
      uniqueTasks: (json['uniqueTasks'] as num).toInt(),
      dailyBreakdown:
          (json['dailyBreakdown'] as List<dynamic>?)
              ?.map((e) => DailyStatsModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      taskBreakdown:
          (json['taskBreakdown'] as List<dynamic>?)
              ?.map((e) => TaskStatsModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      previousWeekDuration: (json['previousWeekDuration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WeeklyStatsModelToJson(WeeklyStatsModel instance) =>
    <String, dynamic>{
      'weekStart': const TimestampConverter().toJson(instance.weekStart),
      'weekEnd': const TimestampConverter().toJson(instance.weekEnd),
      'totalDuration': instance.totalDuration,
      'totalSessions': instance.totalSessions,
      'uniqueTasks': instance.uniqueTasks,
      'dailyBreakdown': instance.dailyBreakdown,
      'taskBreakdown': instance.taskBreakdown,
      'previousWeekDuration': instance.previousWeekDuration,
    };

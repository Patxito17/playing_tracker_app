// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyStatsModel _$DailyStatsModelFromJson(Map<String, dynamic> json) =>
    DailyStatsModel(
      date: const TimestampConverter().fromJson(json['date'] as Object),
      totalDuration: (json['totalDuration'] as num).toInt(),
      totalSessions: (json['totalSessions'] as num).toInt(),
      uniqueTasks: (json['uniqueTasks'] as num).toInt(),
    );

Map<String, dynamic> _$DailyStatsModelToJson(DailyStatsModel instance) =>
    <String, dynamic>{
      'date': const TimestampConverter().toJson(instance.date),
      'totalDuration': instance.totalDuration,
      'totalSessions': instance.totalSessions,
      'uniqueTasks': instance.uniqueTasks,
    };

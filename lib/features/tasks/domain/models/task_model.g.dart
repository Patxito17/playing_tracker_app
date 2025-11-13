// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  createdBy: json['createdBy'] as String,
  durationSuggested: (json['durationSuggested'] as num).toInt(),
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
  dueDate: _$JsonConverterFromJson<Object, Timestamp>(
    json['dueDate'],
    const TimestampConverter().fromJson,
  ),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'createdBy': instance.createdBy,
  'durationSuggested': instance.durationSuggested,
  'attachments': instance.attachments.map((e) => e.toJson()).toList(),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'dueDate': _$JsonConverterToJson<Object, Timestamp>(
    instance.dueDate,
    const TimestampConverter().toJson,
  ),
  'isActive': instance.isActive,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassModel _$ClassModelFromJson(Map<String, dynamic> json) => ClassModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  ownerTeacherId: json['ownerTeacherId'] as String,
  accessCode: json['accessCode'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ClassModelToJson(ClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'ownerTeacherId': instance.ownerTeacherId,
      'accessCode': instance.accessCode,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'isActive': instance.isActive,
    };

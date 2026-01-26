// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttachmentModel _$AttachmentModelFromJson(Map<String, dynamic> json) =>
    AttachmentModel(
      name: json['name'] as String,
      url: json['url'] as String,
      type: $enumDecode(_$AttachmentTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$AttachmentModelToJson(AttachmentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'type': _$AttachmentTypeEnumMap[instance.type]!,
    };

const _$AttachmentTypeEnumMap = {AttachmentType.link: 'link'};

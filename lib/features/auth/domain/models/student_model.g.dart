// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentModel _$StudentModelFromJson(Map<String, dynamic> json) => StudentModel(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
  isActive: json['isActive'] as bool? ?? true,
  totalSessionsCount: (json['totalSessionsCount'] as num?)?.toInt() ?? 0,
  totalDurationLogged: (json['totalDurationLogged'] as num?)?.toInt() ?? 0,
  lastSessionDate: _$JsonConverterFromJson<Object, Timestamp>(
    json['lastSessionDate'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$StudentModelToJson(StudentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'isActive': instance.isActive,
      'totalSessionsCount': instance.totalSessionsCount,
      'totalDurationLogged': instance.totalDurationLogged,
      'lastSessionDate': _$JsonConverterToJson<Object, Timestamp>(
        instance.lastSessionDate,
        const TimestampConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

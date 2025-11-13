// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipModel _$MembershipModelFromJson(Map<String, dynamic> json) =>
    MembershipModel(
      id: json['id'] as String,
      classId: json['classId'] as String,
      studentId: json['studentId'] as String,
      teacherId: json['teacherId'] as String,
      className: json['className'] as String,
      joinedAt: const TimestampConverter().fromJson(json['joinedAt'] as Object),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$MembershipModelToJson(MembershipModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'studentId': instance.studentId,
      'teacherId': instance.teacherId,
      'className': instance.className,
      'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
      'isActive': instance.isActive,
    };

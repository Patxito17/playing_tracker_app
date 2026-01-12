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
      studentName: json['studentName'] as String?,
      studentEmail: json['studentEmail'] as String?,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String?,
      teacherEmail: json['teacherEmail'] as String?,
      className: json['className'] as String,
      classIsActive: json['classIsActive'] as bool? ?? true,
      joinedAt: const TimestampConverter().fromJson(json['joinedAt'] as Object),
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Object,
      ),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$MembershipModelToJson(MembershipModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'studentEmail': instance.studentEmail,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'teacherEmail': instance.teacherEmail,
      'className': instance.className,
      'classIsActive': instance.classIsActive,
      'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'isActive': instance.isActive,
    };

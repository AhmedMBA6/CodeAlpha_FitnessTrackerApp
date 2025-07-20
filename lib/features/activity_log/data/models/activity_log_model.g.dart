// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityLogModel _$ActivityLogModelFromJson(Map<String, dynamic> json) =>
    ActivityLogModel(
      id: json['id'] as String?,
      activityType: json['activityType'] as String,
      duration: (json['duration'] as num).toInt(),
      calories: (json['calories'] as num).toDouble(),
      date: ActivityLogModel._dateTimeFromJson(json['date']),
      heartRate: (json['heartRate'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ActivityLogModelToJson(ActivityLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityType': instance.activityType,
      'duration': instance.duration,
      'calories': instance.calories,
      'date': ActivityLogModel._dateTimeToJson(instance.date),
      'heartRate': instance.heartRate,
      'distance': instance.distance,
      'tags': instance.tags,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityGoal _$ActivityGoalFromJson(Map<String, dynamic> json) => ActivityGoal(
  id: json['id'] as String,
  goalType: $enumDecode(_$GoalTypeEnumMap, json['goalType']),
  description: json['description'] as String?,
  targetValue: (json['targetValue'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  createdAt: ActivityGoal._dateTimeFromJson(json['createdAt']),
  progress: (json['progress'] as num?)?.toDouble(),
  isCompleted: json['isCompleted'] as bool?,
  isArchived: json['isArchived'] == null
      ? false
      : ActivityGoal._boolFromInt(json['isArchived']),
);

Map<String, dynamic> _$ActivityGoalToJson(ActivityGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalType': _$GoalTypeEnumMap[instance.goalType]!,
      'description': instance.description,
      'targetValue': instance.targetValue,
      'unit': instance.unit,
      'tags': instance.tags,
      'createdAt': ActivityGoal._dateTimeToJson(instance.createdAt),
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
      'isArchived': ActivityGoal._boolToInt(instance.isArchived),
    };

const _$GoalTypeEnumMap = {
  GoalType.quantitative: 'quantitative',
  GoalType.qualitative: 'qualitative',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityGoal _$ActivityGoalFromJson(Map<String, dynamic> json) => ActivityGoal(
  type: $enumDecode(_$GoalTypeEnumMap, json['type']),
  goalDistance: (json['goalDistance'] as num?)?.toDouble(),
  goalDestination: json['goalDestination'] == null
      ? null
      : RoutePoint.fromJson(json['goalDestination'] as Map<String, dynamic>),
  goalDescription: json['goalDescription'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ActivityGoalToJson(ActivityGoal instance) =>
    <String, dynamic>{
      'type': _$GoalTypeEnumMap[instance.type]!,
      'goalDistance': instance.goalDistance,
      'goalDestination': instance.goalDestination,
      'goalDescription': instance.goalDescription,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$GoalTypeEnumMap = {
  GoalType.distance: 'distance',
  GoalType.destination: 'destination',
};

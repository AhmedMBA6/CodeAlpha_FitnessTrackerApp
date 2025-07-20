// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_goal_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityLogGoalLink _$ActivityLogGoalLinkFromJson(Map<String, dynamic> json) =>
    ActivityLogGoalLink(
      id: json['id'] as String,
      activityLogId: json['activityLogId'] as String,
      goalId: json['goalId'] as String,
      contributedValue: (json['contributedValue'] as num).toDouble(),
      contributionType: json['contributionType'] as String,
      linkedAt: DateTime.parse(json['linkedAt'] as String),
      unlinkedAt: json['unlinkedAt'] == null
          ? null
          : DateTime.parse(json['unlinkedAt'] as String),
    );

Map<String, dynamic> _$ActivityLogGoalLinkToJson(
  ActivityLogGoalLink instance,
) => <String, dynamic>{
  'id': instance.id,
  'activityLogId': instance.activityLogId,
  'goalId': instance.goalId,
  'contributedValue': instance.contributedValue,
  'contributionType': instance.contributionType,
  'linkedAt': instance.linkedAt.toIso8601String(),
  'unlinkedAt': instance.unlinkedAt?.toIso8601String(),
};

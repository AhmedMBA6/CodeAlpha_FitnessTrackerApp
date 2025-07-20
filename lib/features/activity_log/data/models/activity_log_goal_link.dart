import 'package:json_annotation/json_annotation.dart';

part 'activity_log_goal_link.g.dart';

@JsonSerializable()
class ActivityLogGoalLink {
  final String id;
  final String activityLogId;
  final String goalId;
  final double contributedValue;
  final String contributionType; // e.g., 'calories', 'duration', 'tag'
  final DateTime linkedAt;
  final DateTime? unlinkedAt;

  ActivityLogGoalLink({
    required this.id,
    required this.activityLogId,
    required this.goalId,
    required this.contributedValue,
    required this.contributionType,
    required this.linkedAt,
    this.unlinkedAt,
  });

  factory ActivityLogGoalLink.fromJson(Map<String, dynamic> json) => _$ActivityLogGoalLinkFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityLogGoalLinkToJson(this);

  ActivityLogGoalLink copyWith({
    String? id,
    String? activityLogId,
    String? goalId,
    double? contributedValue,
    String? contributionType,
    DateTime? linkedAt,
    DateTime? unlinkedAt,
  }) {
    return ActivityLogGoalLink(
      id: id ?? this.id,
      activityLogId: activityLogId ?? this.activityLogId,
      goalId: goalId ?? this.goalId,
      contributedValue: contributedValue ?? this.contributedValue,
      contributionType: contributionType ?? this.contributionType,
      linkedAt: linkedAt ?? this.linkedAt,
      unlinkedAt: unlinkedAt ?? this.unlinkedAt,
    );
  }
} 
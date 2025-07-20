import 'package:json_annotation/json_annotation.dart';

part 'activity_goal.g.dart';

enum GoalType {
  @JsonValue('quantitative')
  quantitative,
  @JsonValue('qualitative')
  qualitative,
}

@JsonSerializable()
class ActivityGoal {
  final String id;
  final GoalType goalType;
  final String? description;
  // For quantitative goals
  final double? targetValue;
  final String? unit; // e.g., 'calories', 'minutes', 'km'
  // For qualitative goals
  final List<String>? tags; // e.g., ['trapezius', 'strength']
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  // Optionally, for UI
  final double? progress; // 0.0 - 1.0
  final bool? isCompleted;
  @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt)
  final bool isArchived;

  ActivityGoal({
    required this.id,
    required this.goalType,
    this.description,
    this.targetValue,
    this.unit,
    this.tags,
    required this.createdAt,
    this.progress,
    this.isCompleted,
    this.isArchived = false,
  });

  factory ActivityGoal.fromJson(Map<String, dynamic> json) => _$ActivityGoalFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityGoalToJson(this);

  static DateTime _dateTimeFromJson(dynamic value) => value is String ? DateTime.parse(value) : value as DateTime;
  static String _dateTimeToJson(DateTime value) => value.toIso8601String();
  static bool _boolFromInt(dynamic value) => value is int ? value == 1 : value == true;
  static int _boolToInt(bool value) => value ? 1 : 0;

  ActivityGoal copyWith({
    String? id,
    GoalType? goalType,
    String? description,
    double? targetValue,
    String? unit,
    List<String>? tags,
    DateTime? createdAt,
    double? progress,
    bool? isCompleted,
    bool? isArchived,
  }) {
    return ActivityGoal(
      id: id ?? this.id,
      goalType: goalType ?? this.goalType,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
    );
  }
} 
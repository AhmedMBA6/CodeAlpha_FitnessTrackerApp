import 'package:json_annotation/json_annotation.dart';

part 'activity_log_model.g.dart';

@JsonSerializable()
class ActivityLogModel {
  final String? id;
  final String activityType;
  final int duration; // in minutes
  final double calories;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime date;
  final int? heartRate;
  final double? distance; // in km
  final List<String>? tags; // e.g., ['trapezius', 'cardio']
  @JsonKey(includeFromJson: false, includeToJson: false)
  /// Transient: Only for UI convenience, not persisted. Do not use for DB queries.
  final List<String>? linkedGoalIds;

  ActivityLogModel({
    this.id,
    required this.activityType,
    required this.duration,
    required this.calories,
    required this.date,
    this.heartRate,
    this.distance,
    this.tags,
    this.linkedGoalIds,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) => _$ActivityLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityLogModelToJson(this);

  ActivityLogModel copyWith({
    String? id,
    String? activityType,
    int? duration,
    double? calories,
    DateTime? date,
    int? heartRate,
    double? distance,
    List<String>? tags,
    List<String>? linkedGoalIds,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      date: date ?? this.date,
      heartRate: heartRate ?? this.heartRate,
      distance: distance ?? this.distance,
      tags: tags ?? this.tags,
      linkedGoalIds: linkedGoalIds ?? this.linkedGoalIds,
    );
  }

  static DateTime _dateTimeFromJson(dynamic value) => value is String ? DateTime.parse(value) : value as DateTime;
  static String _dateTimeToJson(DateTime value) => value.toIso8601String();

  /// Domain-level validation for activity log.
  bool isValid({bool? realTime}) {
    final validDuration = duration > 0;
    final validCalories = calories >= 0;
    final validRealTime = realTime == true ? duration > 0 : true;
    return validDuration && validCalories && validRealTime;
  }
} 
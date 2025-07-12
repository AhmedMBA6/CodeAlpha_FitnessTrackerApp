import 'package:json_annotation/json_annotation.dart';
import '../../../route_tracking/data/models/route_point.dart';

part 'activity_goal.g.dart';

enum GoalType {
  @JsonValue('distance')
  distance,
  @JsonValue('destination')
  destination,
}

@JsonSerializable()
class ActivityGoal {
  final GoalType type;
  final double? goalDistance; // in meters, for distance goals
  final RoutePoint? goalDestination; // for destination goals
  final String? goalDescription; // optional description
  final DateTime createdAt;

  const ActivityGoal({
    required this.type,
    this.goalDistance,
    this.goalDestination,
    this.goalDescription,
    required this.createdAt,
  });

  factory ActivityGoal.fromJson(Map<String, dynamic> json) => _$ActivityGoalFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityGoalToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'goal_distance': goalDistance,
      'goal_destination_lat': goalDestination?.latitude,
      'goal_destination_lng': goalDestination?.longitude,
      'goal_destination_timestamp': goalDestination?.timestamp.toIso8601String(),
      'goal_description': goalDescription,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ActivityGoal.fromMap(Map<String, dynamic> map) {
    RoutePoint? destination;
    if (map['goal_destination_lat'] != null && map['goal_destination_lng'] != null) {
      destination = RoutePoint(
        latitude: map['goal_destination_lat'] as double,
        longitude: map['goal_destination_lng'] as double,
        timestamp: DateTime.parse(map['goal_destination_timestamp'] as String),
      );
    }

    return ActivityGoal(
      type: GoalType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => GoalType.distance,
      ),
      goalDistance: map['goal_distance'] as double?,
      goalDestination: destination,
      goalDescription: map['goal_description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  ActivityGoal copyWith({
    GoalType? type,
    double? goalDistance,
    RoutePoint? goalDestination,
    String? goalDescription,
    DateTime? createdAt,
  }) {
    return ActivityGoal(
      type: type ?? this.type,
      goalDistance: goalDistance ?? this.goalDistance,
      goalDestination: goalDestination ?? this.goalDestination,
      goalDescription: goalDescription ?? this.goalDescription,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a distance-based goal
  factory ActivityGoal.distance({
    required double distanceInMeters,
    String? description,
  }) {
    return ActivityGoal(
      type: GoalType.distance,
      goalDistance: distanceInMeters,
      goalDescription: description,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a destination-based goal
  factory ActivityGoal.destination({
    required RoutePoint destination,
    String? description,
  }) {
    return ActivityGoal(
      type: GoalType.destination,
      goalDestination: destination,
      goalDescription: description,
      createdAt: DateTime.now(),
    );
  }

  /// Validates the goal data
  bool get isValid {
    switch (type) {
      case GoalType.distance:
        return goalDistance != null && goalDistance! > 0;
      case GoalType.destination:
        return goalDestination != null;
    }
  }

  /// Gets a human-readable description of the goal
  String get displayText {
    switch (type) {
      case GoalType.distance:
        if (goalDistance! < 1000) {
          return '${goalDistance!.toStringAsFixed(0)}m';
        } else {
          return '${(goalDistance! / 1000).toStringAsFixed(2)}km';
        }
      case GoalType.destination:
        return goalDescription ?? 'Destination';
    }
  }

  @override
  String toString() {
    return 'ActivityGoal(type: $type, goalDistance: $goalDistance, goalDestination: $goalDestination, goalDescription: $goalDescription, createdAt: $createdAt)';
  }
} 
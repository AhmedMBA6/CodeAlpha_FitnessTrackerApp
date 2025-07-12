import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
import 'route_point.dart';
import '../../../activity_goals/data/models/activity_goal.dart';

part 'route_track.g.dart';

@JsonSerializable()
class RouteTrack {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final List<RoutePoint> points;
  final double totalDistance; // in meters
  final Duration totalDuration;
  final double averageSpeed; // in meters per second
  final double maxSpeed; // in meters per second
  final double? elevationGain; // in meters
  final String activityType; // running, cycling, walking, etc.
  final Duration pausedDuration; // total paused time
  final DateTime? lastPausedTime; // when pause started
  final ActivityGoal? goal; // optional goal for this activity

  const RouteTrack({
    required this.id,
    required this.name,
    required this.startTime,
    this.endTime,
    required this.points,
    required this.totalDistance,
    required this.totalDuration,
    required this.averageSpeed,
    required this.maxSpeed,
    this.elevationGain,
    required this.activityType,
    this.pausedDuration = Duration.zero,
    this.lastPausedTime,
    this.goal,
  });

  factory RouteTrack.fromJson(Map<String, dynamic> json) => _$RouteTrackFromJson(json);
  Map<String, dynamic> toJson() => _$RouteTrackToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_distance': totalDistance,
      'total_duration': totalDuration.inMilliseconds,
      'average_speed': averageSpeed,
      'max_speed': maxSpeed,
      'elevation_gain': elevationGain,
      'activity_type': activityType,
      'paused_duration': pausedDuration.inMilliseconds,
      'last_paused_time': lastPausedTime?.toIso8601String(),
      'goal_type': goal?.type.name,
      'goal_distance': goal?.goalDistance,
      'goal_destination_lat': goal?.goalDestination?.latitude,
      'goal_destination_lng': goal?.goalDestination?.longitude,
      'goal_destination_timestamp': goal?.goalDestination?.timestamp.toIso8601String(),
      'goal_description': goal?.goalDescription,
      'goal_created_at': goal?.createdAt.toIso8601String(),
    };
  }

  factory RouteTrack.fromMap(Map<String, dynamic> map, [List<RoutePoint>? points]) {
    ActivityGoal? goal;
    if (map['goal_type'] != null) {
      RoutePoint? destination;
      if (map['goal_destination_lat'] != null && map['goal_destination_lng'] != null) {
        destination = RoutePoint(
          latitude: map['goal_destination_lat'] as double,
          longitude: map['goal_destination_lng'] as double,
          timestamp: DateTime.parse(map['goal_destination_timestamp'] as String),
        );
      }

      goal = ActivityGoal(
        type: GoalType.values.firstWhere(
          (e) => e.name == map['goal_type'],
          orElse: () => GoalType.distance,
        ),
        goalDistance: map['goal_distance'] as double?,
        goalDestination: destination,
        goalDescription: map['goal_description'] as String?,
        createdAt: DateTime.parse(map['goal_created_at'] as String),
      );
    }

    return RouteTrack(
      id: map['id'] as String,
      name: map['name'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      points: points ?? [],
      totalDistance: (map['total_distance'] as double?) ?? 0.0,
      totalDuration: Duration(milliseconds: (map['total_duration'] as int?) ?? 0),
      averageSpeed: (map['average_speed'] as double?) ?? 0.0,
      maxSpeed: (map['max_speed'] as double?) ?? 0.0,
      elevationGain: map['elevation_gain'] as double?,
      activityType: map['activity_type'] as String,
      pausedDuration: Duration(milliseconds: (map['paused_duration'] as int?) ?? 0),
      lastPausedTime: map['last_paused_time'] != null && map['last_paused_time'] is String
          ? DateTime.tryParse(map['last_paused_time'] as String)
          : null,
      goal: goal,
    );
  }

  RouteTrack copyWith({
    String? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    List<RoutePoint>? points,
    double? totalDistance,
    Duration? totalDuration,
    double? averageSpeed,
    double? maxSpeed,
    double? elevationGain,
    String? activityType,
    Duration? pausedDuration,
    DateTime? lastPausedTime,
    ActivityGoal? goal,
  }) {
    return RouteTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      points: points ?? this.points,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDuration: totalDuration ?? this.totalDuration,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      elevationGain: elevationGain ?? this.elevationGain,
      activityType: activityType ?? this.activityType,
      pausedDuration: pausedDuration ?? this.pausedDuration,
      lastPausedTime: lastPausedTime ?? this.lastPausedTime,
      goal: goal ?? this.goal,
    );
  }

  bool get isActive => endTime == null;

  Duration get currentDuration {
    if (endTime != null) return totalDuration;
    final now = DateTime.now();
    final paused = lastPausedTime != null ? now.difference(lastPausedTime!) : Duration.zero;
    return now.difference(startTime) - pausedDuration - paused;
  }

  double get currentDistance {
    if (points.length < 2) return 0.0;
    double distance = 0.0;
    for (int i = 1; i < points.length; i++) {
      distance += _calculateDistance(points[i - 1], points[i]);
    }
    return distance;
  }

  double _calculateDistance(RoutePoint point1, RoutePoint point2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final lat1Rad = point1.latitude * (pi / 180);
    final lat2Rad = point2.latitude * (pi / 180);
    final deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final deltaLonRad = (point2.longitude - point1.longitude) * (pi / 180);
    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Calculates progress towards the goal (0.0 to 1.0)
  double get goalProgress {
    if (goal == null) return 0.0;
    
    switch (goal!.type) {
      case GoalType.distance:
        if (goal!.goalDistance == null || goal!.goalDistance! <= 0) return 0.0;
        return (currentDistance / goal!.goalDistance!).clamp(0.0, 1.0);
      case GoalType.destination:
        if (goal!.goalDestination == null || points.isEmpty) return 0.0;
        final currentPoint = points.last;
        final distanceToGoal = _calculateDistance(currentPoint, goal!.goalDestination!);
        // Consider goal reached if within 50 meters
        return distanceToGoal <= 50 ? 1.0 : 0.0;
    }
  }

  /// Gets the distance to the goal destination in meters
  double? get distanceToGoal {
    if (goal?.type != GoalType.destination || goal?.goalDestination == null || points.isEmpty) {
      return null;
    }
    final currentPoint = points.last;
    return _calculateDistance(currentPoint, goal!.goalDestination!);
  }

  /// Checks if the goal has been reached
  bool get isGoalReached {
    if (goal == null) return false;
    
    switch (goal!.type) {
      case GoalType.distance:
        return currentDistance >= (goal!.goalDistance ?? 0);
      case GoalType.destination:
        return distanceToGoal != null && distanceToGoal! <= 50; // Within 50 meters
    }
  }

  @override
  String toString() {
    return 'RouteTrack(id: $id, name: $name, startTime: $startTime, endTime: $endTime, points: ${points.length}, totalDistance: $totalDistance, totalDuration: $totalDuration, averageSpeed: $averageSpeed, maxSpeed: $maxSpeed, elevationGain: $elevationGain, activityType: $activityType, goal: $goal)';
  }
} 
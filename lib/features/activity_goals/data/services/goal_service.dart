import 'dart:math';
import '../models/activity_goal.dart';
import '../../../route_tracking/data/models/route_point.dart';

class GoalService {
  static const double _earthRadius = 6371000; // Earth's radius in meters
  static const double _goalReachedThreshold = 50; // meters

  /// Calculates distance between two points using Haversine formula
  static double calculateDistance(RoutePoint point1, RoutePoint point2) {
    final lat1Rad = point1.latitude * (pi / 180);
    final lat2Rad = point2.latitude * (pi / 180);
    final deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final deltaLonRad = (point2.longitude - point1.longitude) * (pi / 180);

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadius * c;
  }

  /// Calculates progress towards a distance goal (0.0 to 1.0)
  static double calculateDistanceGoalProgress(double currentDistance, double goalDistance) {
    if (goalDistance <= 0) return 0.0;
    return (currentDistance / goalDistance).clamp(0.0, 1.0);
  }

  /// Calculates progress towards a destination goal (0.0 to 1.0)
  static double calculateDestinationGoalProgress(RoutePoint currentPosition, RoutePoint goalDestination) {
    final distanceToGoal = calculateDistance(currentPosition, goalDestination);
    return distanceToGoal <= _goalReachedThreshold ? 1.0 : 0.0;
  }

  /// Checks if a distance goal has been reached
  static bool isDistanceGoalReached(double currentDistance, double goalDistance) {
    return currentDistance >= goalDistance;
  }

  /// Checks if a destination goal has been reached
  static bool isDestinationGoalReached(RoutePoint currentPosition, RoutePoint goalDestination) {
    final distanceToGoal = calculateDistance(currentPosition, goalDestination);
    return distanceToGoal <= _goalReachedThreshold;
  }

  /// Gets the distance to a destination goal
  static double getDistanceToGoal(RoutePoint currentPosition, RoutePoint goalDestination) {
    return calculateDistance(currentPosition, goalDestination);
  }

  /// Validates a goal configuration
  static bool isValidGoal(ActivityGoal goal) {
    switch (goal.type) {
      case GoalType.distance:
        return goal.goalDistance != null && goal.goalDistance! > 0;
      case GoalType.destination:
        return goal.goalDestination != null;
    }
  }

  /// Formats distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)}km';
    }
  }

  /// Formats progress as a percentage
  static String formatProgress(double progress) {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  /// Gets a human-readable goal description
  static String getGoalDescription(ActivityGoal goal) {
    switch (goal.type) {
      case GoalType.distance:
        return formatDistance(goal.goalDistance!);
      case GoalType.destination:
        return goal.goalDescription ?? 'Destination';
    }
  }

  /// Gets a human-readable progress description
  static String getProgressDescription(ActivityGoal goal, double currentDistance, RoutePoint? currentPosition) {
    switch (goal.type) {
      case GoalType.distance:
        final progress = calculateDistanceGoalProgress(currentDistance, goal.goalDistance!);
        final remaining = goal.goalDistance! - currentDistance;
        if (remaining <= 0) {
          return 'Goal reached!';
        }
        return '${formatDistance(currentDistance)} / ${formatDistance(goal.goalDistance!)} (${formatProgress(progress)})';
      
      case GoalType.destination:
        if (currentPosition == null) return 'Starting...';
        final distanceToGoal = getDistanceToGoal(currentPosition, goal.goalDestination!);
        if (distanceToGoal <= _goalReachedThreshold) {
          return 'Goal reached!';
        }
        return '${formatDistance(distanceToGoal)} to go';
    }
  }
} 
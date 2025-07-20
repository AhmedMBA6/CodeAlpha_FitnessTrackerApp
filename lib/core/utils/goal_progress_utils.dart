import '../../features/activity_goals/data/models/activity_goal.dart';
import '../../features/activity_log/data/models/activity_log_model.dart';

/// Enum representing the status of a goal.
enum GoalStatus {
  notStarted,
  inProgress,
  almostDone,
  completed,
  inactive,
}

class GoalProgressResult {
  final double progress; // 0.0 to 1.0
  final GoalStatus status;
  GoalProgressResult(this.progress, this.status);
}

class GoalProgressService {
  /// Calculates progress and status for a goal given its linked activity logs.
  static GoalProgressResult calculateGoalProgress(ActivityGoal goal, List<ActivityLogModel> logs) {
    double progress = 0.0;
    GoalStatus status = GoalStatus.notStarted;
    if (goal.goalType == GoalType.quantitative) {
      if (goal.unit == 'calories') {
        final totalCalories = logs.fold<double>(0.0, (sum, log) => sum + (log.calories ?? 0.0));
        progress = (goal.targetValue != null && goal.targetValue! > 0)
            ? (totalCalories / goal.targetValue!).clamp(0.0, 1.0)
            : 0.0;
      } else if (goal.unit == 'km') {
        final totalDistance = logs.fold<double>(0.0, (sum, log) => sum + (log.distance ?? 0.0));
        progress = (goal.targetValue != null && goal.targetValue! > 0)
            ? (totalDistance / goal.targetValue!).clamp(0.0, 1.0)
            : 0.0;
      } else if (goal.unit == 'minutes' || goal.unit == 'hours') {
        final totalMinutes = logs.fold<double>(0.0, (sum, log) => sum + (log.duration ?? 0.0));
        progress = (goal.targetValue != null && goal.targetValue! > 0)
            ? (totalMinutes / goal.targetValue!).clamp(0.0, 1.0)
            : 0.0;
      }
    } else if (goal.goalType == GoalType.qualitative) {
      // For qualitative, consider as completed if any log has matching tags
      final hasTag = logs.any((log) => log.tags != null && goal.tags != null && log.tags!.any((t) => goal.tags!.contains(t)));
      progress = hasTag ? 1.0 : 0.0;
    }
    // Status logic
    if (goal.isCompleted == true || progress >= 1.0) {
      status = GoalStatus.completed;
    } else {
      final now = DateTime.now();
      final lastUpdated = goal.createdAt; // createdAt is non-nullable
      final daysSinceUpdate = now.difference(lastUpdated).inDays;
      if (daysSinceUpdate >= 7) {
        status = GoalStatus.inactive;
      } else if (progress >= 0.8) {
        status = GoalStatus.almostDone;
      } else if (progress > 0.0) {
        status = GoalStatus.inProgress;
      } else {
        status = GoalStatus.notStarted;
      }
    }
    return GoalProgressResult(progress, status);
  }
}

class GoalSuggestionService {
  /// Returns smart goal suggestions based on recent activity logs, or static templates if no data.
  static List<ActivityGoal> getGoalSuggestions(List<ActivityLogModel> recentActivities) {
    if (recentActivities.isEmpty) {
      return _staticGoalTemplates();
    }
    final last = recentActivities.first;
    final List<ActivityGoal> suggestions = [];
    if (last.calories > 0) {
      suggestions.add(ActivityGoal(
        id: 'suggestion_calories',
        goalType: GoalType.quantitative,
        description: 'Burn ${(last.calories * 1.2).toStringAsFixed(0)} calories',
        targetValue: (last.calories * 1.2),
        unit: 'calories',
        createdAt: DateTime.now(),
      ));
    }
    if (last.distance != null && last.distance! > 0) {
      suggestions.add(ActivityGoal(
        id: 'suggestion_distance',
        goalType: GoalType.quantitative,
        description: 'Run ${(last.distance! * 1.2).toStringAsFixed(2)} km',
        targetValue: (last.distance! * 1.2),
        unit: 'km',
        createdAt: DateTime.now(),
      ));
    }
    if (last.duration > 0) {
      suggestions.add(ActivityGoal(
        id: 'suggestion_duration',
        goalType: GoalType.quantitative,
        description: 'Train for ${(last.duration * 1.2).toStringAsFixed(0)} minutes',
        targetValue: (last.duration * 1.2),
        unit: 'minutes',
        createdAt: DateTime.now(),
      ));
    }
    if (last.tags != null && last.tags!.isNotEmpty) {
      suggestions.add(ActivityGoal(
        id: 'suggestion_tags',
        goalType: GoalType.qualitative,
        description: 'Target ${last.tags!.join(", ")}',
        tags: last.tags,
        createdAt: DateTime.now(),
      ));
    }
    if (suggestions.isEmpty) {
      return _staticGoalTemplates();
    }
    return suggestions;
  }

  static List<ActivityGoal> _staticGoalTemplates() {
    return [
      ActivityGoal(
        id: 'template1',
        goalType: GoalType.quantitative,
        description: 'Burn 200 calories',
        targetValue: 200,
        unit: 'calories',
        createdAt: DateTime.now(),
      ),
      ActivityGoal(
        id: 'template2',
        goalType: GoalType.quantitative,
        description: 'Run 3 km',
        targetValue: 3,
        unit: 'km',
        createdAt: DateTime.now(),
      ),
      ActivityGoal(
        id: 'template3',
        goalType: GoalType.quantitative,
        description: 'Train for 30 minutes',
        targetValue: 30,
        unit: 'minutes',
        createdAt: DateTime.now(),
      ),
      ActivityGoal(
        id: 'template4',
        goalType: GoalType.qualitative,
        description: 'Target trapezius muscle',
        tags: ['trapezius'],
        createdAt: DateTime.now(),
      ),
    ];
  }
}

// Utility function for user-friendly goal state label
String getGoalStateLabel(double progress, bool isCompleted) {
  if (isCompleted || progress >= 1.0) return 'Completed';
  if (progress >= 0.8) return 'Almost there';
  if (progress >= 0.5) return 'In Progress';
  if (progress > 0.0) return 'Started';
  return 'Not Started';
} 
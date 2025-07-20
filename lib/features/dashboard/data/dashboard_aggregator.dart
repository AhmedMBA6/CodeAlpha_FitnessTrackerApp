import '../../activity_log/data/models/activity_log_model.dart';
import 'dashboard_filter_service.dart';
import '../../activity_goals/data/models/activity_goal.dart';
import '../../activity_log/data/models/activity_log_goal_link.dart';

/// Data class representing a summary of activity logs for a specific date.
class DashboardSummary {
  /// The date for this summary.
  final DateTime date;
  /// The total calories burned on this date.
  final double totalCalories;
  /// The total duration (minutes) of activities on this date.
  final int totalDuration;

  /// Creates a [DashboardSummary].
  const DashboardSummary({
    required this.date,
    required this.totalCalories,
    required this.totalDuration,
  });
}

/// Data class representing aggregated metrics for a set of activity logs.
class DashboardMetrics {
  /// The total calories burned in the period.
  final double totalCalories;
  /// The total duration (minutes) of activities in the period.
  final int totalDuration;
  /// The total number of activities in the period.
  final int totalActivities;
  /// The average duration per activity (minutes).
  final double averageDuration;
  /// A breakdown of activity types and their counts.
  final Map<String, int> activityTypeBreakdown;
  /// The average calories burned per activity.
  final double averageCaloriesPerActivity;

  /// Creates a [DashboardMetrics].
  const DashboardMetrics({
    required this.totalCalories,
    required this.totalDuration,
    required this.totalActivities,
    required this.averageDuration,
    required this.activityTypeBreakdown,
    required this.averageCaloriesPerActivity,
  });
}

/// Service class providing static utility methods for aggregating and summarizing activity logs for the dashboard.
class DashboardAggregator {
  /// Returns a summary for today based on the provided logs.
  static DashboardSummary getTodaySummary(List<ActivityLogModel> logs) {
    final todayLogs = DashboardFilterService.getTodayLogs(logs);
    return _calculateSummary(todayLogs, DateTime.now());
  }

  /// Returns a list of summaries for each of the last 7 days (including today).
  static List<DashboardSummary> getWeeklySummary(List<ActivityLogModel> logs) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayLogs = DashboardFilterService.getLogsForDay(logs, day);
      return _calculateSummary(dayLogs, day);
    });
  }

  /// Returns comprehensive metrics for the provided (filtered) logs.
  static DashboardMetrics getMetrics(List<ActivityLogModel> logs) {
    if (logs.isEmpty) {
      return const DashboardMetrics(
        totalCalories: 0,
        totalDuration: 0,
        totalActivities: 0,
        averageDuration: 0,
        activityTypeBreakdown: {},
        averageCaloriesPerActivity: 0,
      );
    }

    final totalCalories = logs.fold(0.0, (sum, log) => sum + log.calories);
    final totalDuration = logs.fold(0, (sum, log) => sum + log.duration);
    final totalActivities = logs.length;
    final averageDuration = totalActivities > 0 ? totalDuration / totalActivities : 0.0;
    final averageCaloriesPerActivity = totalActivities > 0 ? totalCalories / totalActivities : 0.0;

    // Calculate activity type breakdown
    final activityTypeBreakdown = _calculateActivityTypeBreakdown(logs);

    return DashboardMetrics(
      totalCalories: totalCalories,
      totalDuration: totalDuration,
      totalActivities: totalActivities,
      averageDuration: averageDuration,
      activityTypeBreakdown: activityTypeBreakdown,
      averageCaloriesPerActivity: averageCaloriesPerActivity,
    );
  }

  /// Returns week-over-week trends for calories, duration, and activities.
  static Map<String, double> getWeeklyTrends(List<ActivityLogModel> logs) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final thisWeekLogs = logs.where((log) => log.date.isAfter(thisWeekStart.subtract(const Duration(seconds: 1)))).toList();
    final lastWeekLogs = logs.where((log) => log.date.isAfter(lastWeekStart.subtract(const Duration(seconds: 1))) && log.date.isBefore(thisWeekStart)).toList();
    final thisWeekMetrics = getMetrics(thisWeekLogs);
    final lastWeekMetrics = getMetrics(lastWeekLogs);
    double percentChange(double current, double prev) => prev == 0 ? (current > 0 ? 100 : 0) : ((current - prev) / prev) * 100;
    return {
      'calories': percentChange(thisWeekMetrics.totalCalories, lastWeekMetrics.totalCalories),
      'duration': percentChange(thisWeekMetrics.totalDuration.toDouble(), lastWeekMetrics.totalDuration.toDouble()),
      'activities': percentChange(thisWeekMetrics.totalActivities.toDouble(), lastWeekMetrics.totalActivities.toDouble()),
    };
  }

  /// Returns personal bests: max distance, calories, duration in a single activity.
  static Map<String, dynamic> getPersonalBests(List<ActivityLogModel> logs) {
    if (logs.isEmpty) return {};
    final maxDistance = logs.reduce((a, b) => (a.distance ?? 0) > (b.distance ?? 0) ? a : b);
    final maxCalories = logs.reduce((a, b) => a.calories > b.calories ? a : b);
    final maxDuration = logs.reduce((a, b) => a.duration > b.duration ? a : b);
    return {
      'distance': maxDistance,
      'calories': maxCalories,
      'duration': maxDuration,
    };
  }

  /// Returns the current streak (consecutive days with activity).
  static int getCurrentStreak(List<ActivityLogModel> logs) {
    if (logs.isEmpty) return 0;
    final dates = logs.map((l) => DateTime(l.date.year, l.date.month, l.date.day)).toSet().toList()..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime? prev;
    for (final d in dates) {
      if (prev == null) {
        prev = d;
        streak = 1;
      } else if (prev.difference(d).inDays == 1) {
        streak++;
        prev = d;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Aggregates dashboard stats using the join model (ActivityLogGoalLink), goals, and logs.
  static Map<String, dynamic> aggregateWithJoinModel({
    required List<ActivityGoal> goals,
    required List<ActivityLogModel> logs,
    required List<ActivityLogGoalLink> links,
  }) {
    // Map goalId to linked logIds
    final Map<String, List<ActivityLogModel>> goalToLogs = {};
    for (final goal in goals) {
      final goalLinks = links.where((l) => l.goalId == goal.id && l.unlinkedAt == null).toList();
      final logIds = goalLinks.map((l) => l.activityLogId).toSet();
      final linkedLogs = logs.where((log) => logIds.contains(log.id.toString())).toList();
      goalToLogs[goal.id] = linkedLogs;
    }
    // Logs linked to at least one goal
    final linkedLogIds = links.where((l) => l.unlinkedAt == null).map((l) => l.activityLogId).toSet();
    final logsLinkedToGoals = logs.where((log) => linkedLogIds.contains(log.id.toString())).toList();
    final logsUnlinked = logs.where((log) => !linkedLogIds.contains(log.id.toString())).toList();
    // Goal progress (simple: count of linked logs / total logs, or use goal.progress if available)
    final List<Map<String, dynamic>> topGoals = goals.map((goal) {
      final linked = goalToLogs[goal.id] ?? [];
      final progress = goal.progress ?? (goal.targetValue != null && goal.unit != null && goal.unit != ''
        ? (linked.fold<double>(0, (sum, log) {
            if (goal.unit == 'km' && log.distance != null) return sum + log.distance!;
            if (goal.unit == 'minutes' && log.duration != null) return sum + log.duration!;
            if (goal.unit == 'calories' && log.calories != null) return sum + log.calories;
            return sum;
          }) / (goal.targetValue ?? 1)
        ) : (linked.length / (goal.targetValue ?? 1)));
      return {
        'goal': goal,
        'goalProgress': progress.clamp(0.0, 1.0),
        'linkedLogs': linked,
      };
    }).toList();
    // Sort top goals by progress desc
    topGoals.sort((a, b) => (b['goalProgress'] as double).compareTo(a['goalProgress'] as double));
    // Top goals by number of linked logs
    final List<Map<String, dynamic>> topLinkedGoals = goals.map((goal) {
      final linked = goalToLogs[goal.id] ?? [];
      return {
        'goal': goal,
        'linkedCount': linked.length,
        'linkedLogs': linked,
      };
    }).toList();
    topLinkedGoals.sort((a, b) => (b['linkedCount'] as int).compareTo(a['linkedCount'] as int));
    // Breakdown: goalId -> linked log count
    final Map<String, int> goalLinkedLogCount = { for (var g in goals) g.id: (goalToLogs[g.id]?.length ?? 0) };
    // Stats
    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.isCompleted == true || (g.progress ?? 0) >= 1.0).length;
    final pendingGoals = totalGoals - completedGoals;
    final avgProgress = goals.isNotEmpty ? goals.map((g) => g.progress ?? 0.0).reduce((a, b) => a + b) / goals.length : 0.0;
    final completionRate = totalGoals > 0 ? completedGoals / totalGoals : 0.0;
    return {
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'pendingGoals': pendingGoals,
      'averageProgress': avgProgress,
      'completionRate': completionRate,
      'topGoals': topGoals,
      'topLinkedGoals': topLinkedGoals,
      'goalLinkedLogCount': goalLinkedLogCount,
      'logsLinkedToGoals': logsLinkedToGoals,
      'logsUnlinked': logsUnlinked,
      'goalToLogs': goalToLogs,
    };
  }

  /// Calculates a summary for a specific set of logs and date.
  static DashboardSummary _calculateSummary(List<ActivityLogModel> logs, DateTime date) {
    final totalCalories = logs.fold(0.0, (sum, log) => sum + log.calories);
    final totalDuration = logs.fold(0, (sum, log) => sum + log.duration);
    
    return DashboardSummary(
      date: date,
      totalCalories: totalCalories,
      totalDuration: totalDuration,
    );
  }

  /// Calculates a breakdown of activity types and their counts.
  static Map<String, int> _calculateActivityTypeBreakdown(List<ActivityLogModel> logs) {
    final Map<String, int> breakdown = {};
    for (final log in logs) {
      breakdown[log.activityType] = (breakdown[log.activityType] ?? 0) + 1;
    }
    return breakdown;
  }
} 
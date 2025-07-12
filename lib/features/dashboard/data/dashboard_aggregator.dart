import '../../activity_log/data/models/activity_log_model.dart';
import 'dashboard_filter_service.dart';

class DashboardSummary {
  final DateTime date;
  final double totalCalories;
  final int totalDuration;

  const DashboardSummary({
    required this.date,
    required this.totalCalories,
    required this.totalDuration,
  });
}

class DashboardMetrics {
  final double totalCalories;
  final int totalDuration;
  final int totalActivities;
  final double averageDuration;
  final Map<String, int> activityTypeBreakdown;
  final double averageCaloriesPerActivity;

  const DashboardMetrics({
    required this.totalCalories,
    required this.totalDuration,
    required this.totalActivities,
    required this.averageDuration,
    required this.activityTypeBreakdown,
    required this.averageCaloriesPerActivity,
  });
}

class DashboardAggregator {
  /// Get summary for today
  static DashboardSummary getTodaySummary(List<ActivityLogModel> logs) {
    final todayLogs = DashboardFilterService.getTodayLogs(logs);
    return _calculateSummary(todayLogs, DateTime.now());
  }

  /// Get summary for each of the last 7 days (including today)
  static List<DashboardSummary> getWeeklySummary(List<ActivityLogModel> logs) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayLogs = DashboardFilterService.getLogsForDay(logs, day);
      return _calculateSummary(dayLogs, day);
    });
  }

  /// Get comprehensive metrics for filtered logs
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

  /// Calculate summary for a specific set of logs and date
  static DashboardSummary _calculateSummary(List<ActivityLogModel> logs, DateTime date) {
    final totalCalories = logs.fold(0.0, (sum, log) => sum + log.calories);
    final totalDuration = logs.fold(0, (sum, log) => sum + log.duration);
    
    return DashboardSummary(
      date: date,
      totalCalories: totalCalories,
      totalDuration: totalDuration,
    );
  }

  /// Calculate activity type breakdown
  static Map<String, int> _calculateActivityTypeBreakdown(List<ActivityLogModel> logs) {
    final Map<String, int> breakdown = {};
    for (final log in logs) {
      breakdown[log.activityType] = (breakdown[log.activityType] ?? 0) + 1;
    }
    return breakdown;
  }
} 
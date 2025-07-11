import '../../activity_log/data/models/activity_log_model.dart';

class DashboardSummary {
  final DateTime date;
  final double totalCalories;
  final int totalDuration;

  DashboardSummary({
    required this.date,
    required this.totalCalories,
    required this.totalDuration,
  });
}

class DashboardAggregator {
  // Get summary for today
  static DashboardSummary getTodaySummary(List<ActivityLogModel> logs) {
    final today = DateTime.now();
    final todayLogs = logs.where((log) =>
      log.date.year == today.year &&
      log.date.month == today.month &&
      log.date.day == today.day
    );
    final totalCalories = todayLogs.fold(0.0, (sum, log) => sum + log.calories);
    final totalDuration = todayLogs.fold(0, (sum, log) => sum + log.duration);
    return DashboardSummary(
      date: today,
      totalCalories: totalCalories,
      totalDuration: totalDuration,
    );
  }

  // Get summary for each of the last 7 days (including today)
  static List<DashboardSummary> getWeeklySummary(List<ActivityLogModel> logs) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayLogs = logs.where((log) =>
        log.date.year == day.year &&
        log.date.month == day.month &&
        log.date.day == day.day
      );
      final totalCalories = dayLogs.fold(0.0, (sum, log) => sum + log.calories);
      final totalDuration = dayLogs.fold(0, (sum, log) => sum + log.duration);
      return DashboardSummary(
        date: day,
        totalCalories: totalCalories,
        totalDuration: totalDuration,
      );
    });
  }
} 
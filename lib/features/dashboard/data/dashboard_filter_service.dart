import '../../activity_log/data/models/activity_log_model.dart';

class DashboardFilterService {
  /// Filter activity logs by activity type
  static List<ActivityLogModel> filterByActivityType(
    List<ActivityLogModel> logs,
    String activityType,
  ) {
    if (activityType == 'All') {
      return logs;
    }
    return logs.where((log) => log.activityType == activityType).toList();
  }

  /// Filter activity logs by date range
  static List<ActivityLogModel> filterByDateRange(
    List<ActivityLogModel> logs,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    var filteredLogs = logs;

    if (startDate != null) {
      // Create start of day for start date
      final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
      filteredLogs = filteredLogs.where((log) => 
        log.date.isAtSameMomentAs(startOfDay) || log.date.isAfter(startOfDay)
      ).toList();
    }

    if (endDate != null) {
      // Create end of day for end date
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      filteredLogs = filteredLogs.where((log) => 
        log.date.isAtSameMomentAs(endOfDay) || log.date.isBefore(endOfDay)
      ).toList();
    }

    return filteredLogs;
  }

  /// Apply multiple filters to activity logs
  static List<ActivityLogModel> applyFilters({
    required List<ActivityLogModel> logs,
    String? activityType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filteredLogs = logs;

    // Apply activity type filter first (usually smaller result set)
    if (activityType != null && activityType != 'All') {
      filteredLogs = filterByActivityType(filteredLogs, activityType);
    }

    // Apply date range filter
    if (startDate != null || endDate != null) {
      filteredLogs = filterByDateRange(filteredLogs, startDate, endDate);
    }

    return filteredLogs;
  }

  /// Get filtered logs for today
  static List<ActivityLogModel> getTodayLogs(List<ActivityLogModel> logs) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return logs.where((log) =>
      log.date.isAtSameMomentAs(startOfDay) || 
      (log.date.isAfter(startOfDay) && log.date.isBefore(endOfDay))
    ).toList();
  }

  /// Get filtered logs for a specific day
  static List<ActivityLogModel> getLogsForDay(
    List<ActivityLogModel> logs,
    DateTime day,
  ) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);
    
    return logs.where((log) =>
      log.date.isAtSameMomentAs(startOfDay) || 
      (log.date.isAfter(startOfDay) && log.date.isBefore(endOfDay))
    ).toList();
  }
} 
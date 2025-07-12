class DateUtils {
  // Weekday labels
  static const List<String> weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  
  /// Format date as dd/MM/yyyy
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Format time as HH:mm
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Format date for export as yyyy-MM-dd
  static String formatDateForExport(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Get weekday label (e.g., 'Mon')
  static String getWeekdayLabel(DateTime date) {
    return weekdayLabels[date.weekday % 7];
  }
  
  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
  
  /// Get start of week (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }
  
  /// Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// Format date range for display
  static String formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) {
      return 'All time';
    }
    if (startDate != null && endDate != null) {
      if (startDate.isAtSameMomentAs(endDate)) {
        return formatDate(startDate);
      }
      return '${formatDate(startDate)} - ${formatDate(endDate)}';
    }
    if (startDate != null) {
      return 'From ${formatDate(startDate)}';
    }
    return 'Until ${formatDate(endDate!)}';
  }
  
  /// Get date range presets
  static Map<String, Map<String, DateTime?>> getDatePresets() {
    final now = DateTime.now();
    return {
      'Today': {
        'start': now,
        'end': now,
      },
      'Last 7 Days': {
        'start': now.subtract(const Duration(days: 6)),
        'end': now,
      },
      'Last 30 Days': {
        'start': now.subtract(const Duration(days: 29)),
        'end': now,
      },
      'This Week': {
        'start': getStartOfWeek(now),
        'end': now,
      },
      'This Month': {
        'start': getStartOfMonth(now),
        'end': now,
      },
      'All Time': {
        'start': null,
        'end': null,
      },
    };
  }
} 
/// Utility class for date and time formatting, comparison, and range calculations.
class DateUtils {
  // Weekday labels
  /// Short labels for weekdays, starting with Sunday.
  static const List<String> weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  
  /// Formats a [date] as dd/MM/yyyy.
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Formats a [date] as HH:mm (24-hour time).
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Formats a [date] for export as yyyy-MM-dd.
  static String formatDateForExport(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Returns the short weekday label (e.g., 'Mon') for a [date].
  static String getWeekdayLabel(DateTime date) {
    return weekdayLabels[date.weekday % 7];
  }
  
  /// Returns true if [date1] and [date2] are on the same calendar day.
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Returns true if [date] is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
  
  /// Returns the start of the week (Monday) for a given [date].
  static DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }
  
  /// Returns the start of the month for a given [date].
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// Formats a date range for display.
  ///
  /// If both [startDate] and [endDate] are null, returns 'All time'.
  /// If both are the same day, returns that date.
  /// If only one is provided, returns 'From ...' or 'Until ...'.
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
  
  /// Returns a map of date range presets with their corresponding start and end dates.
  /// Useful for quick filter options in the UI.
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
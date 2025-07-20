/// A collection of constants used throughout the dashboard feature for
/// activity types, date presets, chart colors, performance thresholds, UI, and formatting.
class DashboardConstants {
  // Activity Types
  /// Supported activity types for filtering and display.
  static const List<String> activityTypes = ['All', 'Running', 'Cycling', 'Walking'];
  /// The default activity type used in filters and analytics.
  static const String defaultActivityType = 'All';
  
  // Date Range Presets
  /// Preset labels for date range selection in the dashboard.
  static const Map<String, String> datePresets = {
    'Today': 'Today',
    'Last 7 Days': 'Last 7 Days',
    'Last 30 Days': 'Last 30 Days',
    'This Week': 'This Week',
    'This Month': 'This Month',
    'All Time': 'All Time',
  };
  
  // Chart Colors
  /// Color palette (as ARGB ints) for dashboard charts.
  static const List<int> chartColors = [
    0xFFFF9800, // Orange
    0xFF2196F3, // Blue
    0xFF4CAF50, // Green
    0xFF9C27B0, // Purple
    0xFFF44336, // Red
    0xFF009688, // Teal
    0xFF795548, // Brown
  ];
  
  // Performance Thresholds
  /// Calorie threshold for high intensity activities.
  static const double highIntensityCalories = 300.0;
  /// Calorie threshold for moderate intensity activities.
  static const double moderateIntensityCalories = 150.0;
  /// Duration (minutes) considered excellent for an activity.
  static const double excellentDuration = 45.0;
  /// Duration (minutes) considered good for an activity.
  static const double goodDuration = 20.0;
  
  // UI Constants
  /// Default height for dashboard charts.
  static const double chartHeight = 220.0;
  /// Elevation for dashboard cards.
  static const double cardElevation = 2.0;
  /// Default icon size for dashboard icons.
  static const double iconSize = 28.0;
  /// Radius for circular charts.
  static const double chartRadius = 60.0;
  /// Center space radius for pie charts.
  static const double centerSpaceRadius = 32.0;
  
  // Date Formatting
  /// Date format used for display (dd/MM/yyyy).
  static const String dateFormat = 'dd/MM/yyyy';
  /// Time format used for display (HH:mm).
  static const String timeFormat = 'HH:mm';
  
  // Export Constants
  /// Maximum number of recent activities to export.
  static const int maxRecentActivities = 10;
  /// Date format used for data export (yyyy-MM-dd).
  static const String exportDateFormat = 'yyyy-MM-dd';
} 
class DashboardConstants {
  // Activity Types
  static const List<String> activityTypes = ['All', 'Running', 'Cycling', 'Walking'];
  static const String defaultActivityType = 'All';
  
  // Date Range Presets
  static const Map<String, String> datePresets = {
    'Today': 'Today',
    'Last 7 Days': 'Last 7 Days',
    'Last 30 Days': 'Last 30 Days',
    'This Week': 'This Week',
    'This Month': 'This Month',
    'All Time': 'All Time',
  };
  
  // Chart Colors
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
  static const double highIntensityCalories = 300.0;
  static const double moderateIntensityCalories = 150.0;
  static const double excellentDuration = 45.0;
  static const double goodDuration = 20.0;
  
  // UI Constants
  static const double chartHeight = 220.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 28.0;
  static const double chartRadius = 60.0;
  static const double centerSpaceRadius = 32.0;
  
  // Date Formatting
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  
  // Export Constants
  static const int maxRecentActivities = 10;
  static const String exportDateFormat = 'yyyy-MM-dd';
} 
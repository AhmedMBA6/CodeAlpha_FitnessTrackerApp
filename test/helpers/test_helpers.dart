import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_model.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_aggregator.dart';

/// Test helper class for creating test data
class TestHelpers {
  /// Create a sample ActivityLogModel for testing
  static ActivityLogModel createSampleActivityLog({
    int? id,
    String activityType = 'Running',
    int duration = 30,
    double calories = 150.0,
    DateTime? date,
    int? heartRate,
    double? distance,
  }) {
    return ActivityLogModel(
      id: id ?? 1,
      activityType: activityType,
      duration: duration,
      calories: calories,
      date: date ?? DateTime.now(),
      heartRate: heartRate,
      distance: distance,
    );
  }

  /// Create a list of sample activity logs for testing
  static List<ActivityLogModel> createSampleActivityLogs() {
    final now = DateTime.now();
    return [
      createSampleActivityLog(
        id: 1,
        activityType: 'Running',
        duration: 30,
        calories: 150.0,
        date: now,
      ),
      createSampleActivityLog(
        id: 2,
        activityType: 'Cycling',
        duration: 45,
        calories: 200.0,
        date: now.subtract(const Duration(days: 1)),
      ),
      createSampleActivityLog(
        id: 3,
        activityType: 'Walking',
        duration: 20,
        calories: 80.0,
        date: now.subtract(const Duration(days: 2)),
      ),
      createSampleActivityLog(
        id: 4,
        activityType: 'Running',
        duration: 35,
        calories: 175.0,
        date: now.subtract(const Duration(days: 3)),
      ),
      createSampleActivityLog(
        id: 5,
        activityType: 'Cycling',
        duration: 60,
        calories: 300.0,
        date: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  /// Create a sample DashboardSummary for testing
  static DashboardSummary createSampleDashboardSummary({
    DateTime? date,
    double totalCalories = 150.0,
    int totalDuration = 30,
  }) {
    return DashboardSummary(
      date: date ?? DateTime.now(),
      totalCalories: totalCalories,
      totalDuration: totalDuration,
    );
  }

  /// Create a sample DashboardMetrics for testing
  static DashboardMetrics createSampleDashboardMetrics({
    double totalCalories = 500.0,
    int totalDuration = 150,
    int totalActivities = 5,
    double averageDuration = 30.0,
    Map<String, int>? activityTypeBreakdown,
    double averageCaloriesPerActivity = 100.0,
  }) {
    return DashboardMetrics(
      totalCalories: totalCalories,
      totalDuration: totalDuration,
      totalActivities: totalActivities,
      averageDuration: averageDuration,
      activityTypeBreakdown: activityTypeBreakdown ?? {'Running': 2, 'Cycling': 2, 'Walking': 1},
      averageCaloriesPerActivity: averageCaloriesPerActivity,
    );
  }

  /// Wait for async operations to complete
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Tap a widget and wait for rebuild
  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await waitForAsync(tester);
  }

  /// Enter text and wait for rebuild
  static Future<void> enterTextAndWait(WidgetTester tester, Finder finder, String text) async {
    await tester.enterText(finder, text);
    await waitForAsync(tester);
  }

  /// Scroll to find a widget
  static Future<void> scrollToFind(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 500.0);
    await waitForAsync(tester);
  }
} 
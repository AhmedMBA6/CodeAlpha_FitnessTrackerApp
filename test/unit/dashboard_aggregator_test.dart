import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_model.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_aggregator.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('DashboardAggregator', () {
    group('getTodaySummary', () {
      test('should return correct summary for today\'s activities', () {
        // Arrange
        final now = DateTime.now();
        final todayLogs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            activityType: 'Running',
            duration: 30,
            calories: 150.0,
            date: now,
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            activityType: 'Cycling',
            duration: 45,
            calories: 200.0,
            date: now,
          ),
        ];
        final allLogs = [
          ...todayLogs,
          TestHelpers.createSampleActivityLog(
            id: 3,
            activityType: 'Walking',
            duration: 20,
            calories: 80.0,
            date: now.subtract(const Duration(days: 1)),
          ),
        ];

        // Act
        final result = DashboardAggregator.getTodaySummary(allLogs);

        // Assert
        expect(result.date.day, equals(now.day));
        expect(result.date.month, equals(now.month));
        expect(result.date.year, equals(now.year));
        expect(result.totalCalories, equals(350.0));
        expect(result.totalDuration, equals(75));
      });

      test('should return zero values when no activities today', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            activityType: 'Running',
            duration: 30,
            calories: 150.0,
            date: yesterday,
          ),
        ];

        // Act
        final result = DashboardAggregator.getTodaySummary(logs);

        // Assert
        expect(result.totalCalories, equals(0.0));
        expect(result.totalDuration, equals(0));
      });

      test('should handle empty list', () {
        // Act
        final result = DashboardAggregator.getTodaySummary([]);

        // Assert
        expect(result.totalCalories, equals(0.0));
        expect(result.totalDuration, equals(0));
      });
    });

    group('getWeeklySummary', () {
      test('should return 7 days of summaries', () {
        // Arrange
        final logs = TestHelpers.createSampleActivityLogs();

        // Act
        final result = DashboardAggregator.getWeeklySummary(logs);

        // Assert
        expect(result.length, equals(7));
        expect(result.first.date.day, equals(DateTime.now().subtract(const Duration(days: 6)).day));
        expect(result.last.date.day, equals(DateTime.now().day));
      });

      test('should calculate correct totals for each day', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            activityType: 'Running',
            duration: 30,
            calories: 150.0,
            date: now,
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            activityType: 'Cycling',
            duration: 45,
            calories: 200.0,
            date: now,
          ),
          TestHelpers.createSampleActivityLog(
            id: 3,
            activityType: 'Walking',
            duration: 20,
            calories: 80.0,
            date: now.subtract(const Duration(days: 1)),
          ),
        ];

        // Act
        final result = DashboardAggregator.getWeeklySummary(logs);

        // Assert
        // Today should have 2 activities
        expect(result.last.totalCalories, equals(350.0));
        expect(result.last.totalDuration, equals(75));
        
        // Yesterday should have 1 activity
        expect(result[result.length - 2].totalCalories, equals(80.0));
        expect(result[result.length - 2].totalDuration, equals(20));
        
        // Other days should be empty
        for (int i = 0; i < result.length - 2; i++) {
          expect(result[i].totalCalories, equals(0.0));
          expect(result[i].totalDuration, equals(0));
        }
      });

      test('should handle empty list', () {
        // Act
        final result = DashboardAggregator.getWeeklySummary([]);

        // Assert
        expect(result.length, equals(7));
        for (final summary in result) {
          expect(summary.totalCalories, equals(0.0));
          expect(summary.totalDuration, equals(0));
        }
      });
    });

    group('getMetrics', () {
      test('should calculate correct metrics for activities', () {
        // Arrange
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            activityType: 'Running',
            duration: 30,
            calories: 150.0,
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            activityType: 'Cycling',
            duration: 45,
            calories: 200.0,
          ),
          TestHelpers.createSampleActivityLog(
            id: 3,
            activityType: 'Running',
            duration: 35,
            calories: 175.0,
          ),
        ];

        // Act
        final result = DashboardAggregator.getMetrics(logs);

        // Assert
        expect(result.totalActivities, equals(3));
        expect(result.totalCalories, equals(525.0));
        expect(result.totalDuration, equals(110));
        expect(result.averageDuration, equals(110 / 3));
        expect(result.averageCaloriesPerActivity, equals(525.0 / 3));
        expect(result.activityTypeBreakdown, equals({'Running': 2, 'Cycling': 1}));
      });

      test('should handle empty list', () {
        // Act
        final result = DashboardAggregator.getMetrics([]);

        // Assert
        expect(result.totalActivities, equals(0));
        expect(result.totalCalories, equals(0.0));
        expect(result.totalDuration, equals(0));
        expect(result.averageDuration, equals(0.0));
        expect(result.averageCaloriesPerActivity, equals(0.0));
        expect(result.activityTypeBreakdown, equals({}));
      });

      test('should handle single activity', () {
        // Arrange
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            activityType: 'Running',
            duration: 30,
            calories: 150.0,
          ),
        ];

        // Act
        final result = DashboardAggregator.getMetrics(logs);

        // Assert
        expect(result.totalActivities, equals(1));
        expect(result.totalCalories, equals(150.0));
        expect(result.totalDuration, equals(30));
        expect(result.averageDuration, equals(30.0));
        expect(result.averageCaloriesPerActivity, equals(150.0));
        expect(result.activityTypeBreakdown, equals({'Running': 1}));
      });

      test('should handle activities with zero values', () {
        // Arrange
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            activityType: 'Walking',
            duration: 0,
            calories: 0.0,
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            activityType: 'Running',
            duration: 30,
            calories: 150.0,
          ),
        ];

        // Act
        final result = DashboardAggregator.getMetrics(logs);

        // Assert
        expect(result.totalActivities, equals(2));
        expect(result.totalCalories, equals(150.0));
        expect(result.totalDuration, equals(30));
        expect(result.averageDuration, equals(15.0));
        expect(result.averageCaloriesPerActivity, equals(75.0));
        expect(result.activityTypeBreakdown, equals({'Walking': 1, 'Running': 1}));
      });
    });
  });
} 
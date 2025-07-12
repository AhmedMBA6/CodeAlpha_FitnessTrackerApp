import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_model.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_filter_service.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('DashboardFilterService', () {
    group('filterByActivityType', () {
      test('should return all logs when activity type is "All"', () {
        // Arrange
        final logs = TestHelpers.createSampleActivityLogs();

        // Act
        final result = DashboardFilterService.filterByActivityType(logs, 'All');

        // Assert
        expect(result.length, equals(logs.length));
        expect(result, equals(logs));
      });

      test('should filter logs by specific activity type', () {
        // Arrange
        final logs = TestHelpers.createSampleActivityLogs();

        // Act
        final result = DashboardFilterService.filterByActivityType(logs, 'Running');

        // Assert
        expect(result.length, equals(2));
        expect(result.every((log) => log.activityType == 'Running'), isTrue);
      });

      test('should return empty list when no activities match type', () {
        // Arrange
        final logs = TestHelpers.createSampleActivityLogs();

        // Act
        final result = DashboardFilterService.filterByActivityType(logs, 'Swimming');

        // Assert
        expect(result.length, equals(0));
      });

      test('should handle empty list', () {
        // Act
        final result = DashboardFilterService.filterByActivityType([], 'Running');

        // Assert
        expect(result.length, equals(0));
      });
    });

    group('filterByDateRange', () {
      test('should return all logs when no date range specified', () {
        // Arrange
        final logs = TestHelpers.createSampleActivityLogs();

        // Act
        final result = DashboardFilterService.filterByDateRange(logs, null, null);

        // Assert
        expect(result.length, equals(logs.length));
        expect(result, equals(logs));
      });

      test('should filter logs by start date', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            date: now.subtract(const Duration(days: 5)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            date: now.subtract(const Duration(days: 3)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 3,
            date: now.subtract(const Duration(days: 1)),
          ),
        ];

        // Act
        final result = DashboardFilterService.filterByDateRange(
          logs,
          now.subtract(const Duration(days: 4)),
          null,
        );

        // Assert
        expect(result.length, equals(2));
        expect(result.every((log) => log.date.isAfter(now.subtract(const Duration(days: 5)))), isTrue);
      });

      test('should filter logs by end date', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            date: now.subtract(const Duration(days: 5)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            date: now.subtract(const Duration(days: 3)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 3,
            date: now.subtract(const Duration(days: 1)),
          ),
        ];

        // Act
        final result = DashboardFilterService.filterByDateRange(
          logs,
          null,
          now.subtract(const Duration(days: 2)),
        );

        // Assert
        expect(result.length, equals(2));
        expect(result.every((log) => log.date.isBefore(now.subtract(const Duration(days: 1)))), isTrue);
      });

      test('should filter logs by both start and end date', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            date: now.subtract(const Duration(days: 5)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            date: now.subtract(const Duration(days: 3)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 3,
            date: now.subtract(const Duration(days: 1)),
          ),
        ];

        // Act
        final result = DashboardFilterService.filterByDateRange(
          logs,
          now.subtract(const Duration(days: 4)),
          now.subtract(const Duration(days: 2)),
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals(2));
      });

      test('should handle empty list', () {
        // Act
        final result = DashboardFilterService.filterByDateRange([], DateTime.now(), DateTime.now());

        // Assert
        expect(result.length, equals(0));
      });
    });

    group('applyFilters', () {
      test('should apply activity type filter only', () {
        // Arrange
        final logs = TestHelpers.createSampleActivityLogs();

        // Act
        final result = DashboardFilterService.applyFilters(
          logs: logs,
          activityType: 'Running',
        );

        // Assert
        expect(result.length, equals(2));
        expect(result.every((log) => log.activityType == 'Running'), isTrue);
      });

      test('should apply date range filter only', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            date: now.subtract(const Duration(days: 5)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            date: now.subtract(const Duration(days: 3)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 3,
            date: now.subtract(const Duration(days: 1)),
          ),
        ];

        // Act
        final result = DashboardFilterService.applyFilters(
          logs: logs,
          startDate: now.subtract(const Duration(days: 4)),
          endDate: now.subtract(const Duration(days: 2)),
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals(2));
      });

      test('should apply both activity type and date range filters', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            activityType: 'Running',
            date: now.subtract(const Duration(days: 5)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            activityType: 'Running',
            date: now.subtract(const Duration(days: 3)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 3,
            activityType: 'Cycling',
            date: now.subtract(const Duration(days: 3)),
          ),
        ];

        // Act
        final result = DashboardFilterService.applyFilters(
          logs: logs,
          activityType: 'Running',
          startDate: now.subtract(const Duration(days: 4)),
          endDate: now.subtract(const Duration(days: 2)),
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals(2));
        expect(result.first.activityType, equals('Running'));
      });

      test('should return all logs when no filters applied', () {
        // Arrange
        final logs = TestHelpers.createSampleActivityLogs();

        // Act
        final result = DashboardFilterService.applyFilters(logs: logs);

        // Assert
        expect(result.length, equals(logs.length));
        expect(result, equals(logs));
      });

      test('should handle empty list', () {
        // Act
        final result = DashboardFilterService.applyFilters(logs: []);

        // Assert
        expect(result.length, equals(0));
      });
    });

    group('getTodayLogs', () {
      test('should return only today\'s logs', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            date: now,
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            date: now.subtract(const Duration(days: 1)),
          ),
          TestHelpers.createSampleActivityLog(
            id: 3,
            date: now,
          ),
        ];

        // Act
        final result = DashboardFilterService.getTodayLogs(logs);

        // Assert
        expect(result.length, equals(2));
        expect(result.every((log) => 
          log.date.day == now.day && 
          log.date.month == now.month && 
          log.date.year == now.year
        ), isTrue);
      });

      test('should return empty list when no activities today', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            date: yesterday,
          ),
        ];

        // Act
        final result = DashboardFilterService.getTodayLogs(logs);

        // Assert
        expect(result.length, equals(0));
      });

      test('should handle empty list', () {
        // Act
        final result = DashboardFilterService.getTodayLogs([]);

        // Assert
        expect(result.length, equals(0));
      });
    });

    group('getLogsForDay', () {
      test('should return logs for specific day', () {
        // Arrange
        final targetDate = DateTime.now().subtract(const Duration(days: 2));
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            date: targetDate,
          ),
          TestHelpers.createSampleActivityLog(
            id: 2,
            date: targetDate,
          ),
          TestHelpers.createSampleActivityLog(
            id: 3,
            date: targetDate.subtract(const Duration(days: 1)),
          ),
        ];

        // Act
        final result = DashboardFilterService.getLogsForDay(logs, targetDate);

        // Assert
        expect(result.length, equals(2));
        expect(result.every((log) => 
          log.date.day == targetDate.day && 
          log.date.month == targetDate.month && 
          log.date.year == targetDate.year
        ), isTrue);
      });

      test('should return empty list when no activities on target day', () {
        // Arrange
        final targetDate = DateTime.now().subtract(const Duration(days: 2));
        final logs = [
          TestHelpers.createSampleActivityLog(
            id: 1,
            date: targetDate.subtract(const Duration(days: 1)),
          ),
        ];

        // Act
        final result = DashboardFilterService.getLogsForDay(logs, targetDate);

        // Assert
        expect(result.length, equals(0));
      });

      test('should handle empty list', () {
        // Act
        final result = DashboardFilterService.getLogsForDay([], DateTime.now());

        // Assert
        expect(result.length, equals(0));
      });
    });
  });
} 
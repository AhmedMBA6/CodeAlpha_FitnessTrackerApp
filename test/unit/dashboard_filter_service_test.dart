import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_model.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_filter_service.dart';

void main() {
  group('DashboardFilterService Tests', () {
    test('should filter by activity type correctly', () {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '3',
          activityType: 'Running',
          duration: 25,
          calories: 125.0,
          date: DateTime.now(),
        ),
      ];

      final runningLogs = DashboardFilterService.applyFilters(
        logs: logs,
        activityType: 'Running',
      );

      expect(runningLogs.length, equals(2));
      expect(runningLogs.every((log) => log.activityType == 'Running'), isTrue);
    });

    test('should filter by date range correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: yesterday,
        ),
        ActivityLogModel(
          id: '3',
          activityType: 'Walking',
          duration: 20,
          calories: 80.0,
          date: twoDaysAgo,
        ),
      ];

      final filteredLogs = DashboardFilterService.applyFilters(
        logs: logs,
        startDate: yesterday,
        endDate: today,
      );

      expect(filteredLogs.length, equals(2));
      expect(filteredLogs.any((log) => log.date == today), isTrue);
      expect(filteredLogs.any((log) => log.date == yesterday), isTrue);
      expect(filteredLogs.any((log) => log.date == twoDaysAgo), isFalse);
    });

    test('should filter by both activity type and date range', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Running',
          duration: 25,
          calories: 125.0,
          date: yesterday,
        ),
        ActivityLogModel(
          id: '3',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: today,
        ),
      ];

      final filteredLogs = DashboardFilterService.applyFilters(
        logs: logs,
        activityType: 'Running',
        startDate: yesterday,
        endDate: today,
      );

      expect(filteredLogs.length, equals(2));
      expect(filteredLogs.every((log) => log.activityType == 'Running'), isTrue);
      expect(filteredLogs.any((log) => log.date == today), isTrue);
      expect(filteredLogs.any((log) => log.date == yesterday), isTrue);
    });

    test('should return all logs when no filters applied', () {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: DateTime.now(),
        ),
      ];

      final filteredLogs = DashboardFilterService.applyFilters(logs: logs);

      expect(filteredLogs.length, equals(2));
      expect(filteredLogs, equals(logs));
    });

    test('should handle empty logs list', () {
      final logs = <ActivityLogModel>[];

      final filteredLogs = DashboardFilterService.applyFilters(
        logs: logs,
        activityType: 'Running',
      );

      expect(filteredLogs, isEmpty);
    });

    test('should handle invalid activity type', () {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: DateTime.now(),
        ),
      ];

      final filteredLogs = DashboardFilterService.applyFilters(
        logs: logs,
        activityType: 'InvalidType',
      );

      expect(filteredLogs, isEmpty);
    });

    test('should handle start date only', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: yesterday,
        ),
      ];

      final filteredLogs = DashboardFilterService.applyFilters(
        logs: logs,
        startDate: today,
      );

      expect(filteredLogs.length, equals(1));
      expect(filteredLogs.first.date, equals(today));
    });

    test('should handle end date only', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: yesterday,
        ),
      ];

      final filteredLogs = DashboardFilterService.applyFilters(
        logs: logs,
        endDate: yesterday,
      );

      expect(filteredLogs.length, equals(1));
      expect(filteredLogs.first.date, equals(yesterday));
    });

    test('should handle invalid date range (start after end)', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
      ];

      final filteredLogs = DashboardFilterService.applyFilters(
        logs: logs,
        startDate: today,
        endDate: yesterday,
      );

      expect(filteredLogs, isEmpty);
    });

    test('should get today logs correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: yesterday,
        ),
      ];

      final todayLogs = DashboardFilterService.getTodayLogs(logs);

      expect(todayLogs.length, equals(1));
      expect(todayLogs.first.date, equals(today));
    });

    test('should get logs for specific date correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: yesterday,
        ),
      ];

      final yesterdayLogs = DashboardFilterService.getLogsForDay(logs, yesterday);

      expect(yesterdayLogs.length, equals(1));
      expect(yesterdayLogs.first.date, equals(yesterday));
    });

    test('should get logs for date range correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: yesterday,
        ),
        ActivityLogModel(
          id: '3',
          activityType: 'Walking',
          duration: 20,
          calories: 80.0,
          date: twoDaysAgo,
        ),
      ];

      final rangeLogs = DashboardFilterService.filterByDateRange(
        logs,
        twoDaysAgo,
        yesterday,
      );

      expect(rangeLogs.length, equals(2));
      expect(rangeLogs.any((log) => log.date == yesterday), isTrue);
      expect(rangeLogs.any((log) => log.date == twoDaysAgo), isTrue);
      expect(rangeLogs.any((log) => log.date == today), isFalse);
    });
  });
} 
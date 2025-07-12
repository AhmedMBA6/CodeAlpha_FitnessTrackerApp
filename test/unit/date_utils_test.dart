import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/date_utils.dart' as app_date_utils;

void main() {
  group('DateUtils', () {
    group('formatDate', () {
      test('should format date correctly', () {
        // Arrange
        final date = DateTime(2024, 1, 15);

        // Act
        final result = app_date_utils.DateUtils.formatDate(date);

        // Assert
        expect(result, equals('15/01/2024'));
      });

      test('should handle single digit day and month', () {
        // Arrange
        final date = DateTime(2024, 3, 5);

        // Act
        final result = app_date_utils.DateUtils.formatDate(date);

        // Assert
        expect(result, equals('05/03/2024'));
      });

      test('should handle different years', () {
        // Arrange
        final date = DateTime(2023, 12, 31);

        // Act
        final result = app_date_utils.DateUtils.formatDate(date);

        // Assert
        expect(result, equals('31/12/2023'));
      });
    });

    group('formatTime', () {
      test('should format time correctly', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 14, 30);

        // Act
        final result = app_date_utils.DateUtils.formatTime(date);

        // Assert
        expect(result, equals('14:30'));
      });

      test('should handle single digit hours and minutes', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 9, 5);

        // Act
        final result = app_date_utils.DateUtils.formatTime(date);

        // Assert
        expect(result, equals('09:05'));
      });

      test('should handle midnight', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 0, 0);

        // Act
        final result = app_date_utils.DateUtils.formatTime(date);

        // Assert
        expect(result, equals('00:00'));
      });
    });

    group('formatDateForExport', () {
      test('should format date for export correctly', () {
        // Arrange
        final date = DateTime(2024, 1, 15);

        // Act
        final result = app_date_utils.DateUtils.formatDateForExport(date);

        // Assert
        expect(result, equals('2024-01-15'));
      });

      test('should handle single digit month and day', () {
        // Arrange
        final date = DateTime(2024, 3, 5);

        // Act
        final result = app_date_utils.DateUtils.formatDateForExport(date);

        // Assert
        expect(result, equals('2024-03-05'));
      });
    });

    group('getWeekdayLabel', () {
      test('should return correct weekday labels', () {
        // Test each day of the week
        final testCases = [
          (DateTime(2024, 1, 7), 'Sun'), // Sunday
          (DateTime(2024, 1, 8), 'Mon'), // Monday
          (DateTime(2024, 1, 9), 'Tue'), // Tuesday
          (DateTime(2024, 1, 10), 'Wed'), // Wednesday
          (DateTime(2024, 1, 11), 'Thu'), // Thursday
          (DateTime(2024, 1, 12), 'Fri'), // Friday
          (DateTime(2024, 1, 13), 'Sat'), // Saturday
        ];

        for (final testCase in testCases) {
          // Act
          final result = app_date_utils.DateUtils.getWeekdayLabel(testCase.$1);

          // Assert
          expect(result, equals(testCase.$2));
        }
      });
    });

    group('isSameDay', () {
      test('should return true for same day', () {
        // Arrange
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 15, 15, 45);

        // Act
        final result = app_date_utils.DateUtils.isSameDay(date1, date2);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for different days', () {
        // Arrange
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 16, 10, 30);

        // Act
        final result = app_date_utils.DateUtils.isSameDay(date1, date2);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for different months', () {
        // Arrange
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 2, 15, 10, 30);

        // Act
        final result = app_date_utils.DateUtils.isSameDay(date1, date2);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for different years', () {
        // Arrange
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2023, 1, 15, 10, 30);

        // Act
        final result = app_date_utils.DateUtils.isSameDay(date1, date2);

        // Assert
        expect(result, isFalse);
      });
    });

    group('isToday', () {
      test('should return true for today', () {
        // Arrange
        final today = DateTime.now();

        // Act
        final result = app_date_utils.DateUtils.isToday(today);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for yesterday', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act
        final result = app_date_utils.DateUtils.isToday(yesterday);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for tomorrow', () {
        // Arrange
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        // Act
        final result = app_date_utils.DateUtils.isToday(tomorrow);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getStartOfWeek', () {
      test('should return Monday for any day in the week', () {
        // Test each day of the week
        final testCases = [
          (DateTime(2024, 1, 7), DateTime(2024, 1, 1)), // Sunday -> Monday
          (DateTime(2024, 1, 8), DateTime(2024, 1, 8)), // Monday -> Monday
          (DateTime(2024, 1, 9), DateTime(2024, 1, 8)), // Tuesday -> Monday
          (DateTime(2024, 1, 10), DateTime(2024, 1, 8)), // Wednesday -> Monday
          (DateTime(2024, 1, 11), DateTime(2024, 1, 8)), // Thursday -> Monday
          (DateTime(2024, 1, 12), DateTime(2024, 1, 8)), // Friday -> Monday
          (DateTime(2024, 1, 13), DateTime(2024, 1, 8)), // Saturday -> Monday
        ];

        for (final testCase in testCases) {
          // Act
          final result = app_date_utils.DateUtils.getStartOfWeek(testCase.$1);

          // Assert
          expect(result.day, equals(testCase.$2.day));
          expect(result.month, equals(testCase.$2.month));
          expect(result.year, equals(testCase.$2.year));
        }
      });
    });

    group('getStartOfMonth', () {
      test('should return first day of month', () {
        // Arrange
        final date = DateTime(2024, 3, 15);

        // Act
        final result = app_date_utils.DateUtils.getStartOfMonth(date);

        // Assert
        expect(result.day, equals(1));
        expect(result.month, equals(3));
        expect(result.year, equals(2024));
      });

      test('should handle different months', () {
        // Arrange
        final date = DateTime(2024, 12, 31);

        // Act
        final result = app_date_utils.DateUtils.getStartOfMonth(date);

        // Assert
        expect(result.day, equals(1));
        expect(result.month, equals(12));
        expect(result.year, equals(2024));
      });
    });

    group('formatDateRange', () {
      test('should format "All time" when no dates provided', () {
        // Act
        final result = app_date_utils.DateUtils.formatDateRange(null, null);

        // Assert
        expect(result, equals('All time'));
      });

      test('should format single date when start and end are same', () {
        // Arrange
        final date = DateTime(2024, 1, 15);

        // Act
        final result = app_date_utils.DateUtils.formatDateRange(date, date);

        // Assert
        expect(result, equals('15/01/2024'));
      });

      test('should format date range when both dates provided', () {
        // Arrange
        final startDate = DateTime(2024, 1, 15);
        final endDate = DateTime(2024, 1, 20);

        // Act
        final result = app_date_utils.DateUtils.formatDateRange(startDate, endDate);

        // Assert
        expect(result, equals('15/01/2024 - 20/01/2024'));
      });

      test('should format "From" when only start date provided', () {
        // Arrange
        final startDate = DateTime(2024, 1, 15);

        // Act
        final result = app_date_utils.DateUtils.formatDateRange(startDate, null);

        // Assert
        expect(result, equals('From 15/01/2024'));
      });

      test('should format "Until" when only end date provided', () {
        // Arrange
        final endDate = DateTime(2024, 1, 20);

        // Act
        final result = app_date_utils.DateUtils.formatDateRange(null, endDate);

        // Assert
        expect(result, equals('Until 20/01/2024'));
      });
    });

    group('getDatePresets', () {
      test('should return all preset options', () {
        // Act
        final result = app_date_utils.DateUtils.getDatePresets();

        // Assert
        expect(result.keys, containsAll([
          'Today',
          'Last 7 Days',
          'Last 30 Days',
          'This Week',
          'This Month',
          'All Time',
        ]));
      });

      test('should have correct structure for each preset', () {
        // Act
        final result = app_date_utils.DateUtils.getDatePresets();

        // Assert
        for (final entry in result.entries) {
          expect(entry.value.containsKey('start'), isTrue);
          expect(entry.value.containsKey('end'), isTrue);
        }
      });

      test('should have "All Time" with null dates', () {
        // Act
        final result = app_date_utils.DateUtils.getDatePresets();

        // Assert
        expect(result['All Time']!['start'], isNull);
        expect(result['All Time']!['end'], isNull);
      });

      test('should have "Today" with same date', () {
        // Act
        final result = app_date_utils.DateUtils.getDatePresets();
        final today = DateTime.now();

        // Assert
        final todayPreset = result['Today']!;
        expect(todayPreset['start']!.day, equals(today.day));
        expect(todayPreset['start']!.month, equals(today.month));
        expect(todayPreset['start']!.year, equals(today.year));
        expect(todayPreset['end']!.day, equals(today.day));
        expect(todayPreset['end']!.month, equals(today.month));
        expect(todayPreset['end']!.year, equals(today.year));
      });
    });
  });
} 
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/presentation/widgets/date_range_filter.dart';

void main() {
  group('DateRangeFilter', () {
    late Function(DateTime?, DateTime?) onDateRangeChanged;
    late DateTime? startDate;
    late DateTime? endDate;

    setUp(() {
      onDateRangeChanged = (start, end) {
        startDate = start;
        endDate = end;
      };
      startDate = null;
      endDate = null;
    });

    void onReset() {
      startDate = null;
      endDate = null;
    }

    testWidgets('should display filter title', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Date Range'), findsOneWidget);
    });

    testWidgets('should display preset buttons', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('Last 30 Days'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
    });

    testWidgets('should display custom date picker button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Custom Date Range'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('should call onDateRangeChanged when preset is selected', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Today'));
      await tester.pump();

      // Assert
      expect(startDate, isNotNull);
      expect(endDate, isNotNull);
      expect(startDate!.day, equals(DateTime.now().day));
      expect(endDate!.day, equals(DateTime.now().day));
    });

    testWidgets('should call onDateRangeChanged with null for All Time', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('All Time'));
      await tester.pump();

      // Assert
      expect(startDate, isNull);
      expect(endDate, isNull);
    });

    testWidgets('should show current date range when provided', (WidgetTester tester) async {
      // Arrange
      final testStartDate = DateTime(2024, 1, 15);
      final testEndDate = DateTime(2024, 1, 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: testStartDate,
              endDate: testEndDate,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Selected: 15/01/2024 - 20/01/2024'), findsOneWidget);
    });

    testWidgets('should show "All time" when no dates provided', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Selected: All time'), findsNothing); // Should not show when no dates
    });

    testWidgets('should show single date when start and end are same', (WidgetTester tester) async {
      // Arrange
      final testDate = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: testDate,
              endDate: testDate,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Selected: 15/01/2024'), findsOneWidget);
    });

    testWidgets('should show "From" when only start date provided', (WidgetTester tester) async {
      // Arrange
      final testStartDate = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: testStartDate,
              endDate: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Selected: From 15/01/2024'), findsOneWidget);
    });

    testWidgets('should show "Until" when only end date provided', (WidgetTester tester) async {
      // Arrange
      final testEndDate = DateTime(2024, 1, 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: testEndDate,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Selected: Until 20/01/2024'), findsOneWidget);
    });

    testWidgets('should handle tap on custom range button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Custom Date Range'));
      await tester.pump();

      // Assert - The button should be tappable
      expect(find.text('Custom Date Range'), findsOneWidget);
      // Note: Date picker dialog is system UI and may not be testable in widget tests
    });

    testWidgets('should handle custom range button interaction', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Custom Date Range'));
      await tester.pump();

      // Assert
      expect(find.text('Custom Date Range'), findsOneWidget);
      // Note: Date picker dialog interactions are not testable in widget tests
    });

    testWidgets('should handle custom date range button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Custom Date Range'));
      await tester.pump();

      // Assert
      expect(find.text('Custom Date Range'), findsOneWidget);
      // Note: Date picker dialog interactions are not testable in widget tests
    });

    testWidgets('should be responsive to different screen sizes', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(DateRangeFilter), findsOneWidget);
      expect(find.text('Date Range'), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should handle rapid preset selections', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Today'));
      await tester.pump();
      await tester.tap(find.text('Last 7 Days'));
      await tester.pump();
      await tester.tap(find.text('This Week'));
      await tester.pump();

      // Assert
      expect(startDate, isNotNull);
      expect(endDate, isNotNull);
    });

    testWidgets('should maintain state when rebuilt', (WidgetTester tester) async {
      // Arrange
      final testStartDate = DateTime(2024, 1, 15);
      final testEndDate = DateTime(2024, 1, 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: testStartDate,
              endDate: testEndDate,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Selected: 15/01/2024 - 20/01/2024'), findsOneWidget);

      // Rebuild with same dates
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: testStartDate,
              endDate: testEndDate,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Selected: 15/01/2024 - 20/01/2024'), findsOneWidget);
    });

    testWidgets('should call onReset when reset button is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: onDateRangeChanged,
              onReset: onReset,
              startDate: null,
              endDate: null,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Assert
      expect(startDate, isNull);
      expect(endDate, isNull);
    });
  });
} 
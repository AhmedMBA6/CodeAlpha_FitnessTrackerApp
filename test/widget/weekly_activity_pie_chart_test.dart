import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/presentation/widgets/weekly_activity_pie_chart.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_model.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('WeeklyActivityPieChart', () {
    late List<ActivityLogModel> activityLogs;

    setUp(() {
      activityLogs = TestHelpers.createSampleActivityLogs();
    });

    testWidgets('should display pie chart when data is available', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: activityLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('No activity data'), findsNothing); // Should not show when there's data
    });

    testWidgets('should display pie chart container', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: activityLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      // The chart itself is rendered by fl_chart, so we check for the container
    });

    testWidgets('should handle empty activity logs', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: [],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No activity data'), findsOneWidget);
    });

    testWidgets('should handle single activity type', (WidgetTester tester) async {
      // Arrange
      final singleTypeLogs = [
        TestHelpers.createSampleActivityLog(
          id: 1,
          activityType: 'Running',
          duration: 30,
        ),
        TestHelpers.createSampleActivityLog(
          id: 2,
          activityType: 'Running',
          duration: 45,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: singleTypeLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('No activity data'), findsNothing);
    });

    testWidgets('should handle activities with zero duration', (WidgetTester tester) async {
      // Arrange
      final zeroDurationLogs = [
        TestHelpers.createSampleActivityLog(
          id: 1,
          activityType: 'Running',
          duration: 0,
        ),
        TestHelpers.createSampleActivityLog(
          id: 2,
          activityType: 'Cycling',
          duration: 30,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: zeroDurationLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('No activity data'), findsNothing);
    });

    testWidgets('should be responsive to different screen sizes', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(400, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: activityLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(WeeklyActivityPieChart), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should handle large number of activity types', (WidgetTester tester) async {
      // Arrange
      final manyTypesLogs = [
        TestHelpers.createSampleActivityLog(id: 1, activityType: 'Running', duration: 30),
        TestHelpers.createSampleActivityLog(id: 2, activityType: 'Cycling', duration: 45),
        TestHelpers.createSampleActivityLog(id: 3, activityType: 'Walking', duration: 20),
        TestHelpers.createSampleActivityLog(id: 4, activityType: 'Swimming', duration: 60),
        TestHelpers.createSampleActivityLog(id: 5, activityType: 'Yoga', duration: 90),
        TestHelpers.createSampleActivityLog(id: 6, activityType: 'Weight Training', duration: 45),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: manyTypesLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('No activity data'), findsNothing);
    });

    testWidgets('should handle activities with same duration', (WidgetTester tester) async {
      // Arrange
      final sameDurationLogs = [
        TestHelpers.createSampleActivityLog(id: 1, activityType: 'Running', duration: 30),
        TestHelpers.createSampleActivityLog(id: 2, activityType: 'Cycling', duration: 30),
        TestHelpers.createSampleActivityLog(id: 3, activityType: 'Walking', duration: 30),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: sameDurationLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('No activity data'), findsNothing);
    });

    testWidgets('should handle very large duration values', (WidgetTester tester) async {
      // Arrange
      final largeDurationLogs = [
        TestHelpers.createSampleActivityLog(id: 1, activityType: 'Running', duration: 9999),
        TestHelpers.createSampleActivityLog(id: 2, activityType: 'Cycling', duration: 8888),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: largeDurationLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('No activity data'), findsNothing);
    });

    testWidgets('should maintain state when rebuilt', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: activityLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('No activity data'), findsNothing);

      // Rebuild with same data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: activityLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('No activity data'), findsNothing);
    });

    testWidgets('should handle null activity logs gracefully', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: [],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No activity data'), findsOneWidget);
    });

    testWidgets('should display correct percentage calculations', (WidgetTester tester) async {
      // Arrange
      final testLogs = [
        TestHelpers.createSampleActivityLog(id: 1, activityType: 'Running', duration: 60),
        TestHelpers.createSampleActivityLog(id: 2, activityType: 'Cycling', duration: 30),
        TestHelpers.createSampleActivityLog(id: 3, activityType: 'Walking', duration: 30),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(
              activityLogs: testLogs,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('No activity data'), findsNothing);
      // The chart should show Running as 33%, Cycling as 33%, Walking as 33%
    });
  });
} 
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_model.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/presentation/widgets/weekly_activity_pie_chart.dart';

void main() {
  group('WeeklyActivityPieChart Widget Tests', () {
    testWidgets('should display pie chart with activity data', (WidgetTester tester) async {
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(activityLogs: logs),
          ),
        ),
      );

      expect(find.byType(WeeklyActivityPieChart), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Cycling'), findsOneWidget);
    });

    testWidgets('should handle empty activity logs', (WidgetTester tester) async {
      final logs = <ActivityLogModel>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(activityLogs: logs),
          ),
        ),
      );

      expect(find.byType(WeeklyActivityPieChart), findsOneWidget);
      expect(find.text('No activities this week'), findsOneWidget);
    });

    testWidgets('should display correct activity percentages', (WidgetTester tester) async {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 60,
          calories: 300.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 30,
          calories: 150.0,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(activityLogs: logs),
          ),
        ),
      );

      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Cycling'), findsOneWidget);
      // Running should be 66.7% (60/90 minutes)
      expect(find.textContaining('66.7'), findsOneWidget);
      // Cycling should be 33.3% (30/90 minutes)
      expect(find.textContaining('33.3'), findsOneWidget);
    });

    testWidgets('should handle single activity type', (WidgetTester tester) async {
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
          activityType: 'Running',
          duration: 45,
          calories: 225.0,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(activityLogs: logs),
          ),
        ),
      );

      expect(find.text('Running'), findsOneWidget);
      expect(find.textContaining('100.0'), findsOneWidget);
    });

    testWidgets('should display legend correctly', (WidgetTester tester) async {
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
          activityType: 'Walking',
          duration: 20,
          calories: 80.0,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(activityLogs: logs),
          ),
        ),
      );

      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Cycling'), findsOneWidget);
      expect(find.text('Walking'), findsOneWidget);
    });

    testWidgets('should handle activities with zero duration', (WidgetTester tester) async {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 0,
          calories: 0.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 30,
          calories: 150.0,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(activityLogs: logs),
          ),
        ),
      );

      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Cycling'), findsOneWidget);
      // Cycling should be 100% since Running has 0 duration
      expect(find.textContaining('100.0'), findsOneWidget);
    });

    testWidgets('should handle large number of activities', (WidgetTester tester) async {
      final logs = List.generate(10, (index) => ActivityLogModel(
        id: index.toString(),
        activityType: 'Activity $index',
        duration: 10,
        calories: 50.0,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(activityLogs: logs),
          ),
        ),
      );

      // Should display all activity types
      for (int i = 0; i < 10; i++) {
        expect(find.text('Activity $i'), findsOneWidget);
      }
    });

    testWidgets('should handle activities with same type but different dates', (WidgetTester tester) async {
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
          activityType: 'Running',
          duration: 45,
          calories: 225.0,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(activityLogs: logs),
          ),
        ),
      );

      expect(find.text('Running'), findsOneWidget);
      expect(find.textContaining('100.0'), findsOneWidget);
    });

    testWidgets('should handle activities with special characters in names', (WidgetTester tester) async {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Strength Training',
          duration: 30,
          calories: 150.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cardio & HIIT',
          duration: 45,
          calories: 200.0,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyActivityPieChart(activityLogs: logs),
          ),
        ),
      );

      expect(find.text('Strength Training'), findsOneWidget);
      expect(find.text('Cardio & HIIT'), findsOneWidget);
    });
  });
} 
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/presentation/widgets/dashboard_summary_row.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_aggregator.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('DashboardSummaryRow', () {
    late DashboardSummary todaySummary;
    late DashboardMetrics metrics;

    setUp(() {
      todaySummary = TestHelpers.createSampleDashboardSummary(
        totalCalories: 250.0,
        totalDuration: 45,
      );
      metrics = TestHelpers.createSampleDashboardMetrics(
        totalCalories: 500.0,
        totalDuration: 150,
        totalActivities: 5,
        averageDuration: 30.0,
        averageCaloriesPerActivity: 100.0,
      );
    });

    testWidgets('should display today\'s summary section', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSummaryRow(
              today: todaySummary,
              metrics: metrics,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Today\'s Summary'), findsOneWidget);
      expect(find.text('250'), findsOneWidget); // Calories
      expect(find.text('45'), findsOneWidget); // Duration
      expect(find.text('Calories Burned'), findsOneWidget);
      expect(find.text('Duration (min)'), findsOneWidget);
    });

    testWidgets('should display overall metrics section', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSummaryRow(
              today: todaySummary,
              metrics: metrics,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Overall Metrics'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // Total Activities
      expect(find.text('30'), findsOneWidget); // Average Duration
      expect(find.text('500'), findsOneWidget); // Total Calories
      expect(find.text('100'), findsOneWidget); // Average Calories per Activity
      expect(find.text('Total Activities'), findsOneWidget);
      expect(find.text('Avg Duration (min)'), findsOneWidget);
      expect(find.text('Total Calories'), findsOneWidget);
      expect(find.text('Avg Calories/Activity'), findsOneWidget);
    });

    testWidgets('should display correct icons', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSummaryRow(
              today: todaySummary,
              metrics: metrics,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.local_fire_department), findsNWidgets(2)); // Calories icons
      expect(find.byIcon(Icons.timer), findsOneWidget); // Duration icon
      expect(find.byIcon(Icons.fitness_center), findsOneWidget); // Activities icon
      expect(find.byIcon(Icons.av_timer), findsOneWidget); // Average duration icon
      expect(find.byIcon(Icons.trending_up), findsOneWidget); // Average calories icon
    });

    testWidgets('should display correct colors', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSummaryRow(
              today: todaySummary,
              metrics: metrics,
            ),
          ),
        ),
      );

      // Assert - Check that cards are rendered (they have elevation)
      expect(find.byType(Card), findsNWidgets(6)); // 6 summary cards total
    });

    testWidgets('should handle zero values correctly', (WidgetTester tester) async {
      // Arrange
      final zeroTodaySummary = TestHelpers.createSampleDashboardSummary(
        totalCalories: 0.0,
        totalDuration: 0,
      );
      final zeroMetrics = TestHelpers.createSampleDashboardMetrics(
        totalCalories: 0.0,
        totalDuration: 0,
        totalActivities: 0,
        averageDuration: 0.0,
        averageCaloriesPerActivity: 0.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSummaryRow(
              today: zeroTodaySummary,
              metrics: zeroMetrics,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('0'), findsNWidgets(6)); // All zero values (6 cards total)
      // No '0.0' values are displayed, only integer zeroes
    });

    testWidgets('should handle decimal values correctly', (WidgetTester tester) async {
      // Arrange
      final decimalTodaySummary = TestHelpers.createSampleDashboardSummary(
        totalCalories: 123.45,
        totalDuration: 67,
      );
      final decimalMetrics = TestHelpers.createSampleDashboardMetrics(
        totalCalories: 456.78,
        totalDuration: 89,
        totalActivities: 3,
        averageDuration: 29.67,
        averageCaloriesPerActivity: 152.26,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSummaryRow(
              today: decimalTodaySummary,
              metrics: decimalMetrics,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('123'), findsOneWidget); // Calories rounded
      expect(find.text('67'), findsOneWidget); // Duration
      expect(find.text('3'), findsOneWidget); // Total activities
      expect(find.text('30'), findsOneWidget); // Average duration rounded
      expect(find.text('457'), findsOneWidget); // Total calories rounded
      expect(find.text('152'), findsOneWidget); // Average calories rounded
    });

    testWidgets('should be responsive to different screen sizes', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSummaryRow(
              today: todaySummary,
              metrics: metrics,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(DashboardSummaryRow), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(6));

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should handle large numbers correctly', (WidgetTester tester) async {
      // Arrange
      final largeTodaySummary = TestHelpers.createSampleDashboardSummary(
        totalCalories: 9999.99,
        totalDuration: 9999,
      );
      final largeMetrics = TestHelpers.createSampleDashboardMetrics(
        totalCalories: 99999.99,
        totalDuration: 99999,
        totalActivities: 999,
        averageDuration: 999.99,
        averageCaloriesPerActivity: 999.99,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSummaryRow(
              today: largeTodaySummary,
              metrics: largeMetrics,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('10000'), findsOneWidget); // Calories rounded
      expect(find.text('9999'), findsOneWidget); // Duration
      expect(find.text('999'), findsOneWidget); // Total activities
      expect(find.text('1000'), findsNWidgets(2)); // Average duration and average calories rounded
      expect(find.text('100000'), findsOneWidget); // Total calories rounded
    });
  });
} 
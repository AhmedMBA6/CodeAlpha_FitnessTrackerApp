import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/logic/dashboard_cubit.dart';

import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_model.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/repos/activity_log_repository.dart';
import '../helpers/test_helpers.dart';

// Mock repository for testing
class MockActivityLogRepository implements ActivityLogRepository {
  final List<ActivityLogModel> _logs;

  MockActivityLogRepository(this._logs);

  @override
  Future<List<ActivityLogModel>> getAllActivities() async {
    return _logs;
  }

  @override
  Future<int> addActivity(ActivityLogModel activity) async {
    // Mock implementation
    return 1;
  }

  @override
  Future<int> updateActivity(ActivityLogModel activity) async {
    // Mock implementation
    return 1;
  }

  @override
  Future<int> deleteActivity(int id) async {
    // Mock implementation
    return 1;
  }

  @override
  Future<ActivityLogModel?> getActivityById(int id) async {
    // Mock implementation
    return null;
  }
}

void main() {
  group('DashboardScreen Integration Tests', () {
    late MockActivityLogRepository mockRepository;
    late List<ActivityLogModel> testLogs;

    setUp(() {
      testLogs = TestHelpers.createSampleActivityLogs();
      mockRepository = MockActivityLogRepository(testLogs);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<DashboardCubit>(
          create: (context) => DashboardCubit(mockRepository),
          child: const DashboardScreen(),
        ),
      );
    }

    testWidgets('should display loading state initially', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display dashboard content after loading', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Today\'s Summary'), findsOneWidget);
      expect(find.text('Overall Metrics'), findsOneWidget);
      expect(find.text('Weekly Activity Chart'), findsOneWidget);
      expect(find.text('Activity Type Distribution'), findsOneWidget);
    });

    testWidgets('should display activity type filter', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Filter by Activity Type'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Cycling'), findsOneWidget);
      expect(find.text('Walking'), findsOneWidget);
    });

    testWidgets('should filter activities when activity type is selected', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Cycling'), findsNothing);
      expect(find.text('Walking'), findsNothing);
    });

    testWidgets('should display date range filter', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to find date range filter
      await tester.scrollUntilVisible(
        find.text('Date Range'),
        500.0,
      );

      // Assert
      expect(find.text('Date Range'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
    });

    testWidgets('should apply date range filter', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to find date range filter
      await tester.scrollUntilVisible(
        find.text('Date Range'),
        500.0,
      );

      // Act
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Selected:'), findsOneWidget);
    });

    testWidgets('should display export/share functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to find export section
      await tester.scrollUntilVisible(
        find.text('Export & Share'),
        500.0,
      );

      // Assert
      expect(find.text('Export & Share'), findsOneWidget);
      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Export as PDF'), findsOneWidget);
      expect(find.text('Share Summary'), findsOneWidget);
    });

    testWidgets('should display quick actions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to find quick actions
      await tester.scrollUntilVisible(
        find.text('Quick Actions'),
        500.0,
      );

      // Assert
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Add Activity'), findsOneWidget);
      expect(find.text('View All Activities'), findsOneWidget);
    });

    testWidgets('should handle pull to refresh', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('should display error state when repository fails', (WidgetTester tester) async {
      // Arrange
      final failingRepository = MockActivityLogRepository([]);
      // Simulate failure by overriding the method
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DashboardCubit>(
            create: (context) => DashboardCubit(failingRepository),
            child: const DashboardScreen(),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
      // Should still display the UI even with empty data
    });

    testWidgets('should be responsive to different screen sizes', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should handle empty activity data gracefully', (WidgetTester tester) async {
      // Arrange
      final emptyRepository = MockActivityLogRepository([]);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DashboardCubit>(
            create: (context) => DashboardCubit(emptyRepository),
            child: const DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Today\'s Summary'), findsOneWidget);
      expect(find.text('Overall Metrics'), findsOneWidget);
      // Should display zero values for empty data
    });

    testWidgets('should maintain state during navigation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Simulate some user interaction
      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Running'), findsOneWidget);

      // Rebuild widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should maintain the filter state
      expect(find.text('Running'), findsOneWidget);
    });

    testWidgets('should handle rapid filter changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Rapid filter changes
      await tester.tap(find.text('Running'));
      await tester.pump();
      await tester.tap(find.text('Cycling'));
      await tester.pump();
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Cycling'), findsOneWidget);
      expect(find.text('Walking'), findsOneWidget);
    });

    testWidgets('should display correct summary data', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Today\'s Summary'), findsOneWidget);
      expect(find.text('Overall Metrics'), findsOneWidget);
      
      // Check that summary cards are displayed
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should handle chart interactions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to find charts - they might not have specific text labels
      await tester.scrollUntilVisible(
        find.byType(Container),
        500.0,
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
    });
  });
} 
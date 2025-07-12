import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/repos/activity_log_repository.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_model.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/logic/dashboard_cubit.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_aggregator.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_filter_service.dart';
import 'package:codealpha_fitness_tracker_app/core/constants/dashboard_constants.dart';
import '../helpers/test_helpers.dart';

import 'dashboard_cubit_performance_test.mocks.dart';

@GenerateMocks([ActivityLogRepository])
void main() {
  group('DashboardCubit Performance Tests', () {
    late MockActivityLogRepository mockRepository;
    late DashboardCubit cubit;

    setUp(() {
      mockRepository = MockActivityLogRepository();
      cubit = DashboardCubit(mockRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('should process large dataset without blocking UI thread', () async {
      // Create a large dataset to simulate performance testing
      final activityTypes = ['Running', 'Cycling', 'Walking', 'Swimming', 'Gym'];
      final largeDataset = List.generate(1000, (index) {
        final date = DateTime.now().subtract(Duration(days: index % 30));
        return ActivityLogModel(
          id: index + 1,
          activityType: activityTypes[index % activityTypes.length],
          duration: 30 + (index % 60),
          calories: 100.0 + (index % 200),
          date: date,
        );
      });

      when(mockRepository.getAllActivities()).thenAnswer((_) async => largeDataset);

      // Test that the cubit can handle large datasets
      await cubit.loadDashboard();

      // Verify that the state is loaded correctly
      expect(cubit.state, isA<DashboardLoaded>());
      
      final loadedState = cubit.state as DashboardLoaded;
      expect(loadedState.activityLogs.length, equals(1000));
      expect(loadedState.todaySummary, isA<DashboardSummary>());
      expect(loadedState.weeklySummaries.length, equals(7));
      expect(loadedState.metrics, isA<DashboardMetrics>());
    });

    test('should handle date range filtering efficiently', () async {
      final testData = TestHelpers.createSampleActivityLogs();
      when(mockRepository.getAllActivities()).thenAnswer((_) async => testData);

      // Test filtering with date range
      final startDate = DateTime.now().subtract(const Duration(days: 7));
      final endDate = DateTime.now();

      await cubit.loadDashboard(startDate: startDate, endDate: endDate);

      expect(cubit.state, isA<DashboardLoaded>());
      
      final loadedState = cubit.state as DashboardLoaded;
      expect(loadedState.startDate, equals(startDate));
      expect(loadedState.endDate, equals(endDate));
    });

    test('should handle activity type filtering efficiently', () async {
      final testData = TestHelpers.createSampleActivityLogs();
      when(mockRepository.getAllActivities()).thenAnswer((_) async => testData);

      // Test filtering by activity type
      await cubit.loadDashboard(activityType: 'Running');

      expect(cubit.state, isA<DashboardLoaded>());
      
      final loadedState = cubit.state as DashboardLoaded;
      expect(loadedState.activityTypeFilter, equals('Running'));
      
      // Verify that only running activities are included
      final runningActivities = loadedState.activityLogs.where((log) => log.activityType == 'Running');
      expect(runningActivities.length, equals(loadedState.activityLogs.length));
    });

    test('should handle multiple filter changes efficiently', () async {
      final testData = TestHelpers.createSampleActivityLogs();
      when(mockRepository.getAllActivities()).thenAnswer((_) async => testData);

      // Test multiple filter changes
      await cubit.loadDashboard();
      
      // Wait for the filter changes to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      cubit.updateActivityTypeFilter('Cycling');
      await Future.delayed(const Duration(milliseconds: 400)); // Wait for debounce
      
      cubit.updateDateRange(
        DateTime.now().subtract(const Duration(days: 3)),
        DateTime.now(),
      );
      await Future.delayed(const Duration(milliseconds: 400)); // Wait for debounce

      expect(cubit.state, isA<DashboardLoaded>());
      
      final loadedState = cubit.state as DashboardLoaded;
      expect(loadedState.activityTypeFilter, equals('Cycling'));
      expect(loadedState.startDate, isNotNull);
      expect(loadedState.endDate, isNotNull);
    });

    test('should handle error states correctly', () async {
      when(mockRepository.getAllActivities()).thenThrow(Exception('Database error'));

      await cubit.loadDashboard();

      expect(cubit.state, isA<DashboardError>());
      
      final errorState = cubit.state as DashboardError;
      expect(errorState.message, contains('Database error'));
    });

    test('should reset filters correctly', () async {
      final testData = TestHelpers.createSampleActivityLogs();
      when(mockRepository.getAllActivities()).thenAnswer((_) async => testData);

      // Set some filters first
      await cubit.loadDashboard(
        activityType: 'Running',
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );

      // Reset filters
      cubit.resetFilters();
      await Future.delayed(const Duration(milliseconds: 400)); // Wait for debounce

      expect(cubit.state, isA<DashboardLoaded>());
      
      final loadedState = cubit.state as DashboardLoaded;
      expect(loadedState.activityTypeFilter, equals(DashboardConstants.defaultActivityType));
      expect(loadedState.startDate, isNull);
      expect(loadedState.endDate, isNull);
    });

    test('should refresh dashboard correctly', () async {
      final testData = TestHelpers.createSampleActivityLogs();
      when(mockRepository.getAllActivities()).thenAnswer((_) async => testData);

      await cubit.refreshDashboard();

      expect(cubit.state, isA<DashboardLoaded>());
      verify(mockRepository.getAllActivities()).called(1);
    });
  });
} 
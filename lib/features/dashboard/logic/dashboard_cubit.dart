import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../activity_log/data/repos/activity_log_repository.dart';
import '../../activity_log/data/models/activity_log_model.dart';
import '../data/dashboard_aggregator.dart';
import '../data/dashboard_filter_service.dart';
import '../../../core/constants/dashboard_constants.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/di.dart';

part 'dashboard_state.dart';

/// Data class for passing dashboard filter and log data to the compute function.
class DashboardComputeData {
  /// The list of activity logs to process.
  final List<ActivityLogModel> logs;
  /// The activity type filter to apply.
  final String activityType;
  /// The start date for filtering (optional).
  final DateTime? startDate;
  /// The end date for filtering (optional).
  final DateTime? endDate;

  /// Creates a [DashboardComputeData].
  DashboardComputeData({
    required this.logs,
    required this.activityType,
    this.startDate,
    this.endDate,
  });
}

/// Data class for returning the result of dashboard computation from the isolate.
class DashboardComputeResult {
  /// The summary for today.
  final DashboardSummary todaySummary;
  /// The summaries for the last 7 days.
  final List<DashboardSummary> weeklySummaries;
  /// The aggregated metrics for the filtered logs.
  final DashboardMetrics metrics;
  /// The filtered activity logs.
  final List<ActivityLogModel> filteredLogs;

  /// Creates a [DashboardComputeResult].
  DashboardComputeResult({
    required this.todaySummary,
    required this.weeklySummaries,
    required this.metrics,
    required this.filteredLogs,
  });
}

/// Static function to be run in an isolate for dashboard data processing.
DashboardComputeResult _processDashboardData(DashboardComputeData data) {
  // Apply filters using the filter service
  final filteredLogs = DashboardFilterService.applyFilters(
    logs: data.logs,
    activityType: data.activityType,
    startDate: data.startDate,
    endDate: data.endDate,
  );
  
  // Generate dashboard data
  final todaySummary = DashboardAggregator.getTodaySummary(filteredLogs);
  final weeklySummaries = DashboardAggregator.getWeeklySummary(filteredLogs);
  final metrics = DashboardAggregator.getMetrics(filteredLogs);
  
  return DashboardComputeResult(
    todaySummary: todaySummary,
    weeklySummaries: weeklySummaries,
    metrics: metrics,
    filteredLogs: filteredLogs,
  );
}

/// Cubit for managing dashboard state, filters, and data aggregation.
class DashboardCubit extends Cubit<DashboardState> {
  final ActivityLogRepository _activityLogRepository = getIt<ActivityLogRepository>();
  String _activityTypeFilter = DashboardConstants.defaultActivityType;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Cache for activity logs to avoid repeated repository calls
  List<ActivityLogModel>? _cachedLogs;
  Timer? _debounceTimer;
  bool _isInitialized = false;
  
  // Data sync subscription
  StreamSubscription<DataSyncEvent>? _dataSyncSubscription;

  /// Creates a [DashboardCubit].
  DashboardCubit() : super(DashboardInitial()) {
    // Listen for data changes and refresh dashboard
    _setupDataSyncListener();
  }

  void _setupDataSyncListener() {
    try {
      final dataSyncService = getIt<DataSyncService>();
      _dataSyncSubscription = dataSyncService.events.listen((event) {
        print('[DASHBOARD] Received data sync event: ${event.type}');
        // Refresh dashboard when activity data changes
        if (event.type == 'activity_added' || 
            event.type == 'activity_updated' || 
            event.type == 'activity_deleted') {
          // Clear cache and reload
          _cachedLogs = null;
          _isInitialized = false;
          loadDashboard(forceRefresh: true);
        }
      });
    } catch (e) {
      print('[DASHBOARD] Error setting up data sync listener: $e');
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _dataSyncSubscription?.cancel();
    return super.close();
  }

  /// Loads dashboard data, applying filters and aggregating metrics.
  /// Uses background isolate for heavy computation.
  Future<void> loadDashboard({
    String? activityType,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    if (isClosed) return;
    // Cancel any pending debounced operations
    _debounceTimer?.cancel();
    
    // If not initialized or force refresh, load from repository
    if (!_isInitialized || forceRefresh || _cachedLogs == null) {
      emit(DashboardLoading());
      
      try {
        _cachedLogs = await _activityLogRepository.getAllActivities();
        _isInitialized = true;
      } catch (e) {
        if (!isClosed) {
          emit(DashboardError(_formatErrorMessage(e)));
        }
        return;
      }
    }

    final filter = activityType ?? _activityTypeFilter;
    final start = startDate ?? _startDate;
    final end = endDate ?? _endDate;
    
    // Use compute to run filtering and aggregation in background isolate
    final computeData = DashboardComputeData(
      logs: _cachedLogs!,
      activityType: filter,
      startDate: start,
      endDate: end,
    );
    
    try {
      final result = await compute(_processDashboardData, computeData);
      
      if (!isClosed) {
        emit(DashboardLoaded(
          todaySummary: result.todaySummary,
          weeklySummaries: result.weeklySummaries,
          activityTypeFilter: filter,
          activityLogs: result.filteredLogs,
          startDate: start,
          endDate: end,
          metrics: result.metrics,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(DashboardError(_formatErrorMessage(e)));
      }
    }
  }

  /// Updates the activity type filter and reloads the dashboard.
  void updateActivityTypeFilter(String activityType) {
    if (!DashboardConstants.activityTypes.contains(activityType)) {
      return; // Invalid activity type
    }
    _activityTypeFilter = activityType;
    _debouncedLoadDashboard(activityType: activityType);
  }

  /// Updates the date range filter and reloads the dashboard.
  void updateDateRange(DateTime? startDate, DateTime? endDate) {
    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return; // Invalid date range
    }
    
    _startDate = startDate;
    _endDate = endDate;
    _debouncedLoadDashboard(startDate: startDate, endDate: endDate);
  }

  /// Resets all filters to their default values and reloads the dashboard.
  void resetFilters() {
    _activityTypeFilter = DashboardConstants.defaultActivityType;
    _startDate = null;
    _endDate = null;
    _debouncedLoadDashboard();
  }

  /// Forces a refresh of the dashboard data from the repository.
  Future<void> refreshDashboard() async {
    await loadDashboard(forceRefresh: true);
  }

  /// Debounced method to prevent rapid filter changes from causing lag.
  void _debouncedLoadDashboard({
    String? activityType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      loadDashboard(
        activityType: activityType,
        startDate: startDate,
        endDate: endDate,
      );
    });
  }

  /// Formats error messages for display.
  String _formatErrorMessage(dynamic error) {
    if (error is Exception) {
      return 'An error occurred: ${error.toString()}';
    }
    return 'Unknown error occurred';
  }
} 
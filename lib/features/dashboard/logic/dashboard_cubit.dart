import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../activity_log/data/repos/activity_log_repository.dart';
import '../../activity_log/data/models/activity_log_model.dart';
import '../data/dashboard_aggregator.dart';
import '../data/dashboard_filter_service.dart';
import '../../../core/constants/dashboard_constants.dart';

part 'dashboard_state.dart';

// Data class for compute function
class DashboardComputeData {
  final List<ActivityLogModel> logs;
  final String activityType;
  final DateTime? startDate;
  final DateTime? endDate;

  DashboardComputeData({
    required this.logs,
    required this.activityType,
    this.startDate,
    this.endDate,
  });
}

// Result class for compute function
class DashboardComputeResult {
  final DashboardSummary todaySummary;
  final List<DashboardSummary> weeklySummaries;
  final DashboardMetrics metrics;
  final List<ActivityLogModel> filteredLogs;

  DashboardComputeResult({
    required this.todaySummary,
    required this.weeklySummaries,
    required this.metrics,
    required this.filteredLogs,
  });
}

// Static function to be run in isolate
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

class DashboardCubit extends Cubit<DashboardState> {
  final ActivityLogRepository _activityLogRepository;
  String _activityTypeFilter = DashboardConstants.defaultActivityType;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Cache for activity logs to avoid repeated repository calls
  List<ActivityLogModel>? _cachedLogs;
  Timer? _debounceTimer;
  bool _isInitialized = false;

  DashboardCubit(this._activityLogRepository) : super(DashboardInitial());

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  Future<void> loadDashboard({
    String? activityType,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    // Cancel any pending debounced operations
    _debounceTimer?.cancel();
    
    // If not initialized or force refresh, load from repository
    if (!_isInitialized || forceRefresh || _cachedLogs == null) {
      emit(DashboardLoading());
      
      try {
        _cachedLogs = await _activityLogRepository.getAllActivities();
        _isInitialized = true;
      } catch (e) {
        emit(DashboardError(_formatErrorMessage(e)));
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
      
      emit(DashboardLoaded(
        todaySummary: result.todaySummary,
        weeklySummaries: result.weeklySummaries,
        activityTypeFilter: filter,
        activityLogs: result.filteredLogs,
        startDate: start,
        endDate: end,
        metrics: result.metrics,
      ));
    } catch (e) {
      emit(DashboardError(_formatErrorMessage(e)));
    }
  }

  void updateActivityTypeFilter(String activityType) {
    if (!DashboardConstants.activityTypes.contains(activityType)) {
      return; // Invalid activity type
    }
    _activityTypeFilter = activityType;
    _debouncedLoadDashboard(activityType: activityType);
  }

  void updateDateRange(DateTime? startDate, DateTime? endDate) {
    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return; // Invalid date range
    }
    
    _startDate = startDate;
    _endDate = endDate;
    _debouncedLoadDashboard(startDate: startDate, endDate: endDate);
  }

  void resetFilters() {
    _activityTypeFilter = DashboardConstants.defaultActivityType;
    _startDate = null;
    _endDate = null;
    _debouncedLoadDashboard();
  }

  Future<void> refreshDashboard() async {
    await loadDashboard(forceRefresh: true);
  }

  // Debounced method to prevent rapid filter changes from causing lag
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

  String _formatErrorMessage(dynamic error) {
    if (error is Exception) {
      return 'An error occurred: ${error.toString()}';
    }
    return 'Unknown error occurred';
  }
} 
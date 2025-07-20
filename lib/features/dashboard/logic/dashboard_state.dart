part of 'dashboard_cubit.dart';

/// Base class for all dashboard states.
abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

/// State when the dashboard is first initialized.
class DashboardInitial extends DashboardState {}

/// State when the dashboard is loading data.
class DashboardLoading extends DashboardState {}

/// State when the dashboard has loaded data successfully.
class DashboardLoaded extends DashboardState {
  /// The summary for today.
  final DashboardSummary todaySummary;
  /// The summaries for the last 7 days.
  final List<DashboardSummary> weeklySummaries;
  /// The currently selected activity type filter.
  final String activityTypeFilter;
  /// The filtered activity logs.
  final List<ActivityLogModel> activityLogs;
  /// The start date for the current filter (optional).
  final DateTime? startDate;
  /// The end date for the current filter (optional).
  final DateTime? endDate;
  /// The aggregated metrics for the filtered logs.
  final DashboardMetrics metrics;
  
  /// Creates a [DashboardLoaded] state.
  const DashboardLoaded({
    required this.todaySummary,
    required this.weeklySummaries,
    required this.activityTypeFilter,
    required this.activityLogs,
    this.startDate,
    this.endDate,
    required this.metrics,
  });

  @override
  List<Object?> get props => [
    todaySummary,
    weeklySummaries,
    activityTypeFilter,
    activityLogs,
    startDate,
    endDate,
    metrics,
  ];
}

/// State when an error occurs while loading the dashboard.
class DashboardError extends DashboardState {
  /// The error message to display.
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
} 
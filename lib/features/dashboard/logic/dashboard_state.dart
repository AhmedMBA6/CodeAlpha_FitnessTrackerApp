part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary todaySummary;
  final List<DashboardSummary> weeklySummaries;
  final String activityTypeFilter;
  final List<ActivityLogModel> activityLogs;
  final DateTime? startDate;
  final DateTime? endDate;
  final DashboardMetrics metrics;
  
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

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
} 
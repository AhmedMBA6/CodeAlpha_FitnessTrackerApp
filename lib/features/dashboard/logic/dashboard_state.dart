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
  const DashboardLoaded({required this.todaySummary, required this.weeklySummaries});

  @override
  List<Object?> get props => [todaySummary, weeklySummaries];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
} 
part of 'activity_log_cubit.dart';

/// Base class for all activity log states.
abstract class ActivityLogState extends Equatable {
  const ActivityLogState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any activity log action.
class ActivityLogInitial extends ActivityLogState {}

/// State when activity log operations are in progress.
class ActivityLogLoading extends ActivityLogState {}

/// State when activity logs are successfully loaded.
class ActivityLogSuccess extends ActivityLogState {
  final List<ActivityLogModel> activities;
  const ActivityLogSuccess(this.activities);

  @override
  List<Object?> get props => [activities];
}

/// State when an activity log operation fails.
class ActivityLogError extends ActivityLogState {
  final String message;
  const ActivityLogError(this.message);

  @override
  List<Object?> get props => [message];
} 
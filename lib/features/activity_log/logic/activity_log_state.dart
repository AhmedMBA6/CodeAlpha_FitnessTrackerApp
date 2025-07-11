part of 'activity_log_cubit.dart';

abstract class ActivityLogState extends Equatable {
  const ActivityLogState();

  @override
  List<Object?> get props => [];
}

class ActivityLogInitial extends ActivityLogState {}

class ActivityLogLoading extends ActivityLogState {}

class ActivityLogSuccess extends ActivityLogState {
  final List<ActivityLogModel> activities;
  const ActivityLogSuccess(this.activities);

  @override
  List<Object?> get props => [activities];
}

class ActivityLogError extends ActivityLogState {
  final String message;
  const ActivityLogError(this.message);

  @override
  List<Object?> get props => [message];
} 
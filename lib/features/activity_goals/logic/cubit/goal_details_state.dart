part of 'goal_details_cubit.dart';

abstract class GoalDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GoalDetailsLoading extends GoalDetailsState {}

class GoalDetailsLoaded extends GoalDetailsState {
  final ActivityGoal goal;
  final List<ActivityLogModel> linkedActivities;

  GoalDetailsLoaded({required this.goal, required this.linkedActivities});

  @override
  List<Object?> get props => [goal, linkedActivities];
}

class GoalDetailsError extends GoalDetailsState {
  final String message;
  GoalDetailsError(this.message);

  @override
  List<Object?> get props => [message];
} 
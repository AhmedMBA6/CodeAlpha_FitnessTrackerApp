import '../../data/models/activity_goal.dart';

class GoalsState {
  final bool isLoading;
  final String? error;
  final List<ActivityGoal> goals;

  GoalsState({this.isLoading = false, this.error, this.goals = const []});

  GoalsState copyWith({bool? isLoading, String? error, List<ActivityGoal>? goals}) {
    return GoalsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      goals: goals ?? this.goals,
    );
  }
} 
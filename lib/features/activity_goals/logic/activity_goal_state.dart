import 'package:equatable/equatable.dart';
import '../data/models/activity_goal.dart';

enum ActivityGoalStatus {
  initial,
  loading,
  success,
  failure,
  creating,
  updating,
  deleting,
}

class ActivityGoalState extends Equatable {
  final ActivityGoalStatus status;
  final List<Map<String, dynamic>> routesWithGoals;
  final List<Map<String, dynamic>> completedGoals;
  final List<Map<String, dynamic>> pendingGoals;
  final Map<String, dynamic>? goalStatistics;
  final ActivityGoal? currentGoal;
  final String? errorMessage;

  const ActivityGoalState({
    required this.status,
    required this.routesWithGoals,
    required this.completedGoals,
    required this.pendingGoals,
    this.goalStatistics,
    this.currentGoal,
    this.errorMessage,
  });

  const ActivityGoalState.initial()
      : status = ActivityGoalStatus.initial,
        routesWithGoals = const [],
        completedGoals = const [],
        pendingGoals = const [],
        goalStatistics = null,
        currentGoal = null,
        errorMessage = null;

  ActivityGoalState copyWith({
    ActivityGoalStatus? status,
    List<Map<String, dynamic>>? routesWithGoals,
    List<Map<String, dynamic>>? completedGoals,
    List<Map<String, dynamic>>? pendingGoals,
    Map<String, dynamic>? goalStatistics,
    ActivityGoal? currentGoal,
    String? errorMessage,
  }) {
    return ActivityGoalState(
      status: status ?? this.status,
      routesWithGoals: routesWithGoals ?? this.routesWithGoals,
      completedGoals: completedGoals ?? this.completedGoals,
      pendingGoals: pendingGoals ?? this.pendingGoals,
      goalStatistics: goalStatistics ?? this.goalStatistics,
      currentGoal: currentGoal ?? this.currentGoal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == ActivityGoalStatus.loading;
  bool get isCreating => status == ActivityGoalStatus.creating;
  bool get isUpdating => status == ActivityGoalStatus.updating;
  bool get isDeleting => status == ActivityGoalStatus.deleting;
  bool get hasError => errorMessage != null;
  bool get hasCurrentGoal => currentGoal != null;

  @override
  List<Object?> get props => [
        status,
        routesWithGoals,
        completedGoals,
        pendingGoals,
        goalStatistics,
        currentGoal,
        errorMessage,
      ];
} 
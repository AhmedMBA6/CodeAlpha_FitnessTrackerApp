import 'package:flutter_bloc/flutter_bloc.dart';
import 'activity_goal_state.dart';
import '../data/models/activity_goal.dart';
import '../data/repositories/activity_goal_repository.dart';
import '../data/services/goal_service.dart';
import '../../route_tracking/data/models/route_point.dart';
import '../../route_tracking/data/models/route_track.dart';

class ActivityGoalCubit extends Cubit<ActivityGoalState> {
  final ActivityGoalRepository _repository;

  ActivityGoalCubit({required ActivityGoalRepository repository})
      : _repository = repository,
        super(const ActivityGoalState.initial());

  /// Load all routes with goals and statistics
  Future<void> loadGoals() async {
    emit(state.copyWith(status: ActivityGoalStatus.loading));
    
    try {
      final routesWithGoals = await _repository.getRoutesWithGoals();
      final completedGoals = await _repository.getRoutesWithCompletedGoals();
      final pendingGoals = await _repository.getRoutesWithPendingGoals();
      final goalStatistics = await _repository.getGoalStatistics();

      emit(state.copyWith(
        status: ActivityGoalStatus.success,
        routesWithGoals: routesWithGoals,
        completedGoals: completedGoals,
        pendingGoals: pendingGoals,
        goalStatistics: goalStatistics,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ActivityGoalStatus.failure,
        errorMessage: 'Failed to load goals: $e',
      ));
    }
  }

  /// Create a distance-based goal
  Future<void> createDistanceGoal({
    required double distanceInMeters,
    String? description,
  }) async {
    emit(state.copyWith(status: ActivityGoalStatus.creating));
    
    try {
      final goal = _repository.createDistanceGoal(
        distanceInMeters: distanceInMeters,
        description: description,
      );

      if (!_repository.isValidGoal(goal)) {
        emit(state.copyWith(
          status: ActivityGoalStatus.failure,
          errorMessage: 'Invalid goal configuration',
        ));
        return;
      }

      emit(state.copyWith(
        status: ActivityGoalStatus.success,
        currentGoal: goal,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ActivityGoalStatus.failure,
        errorMessage: 'Failed to create distance goal: $e',
      ));
    }
  }

  /// Create a destination-based goal
  Future<void> createDestinationGoal({
    required RoutePoint destination,
    String? description,
  }) async {
    emit(state.copyWith(status: ActivityGoalStatus.creating));
    
    try {
      final goal = _repository.createDestinationGoal(
        destination: destination,
        description: description,
      );

      if (!_repository.isValidGoal(goal)) {
        emit(state.copyWith(
          status: ActivityGoalStatus.failure,
          errorMessage: 'Invalid goal configuration',
        ));
        return;
      }

      emit(state.copyWith(
        status: ActivityGoalStatus.success,
        currentGoal: goal,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ActivityGoalStatus.failure,
        errorMessage: 'Failed to create destination goal: $e',
      ));
    }
  }

  /// Set a goal for a specific route
  Future<void> setGoalForRoute(String routeId, ActivityGoal goal) async {
    emit(state.copyWith(status: ActivityGoalStatus.updating));
    
    try {
      await _repository.updateGoalForRoute(routeId, goal);
      
      // Reload goals to reflect changes
      await loadGoals();
      
      emit(state.copyWith(
        status: ActivityGoalStatus.success,
        currentGoal: goal,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ActivityGoalStatus.failure,
        errorMessage: 'Failed to set goal for route: $e',
      ));
    }
  }

  /// Remove a goal from a route
  Future<void> removeGoalFromRoute(String routeId) async {
    emit(state.copyWith(status: ActivityGoalStatus.deleting));
    
    try {
      await _repository.deleteGoalFromRoute(routeId);
      
      // Reload goals to reflect changes
      await loadGoals();
      
      emit(state.copyWith(
        status: ActivityGoalStatus.success,
        currentGoal: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ActivityGoalStatus.failure,
        errorMessage: 'Failed to remove goal from route: $e',
      ));
    }
  }

  /// Get goal for a specific route
  Future<void> getGoalForRoute(String routeId) async {
    emit(state.copyWith(status: ActivityGoalStatus.loading));
    
    try {
      final goal = await _repository.getGoalForRoute(routeId);
      
      emit(state.copyWith(
        status: ActivityGoalStatus.success,
        currentGoal: goal,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ActivityGoalStatus.failure,
        errorMessage: 'Failed to get goal for route: $e',
      ));
    }
  }

  /// Calculate progress for a route with a goal
  double calculateGoalProgress(RouteTrack route) {
    if (route.goal == null) return 0.0;
    return route.goalProgress;
  }

  /// Check if a route has reached its goal
  bool isGoalReached(RouteTrack route) {
    if (route.goal == null) return false;
    return route.isGoalReached;
  }

  /// Get distance to goal for destination goals
  double? getDistanceToGoal(RouteTrack route) {
    return route.distanceToGoal;
  }

  /// Get formatted progress description
  String getProgressDescription(RouteTrack route) {
    if (route.goal == null) return '';
    
    final currentPosition = route.points.isNotEmpty ? route.points.last : null;
    return GoalService.getProgressDescription(
      route.goal!,
      route.currentDistance,
      currentPosition,
    );
  }

  /// Get goal statistics
  Map<String, dynamic>? getGoalStatistics() {
    return state.goalStatistics;
  }

  /// Get routes with goals
  List<Map<String, dynamic>> getRoutesWithGoals() {
    return state.routesWithGoals;
  }

  /// Get completed goals
  List<Map<String, dynamic>> getCompletedGoals() {
    return state.completedGoals;
  }

  /// Get pending goals
  List<Map<String, dynamic>> getPendingGoals() {
    return state.pendingGoals;
  }

  /// Clear current goal
  void clearCurrentGoal() {
    emit(state.copyWith(currentGoal: null));
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Reset state to initial
  void reset() {
    emit(const ActivityGoalState.initial());
  }
} 
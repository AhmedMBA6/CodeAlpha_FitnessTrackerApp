import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/activity_goal.dart';
import '../../../activity_log/data/repos/activity_log_goal_link_repository.dart';
import '../../../activity_log/data/repos/activity_log_repository.dart';
import '../../data/repositories/activity_goal_repository.dart';
import 'goals_state.dart';
import '../../../../core/utils/goal_progress_utils.dart';
import '../../../activity_log/data/models/activity_log_model.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final ActivityGoalRepository _goalRepo;
  final ActivityLogGoalLinkRepository _linkRepo;
  final ActivityLogRepository? _activityLogRepo;

  GoalsCubit({
    required ActivityGoalRepository goalRepo,
    required ActivityLogGoalLinkRepository linkRepo,
    ActivityLogRepository? activityLogRepo,
  })  : _goalRepo = goalRepo,
        _linkRepo = linkRepo,
        _activityLogRepo = activityLogRepo,
        super(GoalsState(isLoading: true)) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final goals = await _goalRepo.getAllGoals();
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, goals: goals));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  Future<void> loadGoalsByArchived(bool isArchived) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final goals = await _goalRepo.getGoalsByArchived(isArchived);
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, goals: goals));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  Future<void> archiveGoal(String goalId) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _goalRepo.archiveGoal(goalId);
      await loadGoals();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  Future<void> unarchiveGoal(String goalId) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _goalRepo.unarchiveGoal(goalId);
      await loadGoalsByArchived(true);
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  Future<void> addGoal(ActivityGoal goal) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _goalRepo.addGoal(goal);
      await loadGoals();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  Future<void> updateGoal(ActivityGoal updatedGoal) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _goalRepo.updateGoal(updatedGoal);
      await loadGoals();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  Future<void> deleteGoal(String goalId) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _goalRepo.deleteGoal(goalId);
      await loadGoals();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  /// Fetches all activity logs linked to a specific goal.
  Future<List<ActivityLogModel>> getLinkedActivitiesForGoal(String goalId) async {
    if (_activityLogRepo == null) return [];
    final links = await _linkRepo.getLinksForGoal(goalId);
    if (links.isEmpty) return [];
    final allLogs = await _activityLogRepo.getAllActivities();
    final logIds = links.map((l) => l.activityLogId).toSet();
    return allLogs.where((log) => log.id != null && logIds.contains(log.id.toString())).toList();
  }

  /// Optionally: update progress for a goal based on linked activities
  Future<void> updateGoalProgress(String goalId) async {
    // This method can be implemented to use GoalProgressService if needed
    await loadGoals();
  }

  /// Returns smart goal suggestions based on recent activity logs, or static templates if no data.
  Future<List<ActivityGoal>> getGoalSuggestions() async {
    if (_activityLogRepo == null) {
      return GoalSuggestionService.getGoalSuggestions([]);
    }
    final recentActivities = await _activityLogRepo.getAllActivities();
    return GoalSuggestionService.getGoalSuggestions(recentActivities);
  }

  GoalStatus getGoalStatus(ActivityGoal goal, List<ActivityLogModel> logs) {
    return GoalProgressService.calculateGoalProgress(goal, logs).status;
  }
} 
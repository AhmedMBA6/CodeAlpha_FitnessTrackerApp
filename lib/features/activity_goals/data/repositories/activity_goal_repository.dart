import '../../data/models/activity_goal.dart';
import '../../../../core/utils/sqlite_helper.dart';

class ActivityGoalRepository {
  final SQLHelper _dbHelper;

  ActivityGoalRepository({SQLHelper? dbHelper}) : _dbHelper = dbHelper ?? SQLHelper();

  Future<List<ActivityGoal>> getAllGoals() async {
    final maps = await _dbHelper.getAllActivityGoals();
    return maps.map((m) => ActivityGoal.fromJson(m)).toList();
  }

  Future<List<ActivityGoal>> getGoalsByArchived(bool isArchived) async {
    final maps = await _dbHelper.getGoalsByArchived(isArchived);
    return maps.map((m) => ActivityGoal.fromJson(m)).toList();
  }

  Future<void> addGoal(ActivityGoal goal) async {
    await _dbHelper.insertActivityGoal(goal.toJson());
  }

  Future<void> updateGoal(ActivityGoal goal) async {
    await _dbHelper.updateActivityGoal(goal.toJson());
  }

  Future<void> deleteGoal(String id) async {
    await _dbHelper.deleteActivityGoal(id);
  }

  Future<void> archiveGoal(String goalId) async {
    final goals = await _dbHelper.getAllActivityGoals();
    final goal = goals.firstWhere((g) => g['id'] == goalId);
    final updated = Map<String, dynamic>.from(goal);
    updated['isArchived'] = true;
    await _dbHelper.updateActivityGoal(updated);
  }

  Future<void> unarchiveGoal(String goalId) async {
    final goals = await _dbHelper.getAllActivityGoals();
    final goal = goals.firstWhere((g) => g['id'] == goalId);
    final updated = Map<String, dynamic>.from(goal);
    updated['isArchived'] = false;
    await _dbHelper.updateActivityGoal(updated);
  }

  Future<Map<String, dynamic>> getGoalStatistics() async {
    final goals = await getAllGoals();
    final pendingGoals = goals.where((g) => !(g.isCompleted ?? false)).length;
    final averageProgress = goals.isNotEmpty
        ? goals.map((g) => g.progress ?? 0.0).reduce((a, b) => a + b) / goals.length
        : 0.0;
    return {
      'pendingGoals': pendingGoals,
      'averageProgress': averageProgress,
    };
  }
} 
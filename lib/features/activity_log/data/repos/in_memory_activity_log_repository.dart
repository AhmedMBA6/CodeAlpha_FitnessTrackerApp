import 'activity_log_repository.dart';
import '../models/activity_log_model.dart';
import 'activity_log_goal_link_repository.dart';
import 'in_memory_activity_log_goal_link_repository.dart';

class InMemoryActivityLogRepository implements ActivityLogRepository {
  final List<ActivityLogModel> _logs = [];
  final ActivityLogGoalLinkRepository _linkRepo = InMemoryActivityLogGoalLinkRepository();

  @override
  ActivityLogGoalLinkRepository get linkRepo => _linkRepo;

  @override
  Future<List<ActivityLogModel>> getAllActivities() async => _logs;

  @override
  Future<int> addActivity(ActivityLogModel log) async {
    final newId = (_logs.length + 1).toString();
    _logs.add(log.copyWith(id: newId));
    return int.parse(newId);
  }

  @override
  Future<void> updateActivity(ActivityLogModel log) async {
    final idx = _logs.indexWhere((l) => l.id == log.id);
    if (idx != -1) _logs[idx] = log;
  }

  @override
  Future<void> deleteActivity(String id) async => _logs.removeWhere((l) => l.id == id);

  @override
  Future<List<ActivityLogModel>> getActivitiesForGoal(String goalId) async {
    return _logs.where((log) => log.linkedGoalIds?.contains(goalId) == true).toList();
  }
} 
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
  Future<List<ActivityLogModel>> getAllActivities({bool runCleanup = false}) async => _logs;

  @override
  Future<String> addActivity(ActivityLogModel log) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    _logs.add(log.copyWith(id: newId));
    return newId;
  }

  @override
  Future<void> updateActivity(ActivityLogModel log) async {
    final idx = _logs.indexWhere((l) => l.id == log.id);
    if (idx != -1) _logs[idx] = log;
  }

  @override
  Future<void> deleteActivity(String id, {bool cleanupOrphanedLinks = false}) async {
    _logs.removeWhere((l) => l.id == id);
    if (cleanupOrphanedLinks) {
      await _cleanupOrphanedLinks();
    }
  }

  @override
  Future<List<ActivityLogModel>> getActivitiesForGoal(String goalId) async {
    return _logs.where((log) => log.linkedGoalIds?.contains(goalId) == true).toList();
  }

  @override
  Future<bool> activityExists(String id) async {
    return _logs.any((log) => log.id == id);
  }

  @override
  Future<Map<String, dynamic>> checkCleanupNeeded() async {
    return {
      'needsCleanup': false,
      'nullIdActivities': 0,
      'orphanedLinks': 0,
      'duplicateActivities': 0,
    };
  }

  @override
  Future<void> fixActivitiesWithNullIds() async {
    // No implementation needed for in-memory repository
  }

  @override
  Future<void> removeDuplicateActivities() async {
    // No implementation needed for in-memory repository
  }

  @override
  Future<void> runCleanupOperations() async {
    // No implementation needed for in-memory repository
  }

  Future<void> _cleanupOrphanedLinks() async {
    // No implementation needed for in-memory repository
  }
} 
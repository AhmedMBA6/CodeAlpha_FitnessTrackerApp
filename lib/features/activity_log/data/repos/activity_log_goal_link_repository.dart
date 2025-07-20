import '../models/activity_log_goal_link.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/sqlite_helper.dart';

abstract class ActivityLogGoalLinkRepository {
  Future<void> linkGoalToActivityLog(ActivityLogGoalLink link);
  Future<void> unlinkGoalFromActivityLog(String linkId, {DateTime? unlinkedAt});
  Future<List<ActivityLogGoalLink>> getLinksForActivityLog(String activityLogId);
  Future<List<ActivityLogGoalLink>> getLinksForGoal(String goalId);
  Future<ActivityLogGoalLink?> getLink(String linkId);
  Future<List<ActivityLogGoalLink>> getAllLinks();
}

class SQLiteActivityLogGoalLinkRepository implements ActivityLogGoalLinkRepository {
  final SQLHelper _dbHelper;

  SQLiteActivityLogGoalLinkRepository({SQLHelper? dbHelper}) : _dbHelper = dbHelper ?? SQLHelper();

  @override
  Future<void> linkGoalToActivityLog(ActivityLogGoalLink link) async {
    await _dbHelper.insertLink(link.toJson());
  }

  @override
  Future<void> unlinkGoalFromActivityLog(String linkId, {DateTime? unlinkedAt}) async {
    final links = await _dbHelper.getAllLinks();
    final idx = links.indexWhere((l) => l['id'] == linkId);
    if (idx != -1) {
      final updated = Map<String, dynamic>.from(links[idx]);
      updated['unlinkedAt'] = (unlinkedAt ?? DateTime.now()).toIso8601String();
      await _dbHelper.updateLink(updated);
    }
  }

  @override
  Future<List<ActivityLogGoalLink>> getLinksForActivityLog(String activityLogId) async {
    final maps = await _dbHelper.getLinksForActivityLog(activityLogId);
    return maps.map((m) => ActivityLogGoalLink.fromJson(m)).toList();
  }

  @override
  Future<List<ActivityLogGoalLink>> getLinksForGoal(String goalId) async {
    final maps = await _dbHelper.getLinksForGoal(goalId);
    return maps.map((m) => ActivityLogGoalLink.fromJson(m)).toList();
  }

  @override
  Future<ActivityLogGoalLink?> getLink(String linkId) async {
    final maps = await _dbHelper.getAllLinks();
    try {
      return ActivityLogGoalLink.fromJson(maps.firstWhere((l) => l['id'] == linkId));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ActivityLogGoalLink>> getAllLinks() async {
    final maps = await _dbHelper.getAllLinks();
    return maps.map((m) => ActivityLogGoalLink.fromJson(m)).toList();
  }
} 
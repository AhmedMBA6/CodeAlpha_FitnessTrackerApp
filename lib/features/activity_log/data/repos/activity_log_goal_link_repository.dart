import '../models/activity_log_goal_link.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/sqlite_helper.dart';

abstract class ActivityLogGoalLinkRepository {
  Future<void> linkGoalToActivityLog(ActivityLogGoalLink link);
  Future<void> unlinkGoalFromActivityLog(String linkId, {DateTime? unlinkedAt});
  Future<void> deleteLink(String linkId);
  Future<void> updateLink(Map<String, dynamic> data);
  Future<void> deleteAllLinksForActivityLog(String activityLogId);
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
  Future<void> deleteLink(String linkId) async {
    await _dbHelper.deleteLink(linkId);
  }

  @override
  Future<void> updateLink(Map<String, dynamic> data) async {
    await _dbHelper.updateLink(data);
  }

  @override
  /// Deletes all links for a specific activity log
  Future<void> deleteAllLinksForActivityLog(String activityLogId) async {
    print('[LINK_REPO] deleteAllLinksForActivityLog called with activityLogId: $activityLogId');
    
    // Validate input
    if (activityLogId.isEmpty) {
      print('[LINK_REPO] Invalid activityLogId (empty)');
      return;
    }
    
    try {
      final links = await getLinksForActivityLog(activityLogId);
      print('[LINK_REPO] Found ${links.length} links to delete');
      
      if (links.isEmpty) {
        print('[LINK_REPO] No links found for activityLogId: $activityLogId');
        return;
      }
      
      for (final link in links) {
        try {
          print('[LINK_REPO] Deleting link with ID: ${link.id}');
          await _dbHelper.deleteLink(link.id);
        } catch (e) {
          print('[LINK_REPO] Error deleting link ${link.id}: $e');
          // Continue with other links even if one fails
        }
      }
      print('[LINK_REPO] All links deleted for activityLogId: $activityLogId');
    } catch (e) {
      print('[LINK_REPO] Error in deleteAllLinksForActivityLog: $e');
      print('[LINK_REPO] Stack trace: ${StackTrace.current}');
      throw Exception('Failed to delete links for activity: ${e.toString()}');
    }
  }

  @override
  Future<List<ActivityLogGoalLink>> getLinksForActivityLog(String activityLogId) async {
    print('[LINK_REPO] getLinksForActivityLog called with activityLogId: $activityLogId');
    final maps = await _dbHelper.getLinksForActivityLog(activityLogId);
    final links = maps.map((m) => ActivityLogGoalLink.fromJson(m)).toList();
    print('[LINK_REPO] Found ${links.length} links for activityLogId: $activityLogId');
    return links;
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
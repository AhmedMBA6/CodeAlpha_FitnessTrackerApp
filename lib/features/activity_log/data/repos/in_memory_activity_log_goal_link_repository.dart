import 'activity_log_goal_link_repository.dart';
import '../models/activity_log_goal_link.dart';

class InMemoryActivityLogGoalLinkRepository implements ActivityLogGoalLinkRepository {
  final List<ActivityLogGoalLink> _links = [];

  @override
  Future<void> linkGoalToActivityLog(ActivityLogGoalLink link) async {
    _links.add(link);
  }

  @override
  Future<void> unlinkGoalFromActivityLog(String linkId, {DateTime? unlinkedAt}) async {
    final idx = _links.indexWhere((l) => l.id == linkId);
    if (idx != -1) {
      final updated = _links[idx].copyWith(unlinkedAt: unlinkedAt ?? DateTime.now());
      _links[idx] = updated;
    }
  }

  @override
  Future<List<ActivityLogGoalLink>> getLinksForActivityLog(String activityLogId) async {
    return _links.where((l) => l.activityLogId == activityLogId).toList();
  }

  @override
  Future<List<ActivityLogGoalLink>> getLinksForGoal(String goalId) async {
    return _links.where((l) => l.goalId == goalId).toList();
  }

  @override
  Future<ActivityLogGoalLink?> getLink(String linkId) async {
    try {
      return _links.firstWhere((l) => l.id == linkId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ActivityLogGoalLink>> getAllLinks() async {
    return _links;
  }

  @override
  Future<void> deleteAllLinksForActivityLog(String activityLogId) async {
    _links.removeWhere((l) => l.activityLogId == activityLogId);
  }

  @override
  Future<void> deleteLink(String linkId) async {
    _links.removeWhere((l) => l.id == linkId);
  }

  @override
  Future<void> updateLink(Map<String, dynamic> data) async {
    final linkId = data['id'] as String?;
    if (linkId != null) {
      final idx = _links.indexWhere((l) => l.id == linkId);
      if (idx != -1) {
        final updated = ActivityLogGoalLink.fromJson(data);
        _links[idx] = updated;
      }
    }
  }
} 
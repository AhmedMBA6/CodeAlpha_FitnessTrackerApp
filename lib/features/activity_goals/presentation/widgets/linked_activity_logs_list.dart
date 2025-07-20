import 'package:flutter/material.dart';
import '../../../activity_log/data/models/activity_log_model.dart';
import '../../../activity_log/data/repos/activity_log_repository.dart';
import '../../../activity_log/data/repos/activity_log_goal_link_repository.dart';

class LinkedActivityLogsList extends StatelessWidget {
  final String goalId;
  final ActivityLogGoalLinkRepository linkRepo;
  final ActivityLogRepository logRepo;
  const LinkedActivityLogsList({super.key, required this.goalId, required this.linkRepo, required this.logRepo});

  Future<List<ActivityLogModel>> _fetchLinkedLogs() async {
    final links = await linkRepo.getLinksForGoal(goalId);
    if (links.isEmpty) return [];
    final allLogs = await logRepo.getAllActivities();
    final logIds = links.map((l) => l.activityLogId).toSet();
    return allLogs.where((log) => log.id != null && logIds.contains(log.id.toString())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActivityLogModel>>(
      future: _fetchLinkedLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No activity logs linked to this goal.'),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final log = logs[i];
            return ListTile(
              title: Text(log.activityType),
              subtitle: Text(
                'Duration: ${log.duration} min\nCalories: ${log.calories}\nDate: ${log.date.toLocal().toIso8601String().split('T').first}${log.heartRate != null ? '\nHeart Rate: ${log.heartRate}' : ''}${log.distance != null ? '\nDistance: ${log.distance} km' : ''}',
              ),
              isThreeLine: true,
            );
          },
        );
      },
    );
  }
} 
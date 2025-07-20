import 'package:flutter/material.dart';
import '../../features/activity_goals/data/models/activity_goal.dart';
import '../../features/activity_log/data/repos/activity_log_repository.dart';
import '../../features/activity_log/data/models/activity_log_model.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/goal_progress_utils.dart';
import '../../features/activity_log/data/repos/activity_log_goal_link_repository.dart';

class GoalDetailsDialog extends StatefulWidget {
  final ActivityGoal goal;
  final String routeId;
  final double progress;
  final bool isCompleted;
  const GoalDetailsDialog({super.key, required this.goal, required this.routeId, required this.progress, required this.isCompleted});

  @override
  State<GoalDetailsDialog> createState() => _GoalDetailsDialogState();
}

class _GoalDetailsDialogState extends State<GoalDetailsDialog> {
  List<ActivityLogModel> _logs = [];
  List<ActivityLogModel> _allLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _fetchRealRouteIfNeeded();
  }

  Future<void> _fetchLogs() async {
    final repo = ActivityLogRepository(linkRepo: SQLiteActivityLogGoalLinkRepository());
    final allLogs = await repo.getAllActivities();
    setState(() {
      _allLogs = allLogs;
      _logs = allLogs.where((log) => log.linkedGoalIds?.contains(widget.routeId) == true).toList();
      _loading = false;
    });
  }

  Future<void> _fetchRealRouteIfNeeded() async {
    final goal = widget.goal;

    // TODO: Add route fetching logic if/when start/end points are added to ActivityGoal.
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Goal Details'),
      content: _loading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SizedBox(
              width: 350,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${widget.goal.description ?? "-"}'),
                    // State label
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Tooltip(
                            message: 'Goal state',
                            child: Semantics(
                              label: 'Goal state: ${getGoalStateLabel(widget.progress, widget.isCompleted)}',
                              child: Chip(
                                label: Text(
                                  getGoalStateLabel(widget.progress, widget.isCompleted),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: widget.isCompleted
                                    ? Colors.green[100]
                                    : widget.progress >= 0.99
                                        ? Colors.blue[100]
                                        : widget.progress >= 0.5
                                            ? Colors.orange[100]
                                            : widget.progress >= 0.2
                                                ? Colors.yellow[100]
                                                : Colors.grey[200],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: 'Goal progress percent',
                      child: Semantics(
                        label: 'Goal progress: ${(widget.progress * 100).toStringAsFixed(1)} percent',
                        child: Text('Progress: ${(widget.progress * 100).toStringAsFixed(1)}%'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: LinearProgressIndicator(
                        value: widget.progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isCompleted ? Colors.green : (widget.progress >= 0.5 ? Colors.orange : Colors.blue),
                        ),
                        semanticsLabel: 'Goal progress bar',
                      ),
                    ),
                    Tooltip(
                      message: 'Goal completion status',
                      child: Semantics(
                        label: 'Goal completed: ${widget.isCompleted ? "Yes" : "No"}',
                        child: Text('Completed: ${widget.isCompleted ? "Yes" : "No"}'),
                      ),
                    ),
                    // Remove all logic and UI that references startPoint, endPoint, and destination goal type, since these fields do not exist in ActivityGoal.
                    // Remove the related if conditions, map display, and any code that depends on these fields.
                    // Leave a TODO comment if needed for future support.
                    const SizedBox(height: 16),
                    const Text('Linked Activity Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_allLogs.isEmpty)
                      const Text('No activity logs available.'),
                    ..._allLogs.map((log) {
                      final isLinked = log.linkedGoalIds?.contains(widget.routeId) == true;
                      return Tooltip(
                        message: isLinked ? 'Unlink this log from goal' : 'Link this log to goal',
                        child: Semantics(
                          label: isLinked
                              ? 'Linked activity log: ${log.activityType}, Date: ${log.date.toLocal().toIso8601String().split('T').first}, Unlink button'
                              : 'Unlinked activity log: ${log.activityType}, Date: ${log.date.toLocal().toIso8601String().split('T').first}, Link button',
                          child: ListTile(
                            title: Text(log.activityType),
                            subtitle: Text('Date: ${log.date.toLocal().toIso8601String().split('T').first}'),
                            trailing: isLinked
                                ? IconButton(
                                    icon: const Icon(Icons.link_off, color: Colors.red),
                                    tooltip: 'Unlink from goal',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Unlink Log'),
                                          content: const Text('Unlink this activity log from this goal?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              child: const Text('Unlink'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final repo = ActivityLogRepository(linkRepo: SQLiteActivityLogGoalLinkRepository());
                                        await repo.updateActivity(ActivityLogModel(
                                          id: log.id,
                                          activityType: log.activityType,
                                          duration: log.duration,
                                          calories: log.calories,
                                          date: log.date,
                                          heartRate: log.heartRate,
                                          distance: log.distance,
                                          linkedGoalIds: log.linkedGoalIds?.where((id) => id != widget.routeId).toList(),
                                        ));
                                        await _fetchLogs();
                                      }
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.link, color: Colors.green),
                                    tooltip: 'Link to goal',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Link Log'),
                                          content: const Text('Link this activity log to this goal?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              child: const Text('Link'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final repo = ActivityLogRepository(linkRepo: SQLiteActivityLogGoalLinkRepository());
                                        await repo.updateActivity(ActivityLogModel(
                                          id: log.id,
                                          activityType: log.activityType,
                                          duration: log.duration,
                                          calories: log.calories,
                                          date: log.date,
                                          heartRate: log.heartRate,
                                          distance: log.distance,
                                          linkedGoalIds: [...log.linkedGoalIds ?? [], widget.routeId],
                                        ));
                                        await _fetchLogs();
                                      }
                                    },
                                  ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        Tooltip(
          message: 'Edit goal',
          child: IconButton(
            icon: const Icon(Icons.edit, semanticLabel: 'Edit goal'),
            onPressed: () async {
              // final updatedGoal = await showDialog<ActivityGoal>(
              //   context: context,
              //   builder: (ctx) => GoalInputDialog(initialGoal: widget.goal),
              // );
              // if (updatedGoal != null) {
              //   // Use Navigator.pop to return a signal to refresh
              //   Navigator.of(context).pop({'action': 'edit', 'goal': updatedGoal});
              // }
            },
          ),
        ),
        Tooltip(
          message: 'Delete goal',
          child: IconButton(
            icon: const Icon(Icons.delete, semanticLabel: 'Delete goal'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.warning, color: Colors.red, size: 28),
                      SizedBox(width: 8),
                      Text('Delete Goal'),
                    ],
                  ),
                  content: const Text('Are you sure you want to delete this goal?\n\nThis action cannot be undone and you will lose all progress linked to this goal.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                Navigator.of(context).pop({'action': 'delete'});
              }
            },
          ),
        ),
      ],
    );
  }
} 
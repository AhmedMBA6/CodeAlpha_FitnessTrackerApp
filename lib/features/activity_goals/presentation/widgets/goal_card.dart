import 'package:flutter/material.dart';
import '../../data/models/activity_goal.dart';
import 'goal_status_chip.dart';
import 'goal_progress_ring.dart';
import '../../../../core/utils/goal_progress_utils.dart';
import '../../../activity_log/data/models/activity_log_model.dart';

class GoalCard extends StatelessWidget {
  final ActivityGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onLinkedActivitiesTap;
  final VoidCallback? onArchiveToggle;
  final List<ActivityLogModel> logs;

  const GoalCard({
    super.key,
    required this.goal,
    this.logs = const [],
    this.onTap,
    this.onLinkedActivitiesTap,
    this.onArchiveToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressResult = GoalProgressService.calculateGoalProgress(goal, logs);
    final progress = progressResult.progress;
    final status = progressResult.status;
    final icon = _getGoalIcon(goal);
    final color = theme.colorScheme.primary;
    final surfaceVariant = theme.colorScheme.surfaceContainerHighest;
    final onSurface = theme.colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: surfaceVariant,
                    radius: 28,
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getGoalTitle(goal), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(_getGoalTarget(goal), style: theme.textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        GoalProgressRing(progress: progress, size: 40, color: color),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      GoalStatusChip(status: status, color: color),
                      const SizedBox(height: 8),
                      Tooltip(
                        message: 'Show linked activities',
                        child: Semantics(
                          label: 'Show linked activities for this goal',
                          button: true,
                          child: InkWell(
                            onTap: onLinkedActivitiesTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                Icon(Icons.link, size: 18, color: color),
                                const SizedBox(width: 4),
                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (goal.isCompleted == true)
                        Tooltip(
                          message: goal.isArchived ? 'Unarchive Goal' : 'Archive Goal',
                          child: Semantics(
                            label: goal.isArchived ? 'Unarchive Goal' : 'Archive Goal',
                            button: true,
                            child: IconButton(
                              icon: Icon(goal.isArchived ? Icons.unarchive : Icons.archive, color: onSurface),
                              tooltip: goal.isArchived ? 'Unarchive Goal' : 'Archive Goal',
                              onPressed: onArchiveToggle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (goal.isArchived)
            Positioned(
              top: 8,
              right: 8,
              child: Tooltip(
                message: 'Archived',
                child: Chip(
                  label: const Text('Archived'),
                  backgroundColor: surfaceVariant,
                  labelStyle: TextStyle(color: onSurface),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getGoalTitle(ActivityGoal goal) {
    switch (goal.goalType) {
      case GoalType.quantitative:
        return 'Quantitative Goal';
      case GoalType.qualitative:
        return 'Qualitative Goal';
    }
  }

  String _getGoalTarget(ActivityGoal goal) {
    if (goal.goalType == GoalType.quantitative) {
      return 'Target: ${goal.targetValue?.toStringAsFixed(0) ?? '-'} ${goal.unit ?? ''}';
    } else {
      return 'Tags: ${goal.tags?.join(', ') ?? '-'}';
    }
  }

  IconData _getGoalIcon(ActivityGoal goal) {
    if (goal.unit == 'calories') return Icons.local_fire_department;
    if (goal.unit == 'km' || goal.unit == 'miles') return Icons.directions_run;
    if (goal.unit == 'minutes' || goal.unit == 'hours') return Icons.timer;
    if (goal.tags != null && goal.tags!.contains('trapezius')) return Icons.fitness_center;
    return Icons.flag;
  }
} 
import 'package:flutter/material.dart';
import '../../../../core/utils/goal_progress_utils.dart';

class GoalStatusChip extends StatelessWidget {
  final GoalStatus status;
  final Color color;
  const GoalStatusChip({required this.status, required this.color, super.key});

  String get label {
    switch (status) {
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.almostDone:
        return 'Almost Done';
      case GoalStatus.inProgress:
        return 'In Progress';
      case GoalStatus.inactive:
        return 'Inactive';
      case GoalStatus.notStarted:
      return 'Not Started';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Goal status: $label',
      child: Chip(
        label: Text(label, style: TextStyle(color: color)),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
    );
  }
} 
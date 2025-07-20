import 'package:flutter/material.dart';
import '../../../activity_goals/data/models/activity_goal.dart';

class ActivityProgressChip extends StatelessWidget {
  final List<ActivityGoal> linkedGoals;
  const ActivityProgressChip({super.key, required this.linkedGoals});

  @override
  Widget build(BuildContext context) {
    if (linkedGoals.isEmpty) return SizedBox.shrink();
    return Wrap(
      spacing: 8,
      children: linkedGoals.map((g) => Chip(
        label: Text(g.description ?? g.id),
        avatar: const Icon(Icons.flag),
      )).toList(),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'goal_card.dart';
import '../../data/models/activity_goal.dart';
import '../../logic/cubit/goals_cubit.dart';
import '../../../activity_log/data/models/activity_log_model.dart';

class GoalsOverviewList extends StatelessWidget {
  final void Function(ActivityGoal goal)? onGoalTap;
  final VoidCallback? onAddGoal;
  final void Function(ActivityGoal goal)? onLinkedActivitiesTap;
  final void Function(ActivityGoal goal)? onArchiveToggle;
  final List<ActivityGoal> goals;

  const GoalsOverviewList({
    super.key,
    this.onGoalTap,
    this.onAddGoal,
    this.onLinkedActivitiesTap,
    this.onArchiveToggle,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 96, top: 8),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final cubit = BlocProvider.of<GoalsCubit>(context, listen: false);
            return FutureBuilder<List<ActivityLogModel>>(
              future: cubit.getLinkedActivitiesForGoal(goal.id),
              builder: (context, snapshot) {
                final logs = snapshot.data ?? [];
                return GoalCard(
                  goal: goal,
                  logs: logs,
                  onTap: () => onGoalTap?.call(goal),
                  onLinkedActivitiesTap: () => onLinkedActivitiesTap?.call(goal),
                  onArchiveToggle: () => onArchiveToggle?.call(goal),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: onAddGoal,
            icon: const Icon(Icons.add),
            label: const Text('Add Goal'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            heroTag: 'add_goal_fab',
          ),
        ),
      ],
    );
  }
} 
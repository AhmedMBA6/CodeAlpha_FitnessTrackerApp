import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubit/goals_cubit.dart';
import '../data/models/activity_goal.dart';
import '../logic/cubit/goals_state.dart';
import 'widgets/goals_overview_list.dart';
import 'widgets/goal_template_selector.dart';
import 'widgets/goal_creation_form.dart';

enum GoalFilterType { all, inProgress, completed, archived }

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  GoalFilterType _filterType = GoalFilterType.all;

  void _resetFilter() => setState(() => _filterType = GoalFilterType.all);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filterType == GoalFilterType.all,
                      onSelected: (_) {
                        setState(() => _filterType = GoalFilterType.all);
                        context.read<GoalsCubit>().loadGoals();
                      },
                      tooltip: 'Show all goals',
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('In Progress'),
                      selected: _filterType == GoalFilterType.inProgress,
                      onSelected: (_) {
                        setState(() => _filterType = GoalFilterType.inProgress);
                        context.read<GoalsCubit>().loadGoals();
                      },
                      tooltip: 'Show goals in progress',
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Completed'),
                      selected: _filterType == GoalFilterType.completed,
                      onSelected: (_) {
                        setState(() => _filterType = GoalFilterType.completed);
                        context.read<GoalsCubit>().loadGoals();
                      },
                      tooltip: 'Show completed goals',
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Archived'),
                      selected: _filterType == GoalFilterType.archived,
                      onSelected: (_) {
                        setState(() => _filterType = GoalFilterType.archived);
                        context.read<GoalsCubit>().loadGoalsByArchived(true);
                      },
                      tooltip: 'Show archived goals',
                    ),
                  ],
                ),
              ),
            ),
            // Goals list or empty state
            Expanded(
              child: BlocBuilder<GoalsCubit, GoalsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('Couldn’t load goals', style: TextStyle(color: Colors.red, fontSize: 18)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<GoalsCubit>().loadGoals(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  List<ActivityGoal> filteredGoals = state.goals;
                  if (_filterType == GoalFilterType.inProgress) {
                    filteredGoals = state.goals.where((g) => g.isCompleted != true && g.isArchived != true).toList();
                  } else if (_filterType == GoalFilterType.completed) {
                    filteredGoals = state.goals.where((g) => g.isCompleted == true && g.isArchived != true).toList();
                  } else if (_filterType == GoalFilterType.all) {
                    filteredGoals = state.goals.where((g) => g.isArchived != true).toList();
                  } // archived filter handled by cubit
                  if (filteredGoals.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  // Only build the list if not loading/error
                  if (!state.isLoading && state.error == null) {
                    return GoalsOverviewList(
                      onGoalTap: (goal) {
                        // TODO: Navigate to goal details page
                      },
                      onAddGoal: () => _showGoalTemplateSelector(context),
                      onLinkedActivitiesTap: (goal) {
                        // TODO: Show linked activities for this goal
                      },
                      onArchiveToggle: (goal) async {
                        final cubit = context.read<GoalsCubit>();
                        if (goal.isArchived) {
                          await cubit.unarchiveGoal(goal.id);
                        } else {
                          await cubit.archiveGoal(goal.id);
                        }
                      },
                      goals: filteredGoals,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    String message;
    IconData icon;
    Widget? action;
    if (_filterType == GoalFilterType.inProgress) {
      message = 'No goals in progress.\nAll your goals are completed!';
      icon = Icons.emoji_events;
      action = OutlinedButton(
        onPressed: _resetFilter,
        child: const Text('Show All'),
      );
    } else if (_filterType == GoalFilterType.completed) {
      message = 'No completed goals yet.\nKeep working on your goals!';
      icon = Icons.timelapse;
      action = OutlinedButton(
        onPressed: _resetFilter,
        child: const Text('Show All'),
      );
    } else {
      message = 'No goals yet!\nStart your fitness journey by creating a goal.';
      icon = Icons.flag;
      action = Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _showGoalTemplateSelector(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Goal'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Dashboard'),
          ),
        ],
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          action,
        ],
      ),
    );
  }

  void _showGoalTemplateSelector(BuildContext context) {
    final cubit = context.read<GoalsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: GoalTemplateSelector(
          onTemplateSelected: (template) {
            Navigator.of(context).pop();
            _showGoalCreationForm(context, initialGoal: template);
          },
          onCustomGoal: () {
            Navigator.of(context).pop();
            _showGoalCreationForm(context);
          },
        ),
      ),
    );
  }

  void _showGoalCreationForm(BuildContext context, {ActivityGoal? initialGoal}) {
    final cubit = context.read<GoalsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: GoalCreationForm(
          initialGoal: initialGoal,
          onSave: (goal) async {
            await cubit.addGoal(goal);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Goal saved!')),
              );
            }
          },
        ),
      ),
    );
  }
} 
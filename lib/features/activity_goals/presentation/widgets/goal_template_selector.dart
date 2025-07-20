import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/activity_goal.dart';
import '../../logic/cubit/goals_cubit.dart';

class GoalTemplateSelector extends StatefulWidget {
  final void Function(ActivityGoal template) onTemplateSelected;
  final VoidCallback? onCustomGoal;

  const GoalTemplateSelector({
    super.key,
    required this.onTemplateSelected,
    this.onCustomGoal,
  });

  @override
  State<GoalTemplateSelector> createState() => _GoalTemplateSelectorState();
}

class _GoalTemplateSelectorState extends State<GoalTemplateSelector> {
  late Future<List<ActivityGoal>> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<GoalsCubit>();
    _suggestionsFuture = cubit.getGoalSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goal Suggestions', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            FutureBuilder<List<ActivityGoal>>(
              future: _suggestionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final templates = snapshot.data ?? [];
                if (templates.isEmpty) {
                  return Text('No suggestions available.', style: theme.textTheme.bodyMedium);
                }
                return Column(
                  children: templates.map((template) => ListTile(
                    leading: Icon(_getGoalIcon(template), color: theme.colorScheme.primary),
                    title: Text(_getGoalTitle(template)),
                    subtitle: Text(_getGoalSubtitle(template)),
                    onTap: () => widget.onTemplateSelected(template),
                  )).toList(),
                );
              },
            ),
            const Divider(height: 32),
            ListTile(
              leading: Icon(Icons.add, color: theme.colorScheme.primary),
              title: Text('Create Custom Goal'),
              onTap: widget.onCustomGoal,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGoalIcon(ActivityGoal goal) {
    if (goal.unit == 'calories') return Icons.local_fire_department;
    if (goal.unit == 'km' || goal.unit == 'miles') return Icons.directions_run;
    if (goal.unit == 'minutes' || goal.unit == 'hours') return Icons.timer;
    if (goal.tags != null && goal.tags!.contains('trapezius')) return Icons.fitness_center;
    return Icons.flag;
  }

  String _getGoalTitle(ActivityGoal goal) => goal.description ?? 'Goal';

  String _getGoalSubtitle(ActivityGoal goal) {
    if (goal.goalType == GoalType.quantitative) {
      return 'Target: ${goal.targetValue?.toStringAsFixed(0) ?? '-'} ${goal.unit ?? ''}';
    } else {
      return 'Tags: ${goal.tags?.join(', ') ?? '-'}';
    }
  }
} 
/// Step3Goals widget handles the third step of the activity log form: linking goals to the activity and previewing impact.
import 'package:flutter/material.dart';
import '../../../logic/activity_log_form_cubit.dart';
import '../../../../activity_goals/data/models/activity_goal.dart';
import 'package:codealpha_fitness_tracker_app/core/constants/ui_constants.dart';

/// Widget for linking goals and previewing impact in the activity log form.
class Step3Goals extends StatelessWidget {
  final ActivityLogFormState state;
  final ActivityLogFormCubit cubit;
  final List<ActivityGoal> availableGoals;
  const Step3Goals({required this.state, required this.cubit, required this.availableGoals, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select goals to link to this activity:'),
        Wrap(
          spacing: UIConstants.chipSpacing,
          children: availableGoals.map((goal) {
            final isSelected = state.linkedGoals.contains(goal);
            // Determine icon based on goal type/unit
            IconData icon;
            if (goal.unit == 'calories') {
              icon = Icons.local_fire_department;
            } else if (goal.unit == 'km') {
              icon = Icons.directions_run;
            } else if (goal.unit == 'minutes' || goal.unit == 'hours') {
              icon = Icons.timer;
            } else {
              icon = Icons.flag;
            }
            // Calculate impact preview
            String? impact;
            if (goal.unit == 'calories' && state.calories != null && goal.targetValue != null && goal.targetValue! > 0) {
              final percent = ((state.calories! / goal.targetValue!) * 100).clamp(0, 100).toStringAsFixed(0);
              impact = 'Will complete $percent% of this goal';
            } else if (goal.unit == 'km' && state.distance != null && goal.targetValue != null && goal.targetValue! > 0) {
              final percent = ((state.distance! / goal.targetValue!) * 100).clamp(0, 100).toStringAsFixed(0);
              impact = 'Will complete $percent% of this goal';
            } else if ((goal.unit == 'minutes' || goal.unit == 'hours') && state.duration != null && goal.targetValue != null && goal.targetValue! > 0) {
              final percent = ((state.duration! / goal.targetValue!) * 100).clamp(0, 100).toStringAsFixed(0);
              impact = 'Will complete $percent% of this goal';
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterChip(
                  avatar: Icon(icon, size: 18),
                  label: Text(goal.description ?? 'Goal'),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newGoals = List<ActivityGoal>.from(state.linkedGoals);
                    if (selected) {
                      newGoals.add(goal);
                    } else {
                      newGoals.remove(goal);
                    }
                    cubit.linkGoals(newGoals);
                  },
                ),
                if (isSelected && impact != null)
                  Padding(
                    padding: const EdgeInsets.only(left: UIConstants.chipSpacing, bottom: 8),
                    child: Text(impact, style: TextStyle(fontSize: 12, color: Colors.blue)),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
} 
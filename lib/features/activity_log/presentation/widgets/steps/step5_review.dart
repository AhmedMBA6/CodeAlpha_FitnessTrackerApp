/// Step5Review widget handles the final review step of the activity log form, showing a summary and validation feedback.
import 'package:flutter/material.dart';
import '../../../logic/activity_log_form_cubit.dart';
import 'package:codealpha_fitness_tracker_app/core/constants/ui_constants.dart';

/// Widget for reviewing and submitting the activity log form, with validation feedback.
class Step5Review extends StatelessWidget {
  final ActivityLogFormState state;
  final ActivityLogFormCubit cubit;
  const Step5Review({required this.state, required this.cubit, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: UIConstants.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Activity: ${state.selectedType?.name ?? '-'}"),
                if (!cubit.isValidStep1())
                  Text('Please select an activity type.', style: TextStyle(color: Colors.red)),
                Text("Duration: ${state.duration ?? '-'} min"),
                Text("Distance: ${state.distance ?? '-'} km"),
                Text("Calories: ${state.calories ?? '-'}"),
                if (!cubit.isValidStep2())
                  Text('Please enter valid duration and calories.', style: TextStyle(color: Colors.red)),
                Text("Goals: ${state.linkedGoals.map((g) => g.description).join(', ')}"),
                if (!cubit.isValidStep3())
                  Text('Please link at least one goal.', style: TextStyle(color: Colors.red)),
                Text("Tags: ${state.tags.join(', ')}"),
                Text("Notes: ${state.notes ?? '-'}"),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 
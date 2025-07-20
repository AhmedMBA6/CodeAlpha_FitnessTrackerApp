/// Step4Tags widget handles the fourth step of the activity log form: entering tags and notes.
import 'package:flutter/material.dart';
import '../../../logic/activity_log_form_cubit.dart';
import 'package:codealpha_fitness_tracker_app/core/constants/ui_constants.dart';

/// Widget for entering tags and notes in the activity log form.
class Step4Tags extends StatelessWidget {
  final ActivityLogFormState state;
  final ActivityLogFormCubit cubit;
  final List<String> availableTags;
  const Step4Tags({required this.state, required this.cubit, required this.availableTags, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
          onChanged: (v) => cubit.setTagsAndNotes(tags: v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(), notes: state.notes),
        ),
        const SizedBox(height: UIConstants.fieldSpacing),
        TextField(
          decoration: const InputDecoration(labelText: 'Notes (optional)'),
          onChanged: (v) => cubit.setTagsAndNotes(tags: state.tags, notes: v),
        ),
      ],
    );
  }
} 
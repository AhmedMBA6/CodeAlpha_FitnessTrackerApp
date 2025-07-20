/// Step1Type widget handles the first step of the activity log form: selecting the activity type.
import 'package:flutter/material.dart';
import '../../../logic/activity_log_form_cubit.dart';
import 'package:codealpha_fitness_tracker_app/core/constants/ui_constants.dart';


/// Widget for selecting the activity type in the activity log form.
class Step1Type extends StatelessWidget {
  final ActivityLogFormState state;
  final ActivityLogFormCubit cubit;
  const Step1Type({required this.state, required this.cubit, super.key});
  @override
  Widget build(BuildContext context) {
    final typeIcons = {
      ActivityType.run: Icons.directions_run,
      ActivityType.walk: Icons.directions_walk,
      ActivityType.gym: Icons.fitness_center,
      ActivityType.yoga: Icons.self_improvement,
      ActivityType.custom: Icons.star,
    };
    return Wrap(
      spacing: UIConstants.chipSpacing,
      runSpacing: UIConstants.chipSpacing,
      children: ActivityType.values.map((type) {
        final isSelected = state.selectedType == type;
        return Semantics(
          label: type.name,
          selected: isSelected,
          button: true,
          child: Tooltip(
            message: type.name,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 8)]
                    : [],
              ),
              width: 72,
              height: 72,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => cubit.selectActivityType(type),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(typeIcons[type], color: isSelected ? Colors.white : Colors.black, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      type.name[0].toUpperCase() + type.name.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
} 
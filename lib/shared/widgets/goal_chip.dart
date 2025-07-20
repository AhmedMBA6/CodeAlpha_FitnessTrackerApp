import 'package:flutter/material.dart';

class GoalChip extends StatelessWidget {
  final String label;
  final bool completed;
  final String? tooltip;

  const GoalChip({super.key, required this.label, this.completed = false, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label + (completed ? ' (completed)' : ''),
      button: true,
      child: Tooltip(
        message: tooltip ?? label,
        child: Chip(
          label: Text(label),
          backgroundColor: completed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          labelStyle: TextStyle(
            color: completed ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: completed ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';

class ActivityChip extends StatelessWidget {
  final String label;
  final String? tooltip;

  const ActivityChip({super.key, required this.label, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Tooltip(
        message: tooltip ?? label,
        child: Chip(
          label: Text(label),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
} 
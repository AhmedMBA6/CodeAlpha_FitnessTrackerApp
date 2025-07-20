import 'package:flutter/material.dart';

class GoalCompletedDialog extends StatelessWidget {
  final String? goalDescription;
  const GoalCompletedDialog({super.key, this.goalDescription});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Goal Completed!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Colors.green, size: 48),
          const SizedBox(height: 16),
          Text(
            goalDescription ?? 'Congratulations on completing your goal!',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
} 
import 'package:flutter/material.dart';

class ActivityControlButtons extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  const ActivityControlButtons({super.key, required this.isPaused, required this.onPause, required this.onResume, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          iconSize: 48,
          tooltip: isPaused ? 'Resume' : 'Pause',
          onPressed: isPaused ? onResume : onPause,
        ),
        const SizedBox(width: 32),
        IconButton(
          icon: const Icon(Icons.stop),
          iconSize: 48,
          tooltip: 'Finish',
          onPressed: onFinish,
        ),
      ],
    );
  }
} 
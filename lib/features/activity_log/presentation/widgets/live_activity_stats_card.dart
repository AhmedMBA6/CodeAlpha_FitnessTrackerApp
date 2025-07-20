import 'package:flutter/material.dart';
import '../../../../shared/widgets/progress_ring.dart';

class LiveActivityStatsCard extends StatelessWidget {
  final int secondsElapsed;
  final double distance;
  final double calories;
  final String Function(int) formatDuration;
  const LiveActivityStatsCard({super.key, required this.secondsElapsed, required this.distance, required this.calories, required this.formatDuration});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(formatDuration(secondsElapsed), style: Theme.of(context).textTheme.displayMedium),
            const Text('Timer'),
          ],
        ),
        Column(
          children: [
            Text('${distance.toStringAsFixed(2)} km', style: Theme.of(context).textTheme.headlineSmall),
            const Text('Distance'),
          ],
        ),
        Column(
          children: [
            Text('${calories.toStringAsFixed(1)} cal', style: Theme.of(context).textTheme.headlineSmall),
            const Text('Calories'),
          ],
        ),
        ProgressRing(progress: (calories / 100).clamp(0.0, 1.0)),
      ],
    );
  }
} 
import 'package:flutter/material.dart';

class GoalProgressRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double size;
  final Color? color;
  final String? label;

  const GoalProgressRing({
    super.key,
    required this.progress,
    this.size = 48,
    this.color,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = color ?? theme.colorScheme.primary;
    final bgColor = theme.colorScheme.surfaceContainerHighest;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Semantics(
            label: label != null ? 'Goal progress: $label' : 'Goal progress: ${(progress * 100).toStringAsFixed(0)}%',
            value: '${(progress * 100).toStringAsFixed(0)}%',
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 6,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(ringColor),
            ),
          ),
        ),
        if (label != null)
          Text(label!, style: theme.textTheme.labelMedium?.copyWith(color: ringColor)),
        if (label == null)
          Text('${(progress * 100).toStringAsFixed(0)}%', style: theme.textTheme.labelMedium?.copyWith(color: ringColor)),
      ],
    );
  }
} 
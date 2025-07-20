import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double size;

  const ProgressRing({super.key, required this.progress, this.size = 48});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement custom painter or use CircularProgressIndicator
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 6,
      ),
    );
  }
} 
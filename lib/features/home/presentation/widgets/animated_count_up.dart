import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedCountUp extends StatelessWidget {
  final num value;
  final String label;
  const AnimatedCountUp({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<num>(
      tween: Tween<num>(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      builder: (context, val, child) {
        String display = label == 'Distance'
            ? '${val.toStringAsFixed(2)} km'
            : val is int || val == val.roundToDouble()
                ? val.toStringAsFixed(0)
                : val.toStringAsFixed(1);
        return Text(
          display,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        );
      },
    );
  }
} 
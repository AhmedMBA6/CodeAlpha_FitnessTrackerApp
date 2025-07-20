import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final String value;
  const AnimatedProgressRing({super.key, required this.progress, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 10.w,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              SizedBox(height: 2.h),
              Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
} 
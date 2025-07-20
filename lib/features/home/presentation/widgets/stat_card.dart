import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'animated_count_up.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final num value;
  final bool isLoading;
  final VoidCallback onTap;
  final String tooltip;
  const StatCard({super.key, required this.icon, required this.color, required this.label, required this.value, required this.isLoading, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label stat card',
      button: true,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: isLoading ? null : onTap,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            color: color.withValues(alpha: 0.12),
            child: Container(
              width: 90.w,
              padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 32.sp),
                  SizedBox(height: 8.h),
                  isLoading
                      ? SizedBox(height: 22.sp, width: 40.w, child: LinearProgressIndicator(minHeight: 3.h))
                      : AnimatedCountUp(value: value, label: label),
                  SizedBox(height: 2.h),
                  Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
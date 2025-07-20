import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String tooltip;
  final bool enabled;
  const ActionCard({super.key, required this.icon, required this.color, required this.label, required this.onTap, this.onLongPress, required this.tooltip, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label action card',
      button: true,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: enabled ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(18.r),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: enabled ? onTap : null,
            onLongPress: enabled ? onLongPress : null,
            child: Container(
              width: 160.w,
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    radius: 26.r,
                    child: Icon(icon, color: color, size: 32.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';

/// Utility class for proper gesture handling to prevent conflicts
class GestureUtils {
  /// Creates a properly wrapped InkWell widget to prevent gesture conflicts
  static Widget safeInkWell({
    required Widget child,
    required VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: child,
      ),
    );
  }

  /// Creates a safe button that prevents gesture conflicts
  static Widget safeButton({
    required Widget child,
    required VoidCallback? onPressed,
    ButtonStyle? style,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }

  /// Creates a safe icon button that prevents gesture conflicts
  static Widget safeIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
    String? semanticLabel,
  }) {
    return IconButton(
      icon: Icon(icon, semanticLabel: semanticLabel),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  /// Creates a safe list tile that prevents gesture conflicts
  static Widget safeListTile({
    required Widget leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
} 
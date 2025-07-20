import 'package:flutter/material.dart';
import '../../core/utils/haptic_feedback.dart' as app_haptics;

class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final bool enableHapticFeedback;
  final ButtonStyle? style;
  final bool? isSelected;
  final bool autofocus;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.enableHapticFeedback = true,
    this.style,
    this.isSelected,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      child: Tooltip(
        message: tooltip ?? semanticLabel ?? '',
        child: ElevatedButton(
          onPressed: () {
            if (enableHapticFeedback) {
              app_haptics.HapticFeedback.buttonPress();
            }
            onPressed?.call();
          },
          style: style,
          autofocus: autofocus,
          child: child,
        ),
      ),
    );
  }
}

class AccessibleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String semanticLabel;
  final String? tooltip;
  final bool enableHapticFeedback;
  final Color? color;
  final double? size;

  const AccessibleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.semanticLabel,
    this.tooltip,
    this.enableHapticFeedback = true,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: IconButton(
          onPressed: () {
            if (enableHapticFeedback) {
              app_haptics.HapticFeedback.buttonPress();
            }
            onPressed?.call();
          },
          icon: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}

class AccessibleFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String semanticLabel;
  final String? tooltip;
  final bool enableHapticFeedback;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AccessibleFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.tooltip,
    this.enableHapticFeedback = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: FloatingActionButton(
          onPressed: () {
            if (enableHapticFeedback) {
              app_haptics.HapticFeedback.buttonPress();
            }
            onPressed?.call();
          },
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          child: child,
        ),
      ),
    );
  }
}

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final bool enableHapticFeedback;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final ShapeBorder? shape;

  const AccessibleCard({
    super.key,
    required this.child,
    this.semanticLabel,
    this.onTap,
    this.enableHapticFeedback = true,
    this.color,
    this.margin,
    this.padding,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      color: color,
      margin: margin,
      elevation: elevation,
      shape: shape,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: () {
          if (enableHapticFeedback) {
            app_haptics.HapticFeedback.buttonPress();
          }
          onTap?.call();
        },
        child: card,
      );
    }

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }

    return card;
  }
}

class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? semanticLabel;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final int? maxLength;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.semanticLabel,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? labelText,
      hint: hintText,
      textField: true,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onTap: onTap,
        validator: validator,
        maxLines: maxLines,
        maxLength: maxLength,
      ),
    );
  }
} 
import 'package:flutter/services.dart';

class HapticFeedback {
  static void light() {
    SystemChannels.platform.invokeMethod('HapticFeedback.lightImpact');
  }

  static void medium() {
    SystemChannels.platform.invokeMethod('HapticFeedback.mediumImpact');
  }

  static void heavy() {
    SystemChannels.platform.invokeMethod('HapticFeedback.heavyImpact');
  }

  static void selection() {
    SystemChannels.platform.invokeMethod('HapticFeedback.selectionClick');
  }

  static void success() {
    SystemChannels.platform.invokeMethod('HapticFeedback.notificationImpact', 'success');
  }

  static void warning() {
    SystemChannels.platform.invokeMethod('HapticFeedback.notificationImpact', 'warning');
  }

  static void error() {
    SystemChannels.platform.invokeMethod('HapticFeedback.notificationImpact', 'error');
  }

  static void goalCompleted() {
    // Custom pattern for goal completion
    heavy();
    Future.delayed(const Duration(milliseconds: 100), () {
      success();
    });
  }

  static void mapTap() {
    light();
  }

  static void buttonPress() {
    selection();
  }
} 
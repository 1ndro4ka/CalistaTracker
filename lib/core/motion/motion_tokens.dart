import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class MotionTokens {
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  static const Curve curveAppear = Curves.easeOutCubic;
  static const Curve curveTransition = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.elasticOut;

  static const double pressedScale = 0.97;

  static Duration getDuration(BuildContext context, Duration defaultDuration) {
    if (MediaQuery.of(context).disableAnimations) {
      return Duration.zero;
    }
    return defaultDuration;
  }
}

abstract final class AppFeedback {
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> checkmark() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> uncheck() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> milestone() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }
}

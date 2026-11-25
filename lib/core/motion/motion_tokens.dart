import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class MotionTokens {
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationEntrance = Duration(milliseconds: 420);
  static const Duration durationStaggerStep = Duration(milliseconds: 45);

  static const Curve curveAppear = Curves.easeOutCubic;
  static const Curve curveTransition = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.elasticOut;

  static const double pressedScale = 0.97;
  static const double pressedScaleDeep = 0.94;
  static const double entranceOffset = 0.04;

  /// Соблюдаем системную настройку «уменьшить анимацию».
  static bool reducedMotion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  static Duration getDuration(BuildContext context, Duration defaultDuration) {
    if (reducedMotion(context)) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  /// Задержка для ступенчатого появления элементов списка.
  static Duration staggerDelay(BuildContext context, int index) {
    if (reducedMotion(context)) return Duration.zero;
    return Duration(
      milliseconds: (index.clamp(0, 8) * durationStaggerStep.inMilliseconds),
    );
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

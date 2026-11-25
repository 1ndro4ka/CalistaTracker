import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../router/app_router.dart';

/// Нативный для iOS жест «назад»: свайп от левого края к центру.
/// На Android не включаем, чтобы не конфликтовать с системной кнопкой «назад».
class EdgeBackGesture extends StatefulWidget {
  final Widget child;

  const EdgeBackGesture({super.key, required this.child});

  @override
  State<EdgeBackGesture> createState() => _EdgeBackGestureState();
}

class _EdgeBackGestureState extends State<EdgeBackGesture> {
  static const double _edgeWidth = 24;
  static const double _minDistance = 80;
  static const double _maxVerticalDrift = 60;

  double? _startX;
  double? _startY;
  bool _tracking = false;

  bool get _enabled => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  void _reset() {
    _tracking = false;
    _startX = null;
    _startY = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (!_enabled) return;
        if (event.position.dx <= _edgeWidth) {
          _startX = event.position.dx;
          _startY = event.position.dy;
          _tracking = true;
        }
      },
      onPointerMove: (event) {
        if (!_tracking || _startX == null || _startY == null) return;
        final dx = event.position.dx - _startX!;
        final dy = (event.position.dy - _startY!).abs();
        if (dx >= _minDistance && dy <= _maxVerticalDrift) {
          _reset();
          if (AppRouter.router.canPop()) AppRouter.router.pop();
          return;
        }
        if (dx < -8 || dy > _maxVerticalDrift) _reset();
      },
      onPointerUp: (_) => _reset(),
      onPointerCancel: (_) => _reset(),
      child: widget.child,
    );
  }
}

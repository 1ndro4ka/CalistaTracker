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
  /// Старт в 36..90 px от левого края: системные жесты «назад» Android/iOS
  /// забирают первые ~30 px, поэтому мы с ними не конфликтуем.
  static const double _edgeStart = 36;
  static const double _edgeEnd = 90;
  static const double _minDistance = 80;
  static const double _maxVerticalDrift = 60;

  double? _startX;
  double? _startY;
  bool _tracking = false;

  // Включаем и на Android: системный жест «назад» и свайп приложения
  // не конфликтуют, т.к. мы проверяем canPop() и срабатываем только на
  // горизонтальном движении от самого края экрана.
  bool get _enabled => !kIsWeb;

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
        final x = event.position.dx;
        if (x >= _edgeStart && x <= _edgeEnd) {
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

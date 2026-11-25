import 'package:flutter/material.dart';

/// Убирает клавиатуру при тапе вне поля и при любом скролле.
/// Particularly important on iOS, where the keyboard stays up after leaving a field.
class KeyboardDismisser extends StatelessWidget {
  final Widget child;

  const KeyboardDismisser({super.key, required this.child});

  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _unfocus,
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _unfocus();
          return false;
        },
        child: child,
      ),
    );
  }
}

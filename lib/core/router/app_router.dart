import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion/motion_tokens.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/habits/presentation/screens/habit_form_screen.dart';
import '../../features/habits/presentation/screens/today_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';

abstract final class AppRouter {
  /// Единый «тихий» переход для всех маршрутов: лёгкое проявление + сдвиг вверх.
  static CustomTransitionPage<void> _page(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    final duration = MotionTokens.getDuration(
      context,
      MotionTokens.durationMedium,
    );
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondary, child) {
        if (duration == Duration.zero) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: MotionTokens.curveAppear,
        );
        final offset = Tween<Offset>(
          begin: const Offset(0, MotionTokens.entranceOffset),
          end: Offset.zero,
        ).animate(curved);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: offset, child: child),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'today',
        pageBuilder: (context, state) =>
            _page(context, state, const TodayScreen()),
      ),
      GoRoute(
        path: '/habits/new',
        name: 'habit_new',
        pageBuilder: (context, state) =>
            _page(context, state, const HabitFormScreen()),
      ),
      GoRoute(
        path: '/habits/:id',
        name: 'habit_detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _page(context, state, HabitDetailScreen(habitId: id));
        },
      ),
      GoRoute(
        path: '/habits/:id/edit',
        name: 'habit_edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          return _page(context, state, HabitFormScreen(habitId: id));
        },
      ),
      GoRoute(
        path: '/stats',
        name: 'stats',
        pageBuilder: (context, state) =>
            _page(context, state, const StatsScreen()),
      ),
    ],
  );
}

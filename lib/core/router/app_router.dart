import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/habits/presentation/screens/habit_form_screen.dart';
import '../../features/habits/presentation/screens/today_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'today',
        builder: (BuildContext context, GoRouterState state) =>
            const TodayScreen(),
      ),
      GoRoute(
        path: '/habits/new',
        name: 'habit_new',
        builder: (BuildContext context, GoRouterState state) =>
            const HabitFormScreen(),
      ),
      GoRoute(
        path: '/habits/:id',
        name: 'habit_detail',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return HabitDetailScreen(habitId: id);
        },
      ),
      GoRoute(
        path: '/habits/:id/edit',
        name: 'habit_edit',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'];
          return HabitFormScreen(habitId: id);
        },
      ),
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (BuildContext context, GoRouterState state) =>
            const StatsScreen(),
      ),
    ],
  );
}

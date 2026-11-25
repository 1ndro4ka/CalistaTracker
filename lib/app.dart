import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/reminders/presentation/providers/reminder_providers.dart';

class CalistaApp extends ConsumerStatefulWidget {
  const CalistaApp({super.key});

  @override
  ConsumerState<CalistaApp> createState() => _CalistaAppState();
}

class _CalistaAppState extends ConsumerState<CalistaApp> {
  StreamSubscription<String>? _notificationTapSubscription;

  @override
  void initState() {
    super.initState();

    final scheduler = ref.read(reminderSchedulerProvider);
    _notificationTapSubscription = scheduler.habitTapStream.listen(_openHabit);

    // Холодный старт: приложение открыто нажатием по уведомлению.
    final initialPayload = scheduler.consumeInitialPayload();
    if (initialPayload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openHabit(initialPayload);
      });
    }
  }

  @override
  void dispose() {
    _notificationTapSubscription?.cancel();
    super.dispose();
  }

  void _openHabit(String habitId) {
    if (!mounted || habitId.isEmpty) return;
    AppRouter.router.push('/habits/$habitId');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}

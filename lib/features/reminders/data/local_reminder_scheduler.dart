import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/constants/app_constants.dart';
import '../../habits/domain/entities/habit.dart';
import '../../habits/domain/entities/habit_schedule.dart';
import '../domain/entities/reminder_time.dart';
import '../domain/services/reminder_scheduler.dart';

/// Фоновый обработчик нажатий. Навигацию выполняет основной isolate;
/// здесь достаточно того, что плагин получает callback.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

/// Реализация [ReminderScheduler] поверх `flutter_local_notifications`.
///
/// Особенности:
/// * Android 13+ — запрос `POST_NOTIFICATIONS`;
/// * Android 12+ — запрос `SCHEDULE_EXACT_ALARM` с деградацией до
///   `inexactAllowWhileIdle`, если точные будильники запрещены;
/// * iOS — `requestPermissions`;
/// * после перезагрузки Android восстанавливает расписание через
///   `ScheduledNotificationBootReceiver` (см. AndroidManifest.xml), а
///   `syncAll` дополнительно пересоздаёт его при запуске приложения;
/// * нажатие по уведомлению отдаёт `habitId` в [habitTapStream].
class LocalReminderScheduler implements ReminderScheduler {
  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<String> _tapController =
      StreamController<String>.broadcast();

  bool _initialized = false;
  bool _available = false;
  String? _initialPayload;

  LocalReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool get _isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Stream<String> get habitTapStream => _tapController.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!_isMobile) {
      // На desktop/web напоминания не являются целевым сценарием.
      _available = false;
      return;
    }

    try {
      tz_data.initializeTimeZones();
      try {
        final localTimezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
      } catch (error) {
        // Часовой пояс устройства недоступен — остаёмся в UTC, но не падаем.
        debugPrint('Calista: не удалось определить часовой пояс: $error');
      }

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            _tapController.add(payload);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      final android = _androidPlugin;
      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            description: AppConstants.notificationChannelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
      }

      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          _initialPayload = payload;
        }
      }

      _available = true;
    } catch (error) {
      _available = false;
      debugPrint('Calista: напоминания недоступны ($error)');
    }
  }

  @override
  String? consumeInitialPayload() {
    final payload = _initialPayload;
    _initialPayload = null;
    return payload;
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();
    if (!_available) return true; // no-op платформа — не блокируем UX

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _androidPlugin;
        final notificationsGranted =
            await android?.requestNotificationsPermission() ?? true;
        // Точные будильники: если пользователь откажет, планировщик
        // автоматически использует inexact-режим.
        await android?.requestExactAlarmsPermission();
        return notificationsGranted;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (error) {
      debugPrint('Calista: ошибка запроса разрешений: $error');
    }
    return false;
  }

  @override
  Future<void> syncHabitReminder(Habit habit) async {
    await initialize();
    // Сначала всегда снимаем старое расписание: привычка могла быть
    // отредактирована, и старые ID больше не актуальны.
    await cancelHabitReminder(habit.id);

    if (!_available || habit.isArchived) return;
    final time = ReminderTime.tryParse(habit.reminderTime);
    if (time == null) return;

    try {
      final baseId = _baseNotificationId(habit.id);
      final details = _notificationDetails;

      if (habit.schedule.type == ScheduleType.everyDay) {
        await _schedule(
          id: baseId,
          time: time,
          habit: habit,
          details: details,
          matchComponents: DateTimeComponents.time,
        );
        return;
      }

      final days = habit.schedule.daysOfWeek.toSet().toList()..sort();
      for (final weekday in days) {
        await _schedule(
          id: baseId + weekday,
          time: time,
          habit: habit,
          details: details,
          weekday: weekday,
          matchComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (error) {
      debugPrint('Calista: не удалось запланировать напоминание: $error');
    }
  }

  @override
  Future<void> cancelHabitReminder(String habitId) async {
    await initialize();
    if (!_available) return;

    final baseId = _baseNotificationId(habitId);
    for (var weekday = 0; weekday <= 7; weekday++) {
      try {
        await _plugin.cancel(id: baseId + weekday);
      } catch (error) {
        debugPrint('Calista: ошибка отмены уведомления: $error');
      }
    }
  }

  @override
  Future<void> syncAll(List<Habit> habits) async {
    await initialize();
    if (!_available) return;

    final expectedIds = <int>{};
    for (final habit in habits) {
      if (habit.isArchived ||
          ReminderTime.tryParse(habit.reminderTime) == null) {
        continue;
      }
      final baseId = _baseNotificationId(habit.id);
      if (habit.schedule.type == ScheduleType.everyDay) {
        expectedIds.add(baseId);
      } else {
        for (final weekday in habit.schedule.daysOfWeek) {
          expectedIds.add(baseId + weekday);
        }
      }
      await syncHabitReminder(habit);
    }

    // Убираем «осиротевшие» уведомления удалённых привычек.
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final request in pending) {
        if (!expectedIds.contains(request.id)) {
          await _plugin.cancel(id: request.id);
        }
      }
    } catch (error) {
      debugPrint('Calista: не удалось очистить старые уведомления: $error');
    }
  }

  /// ID тестового уведомления не пересекается с ID привычек (те < 1e9).
  static const int _testNotificationId = 0x7ffffff0;

  @override
  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    await initialize();
    if (!_available) return;
    await _plugin.show(
      id: _testNotificationId,
      title: title,
      body: body,
      payload: null,
    );
  }

  @override
  Future<void> scheduleTestNotification({
    required Duration delay,
    required String title,
    required String body,
  }) async {
    await initialize();
    if (!_available) return;
    await _plugin.zonedSchedule(
      id: _testNotificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: _notificationDetails,
      androidScheduleMode: await _resolveScheduleMode(),
    );
  }

  @override
  Future<void> cancelTestNotification() async {
    await initialize();
    if (!_available) return;
    await _plugin.cancel(id: _testNotificationId);
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  NotificationDetails get _notificationDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
      presentBadge: true,
    ),
  );

  Future<void> _schedule({
    required int id,
    required ReminderTime time,
    required Habit habit,
    required NotificationDetails details,
    required DateTimeComponents matchComponents,
    int? weekday,
  }) async {
    final scheduledDate = _nextInstance(time, weekday: weekday);
    final scheduleMode = await _resolveScheduleMode();

    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: scheduleMode,
      title: 'Пора: ${habit.title}',
      body: habit.description.isNotEmpty
          ? habit.description
          : 'Отметьте привычку, чтобы сохранить серию.',
      payload: habit.id,
      matchDateTimeComponents: matchComponents,
    );
  }

  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    try {
      final canExact = await _androidPlugin?.canScheduleExactNotifications();
      return canExact ?? false
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (_) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  /// Следующее наступление времени [time]. Если [weekday] задан, дата
  /// сдвигается до ближайшего соответствующего дня недели.
  tz.TZDateTime _nextInstance(ReminderTime time, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    if (weekday != null) {
      while (candidate.weekday != weekday) {
        candidate = candidate.add(const Duration(days: 1));
      }
    }
    return candidate;
  }

  /// Стабильный (не зависящий от hashCode процесса) ID для AlarmManager.
  /// Диапазон: [0, 1_000_000_000), плюс день недели 0..7.
  int _baseNotificationId(String habitId) {
    var hash = 0x811c9dc5;
    for (final codeUnit in habitId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return (hash % 100000000) * 10;
  }
}

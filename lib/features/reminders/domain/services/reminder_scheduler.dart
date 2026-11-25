import '../../../habits/domain/entities/habit.dart';

/// Контракт планировщика локальных напоминаний.
///
/// Домен и presentation не зависят от `flutter_local_notifications`: любую
/// реализацию можно подменить в тестах или на неподдерживаемой платформе.
abstract interface class ReminderScheduler {
  /// Инициализирует плагин, часовой пояс и канал уведомлений.
  Future<void> initialize();

  /// Запрашивает разрешения (Android 13+ / iOS). Возвращает `true`, если
  /// уведомления разрешены пользователем.
  Future<bool> requestPermissions();

  /// Только разрешение на уведомления — без перехода в настройки точных будильников.
  /// Используется секретной панелью для тестовых уведомлений.
  Future<bool> requestNotificationPermission();

  /// Полностью пересоздаёт расписание для одной привычки.
  Future<void> syncHabitReminder(Habit habit);

  /// Снимает все запланированные напоминания привычки.
  Future<void> cancelHabitReminder(String habitId);

  /// Пересоздаёт расписание для списка привычек (например, после перезапуска).
  Future<void> syncAll(List<Habit> habits);

  /// Payload'ы (ID привычек) из нажатий по уведомлению, пока приложение живо.
  Stream<String> get habitTapStream;

  /// Payload уведомления, которое запустило приложение (холодный старт).
  /// Возвращает значение один раз.
  String? consumeInitialPayload();

  /// Показать тестовое уведомление немедленно (секретная панель).
  Future<void> showTestNotification({
    required String title,
    required String body,
  });

  /// Запланировать тестовое уведомление через [delay] (секретная панель).
  Future<void> scheduleTestNotification({
    required Duration delay,
    required String title,
    required String body,
  });

  /// Отменить запланированное тестовое уведомление.
  Future<void> cancelTestNotification();
}

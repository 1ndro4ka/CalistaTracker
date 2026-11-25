import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_reminder_scheduler.dart';
import '../../domain/services/reminder_scheduler.dart';

/// Единственный экземпляр планировщика на всё приложение: он хранит
/// подписку на нажатия и состояние инициализации плагина.
final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return LocalReminderScheduler();
});

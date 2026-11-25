import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/clock_provider.dart';
import '../../../../core/utils/clock.dart';
import '../../../habits/presentation/providers/database_provider.dart';
import '../../../habits/presentation/providers/habits_provider.dart';
import '../../../reminders/presentation/providers/reminder_providers.dart';
import '../../domain/usecases/seed_demo_data_use_case.dart';
import '../../domain/usecases/simulate_missed_days_use_case.dart';

final seedDemoDataUseCaseProvider = Provider<SeedDemoDataUseCase>((ref) {
  return SeedDemoDataUseCase(
    habitRepository: ref.watch(habitRepositoryProvider),
    completionRepository: ref.watch(completionRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

final simulateMissedDaysUseCaseProvider = Provider<SimulateMissedDaysUseCase>((
  ref,
) {
  return SimulateMissedDaysUseCase(
    habitRepository: ref.watch(habitRepositoryProvider),
    completionRepository: ref.watch(completionRepositoryProvider),
    autoFreezeUseCase: ref.watch(applyAutoFreezeUseCaseProvider),
    clock: ref.watch(clockProvider),
  );
});

/// Оркестратор секретной панели: действия → доменные use case → перезагрузка UI.
final devPanelControllerProvider = Provider<DevPanelController>((ref) {
  return DevPanelController(ref);
});

class DevPanelController {
  DevPanelController(this._ref);

  final Ref _ref;

  FixedClock get _clock => _ref.read(clockProvider);

  Future<int> seedDemoData() async {
    final created = await _ref.read(seedDemoDataUseCaseProvider).execute();
    await _reloadHabits();
    await _resyncReminders();
    return created;
  }

  Future<int> simulateMissedDays(String habitId, int days) async {
    final freezes = await _ref
        .read(simulateMissedDaysUseCaseProvider)
        .execute(habitId, days);
    await _reloadHabits();
    return freezes;
  }

  /// Меняет виртуальное «сегодня», сохраняя время суток.
  Future<void> setDate(DateTime date) async {
    final current = _clock.now();
    _clock.setTime(
      DateTime(
        date.year,
        date.month,
        date.day,
        current.hour,
        current.minute,
        current.second,
      ),
    );
    await _reloadHabits();
  }

  Future<void> shiftDays(int days) =>
      setDate(_clock.now().add(Duration(days: days)));

  Future<void> resetDate() async {
    _clock.reset();
    await _reloadHabits();
  }

  Future<void> showNotificationNow() async {
    final scheduler = _ref.read(reminderSchedulerProvider);
    await scheduler.requestNotificationPermission();
    await scheduler.showTestNotification(
      title: 'ТЕСТ: Calista Tracker',
      body: 'Уведомление сработало сразу. Панель тестов работает.',
    );
  }

  Future<void> scheduleNotification(Duration delay) async {
    final scheduler = _ref.read(reminderSchedulerProvider);
    await scheduler.requestNotificationPermission();
    await scheduler.scheduleTestNotification(
      delay: delay,
      title: 'ТЕСТ: таймер',
      body: 'Прошло ${delay.inSeconds} с. Нажмите, чтобы открыть приложение.',
    );
  }

  Future<void> cancelNotification() async {
    await _ref.read(reminderSchedulerProvider).cancelTestNotification();
  }

  Future<void> _reloadHabits() async {
    await _ref.read(habitsProvider.notifier).reload();
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  Future<void> _resyncReminders() async {
    try {
      final habits = _ref.read(habitsProvider).value ?? const [];
      await _ref
          .read(reminderSchedulerProvider)
          .syncAll(habits.map((item) => item.habit).toList());
    } catch (_) {
      // На desktop/web планировщик недоступен — это не мешает тестам UI.
    }
  }
}

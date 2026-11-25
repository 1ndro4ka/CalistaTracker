import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/habits/domain/entities/habit.dart';
import '../../features/habits/presentation/providers/database_provider.dart';
import '../../features/reminders/presentation/providers/reminder_providers.dart';

/// Инициализация «долгих» сервисов до первого кадра:
/// * плагин локальных уведомлений и часовой пояс;
/// * материализация автозаморозок пропущенных дней;
/// * восстановление расписания напоминаний (в дополнение к Android
///   boot-receiver'у, который перепланирует будильники после перезагрузки).
///
/// Любой сбой здесь не должен мешать запуску приложения — данные и UI важнее.
abstract final class AppBootstrap {
  static Future<void> run(ProviderContainer container) async {
    final scheduler = container.read(reminderSchedulerProvider);
    try {
      await scheduler.initialize();
    } catch (error) {
      debugPrint('Calista: не удалось инициализировать уведомления: $error');
    }

    List<Habit> habits = const [];
    try {
      habits = await _applyAutoFreezes(container);
    } catch (error) {
      debugPrint('Calista: ошибка автозаморозки при запуске: $error');
    }

    try {
      await scheduler.syncAll(habits);
    } catch (error) {
      debugPrint('Calista: не удалось восстановить расписание: $error');
    }
  }

  static Future<List<Habit>> _applyAutoFreezes(
    ProviderContainer container,
  ) async {
    final habitRepository = container.read(habitRepositoryProvider);
    final completionRepository = container.read(completionRepositoryProvider);
    final autoFreezeUseCase = container.read(applyAutoFreezeUseCaseProvider);

    final habits = await habitRepository.getAllHabits(includeArchived: false);
    for (final habit in habits) {
      final completions = await completionRepository.getCompletionsForHabit(
        habit.id,
      );
      await autoFreezeUseCase.execute(habit, completions);
    }
    return habits;
  }
}

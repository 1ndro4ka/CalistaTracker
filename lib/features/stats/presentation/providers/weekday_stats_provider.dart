import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/clock_provider.dart';
import '../../../habits/domain/entities/freeze_policy.dart';
import '../../../habits/presentation/providers/database_provider.dart';

class WeekdayHabitDetail {
  final String title;
  final int scheduled;
  final int completed;
  final int frozen;

  const WeekdayHabitDetail({
    required this.title,
    required this.scheduled,
    required this.completed,
    required this.frozen,
  });

  double get rate => scheduled == 0 ? 0 : completed / scheduled;
}

class WeekdayStat {
  /// 1 = понедельник ... 7 = воскресенье.
  final int weekday;
  final String label;
  final int scheduled;
  final int completed;
  final int frozen;
  final List<WeekdayHabitDetail> habits;

  const WeekdayStat({
    required this.weekday,
    required this.label,
    required this.scheduled,
    required this.completed,
    required this.frozen,
    required this.habits,
  });

  double get rate => scheduled == 0 ? 0 : completed / scheduled;
}

/// Реальная статистика по дням недели за текущий месяц.
final weekdayStatsProvider = FutureProvider<List<WeekdayStat>>((ref) async {
  final habitRepo = ref.watch(habitRepositoryProvider);
  final completionRepo = ref.watch(completionRepositoryProvider);
  final now = ref.watch(clockProvider).now();

  final firstDay = DateTime(now.year, now.month, 1);
  final lastDay = DateTime(now.year, now.month + 1, 0);

  final habits = await habitRepo.getAllHabits();
  final perDay = List.generate(7, (_) => <String, WeekdayHabitDetail>{});

  for (final habit in habits) {
    final completions = await completionRepo.getCompletionsByDateRange(
      habit.id,
      firstDay,
      lastDay,
    );
    final byDate = <DateTime, bool>{
      for (final completion in completions)
        FreezePolicy.normalize(completion.date): !completion.isFrozen,
    };

    var day = firstDay;
    while (!day.isAfter(lastDay)) {
      if (habit.schedule.isScheduledFor(day)) {
        final index = day.weekday - 1;
        final isCompleted = byDate[day] ?? false;
        final isFrozen = byDate.containsKey(day) && !isCompleted;
        final current =
            perDay[index][habit.id] ??
            WeekdayHabitDetail(
              title: habit.title,
              scheduled: 0,
              completed: 0,
              frozen: 0,
            );
        perDay[index][habit.id] = WeekdayHabitDetail(
          title: habit.title,
          scheduled: current.scheduled + 1,
          completed: current.completed + (isCompleted ? 1 : 0),
          frozen: current.frozen + (isFrozen ? 1 : 0),
        );
      }
      day = day.add(const Duration(days: 1));
    }
  }

  const labels = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
  return List.generate(7, (index) {
    final details = perDay[index].values.toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    return WeekdayStat(
      weekday: index + 1,
      label: labels[index],
      scheduled: details.fold(0, (sum, item) => sum + item.scheduled),
      completed: details.fold(0, (sum, item) => sum + item.completed),
      frozen: details.fold(0, (sum, item) => sum + item.frozen),
      habits: details,
    );
  });
});

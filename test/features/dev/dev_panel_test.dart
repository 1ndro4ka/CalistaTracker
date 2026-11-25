import 'package:flutter_test/flutter_test.dart';

import 'package:calista_tracker/core/utils/clock.dart';
import 'package:calista_tracker/features/dev/domain/usecases/seed_demo_data_use_case.dart';
import 'package:calista_tracker/features/dev/domain/usecases/simulate_missed_days_use_case.dart';
import 'package:calista_tracker/features/habits/domain/entities/freeze_policy.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_completion.dart';
import 'package:calista_tracker/features/habits/domain/repositories/completion_repository.dart';
import 'package:calista_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:calista_tracker/features/habits/domain/usecases/apply_auto_freeze_use_case.dart';

class _Habits implements HabitRepository {
  final Map<String, Habit> items = {};

  @override
  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async =>
      items.values.toList();

  @override
  Future<Habit?> getHabitById(String id) async => items[id];

  @override
  Future<void> saveHabit(Habit habit) async => items[habit.id] = habit;

  @override
  Future<void> deleteHabit(String id) async => items.remove(id);
}

class _Completions implements CompletionRepository {
  final List<HabitCompletion> items = [];

  @override
  Future<void> addCompletion(HabitCompletion completion) async {
    items.removeWhere(
      (item) =>
          item.habitId == completion.habitId &&
          FreezePolicy.normalize(item.date) ==
              FreezePolicy.normalize(completion.date),
    );
    items.add(completion);
  }

  @override
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async =>
      items.where((item) => item.habitId == habitId).toList();

  @override
  Future<List<HabitCompletion>> getCompletionsByDateRange(
    String habitId,
    DateTime from,
    DateTime to,
  ) async => items
      .where(
        (item) =>
            item.habitId == habitId &&
            !FreezePolicy.normalize(item.date)
                .isBefore(FreezePolicy.normalize(from)) &&
            !FreezePolicy.normalize(item.date)
                .isAfter(FreezePolicy.normalize(to)),
      )
      .toList();

  @override
  Future<void> removeCompletion(String habitId, DateTime date) async {
    items.removeWhere(
      (item) =>
          item.habitId == habitId &&
          FreezePolicy.normalize(item.date) == FreezePolicy.normalize(date),
    );
  }

  @override
  Future<void> removeCompletionsForHabit(String habitId) async =>
      items.removeWhere((item) => item.habitId == habitId);
}

void main() {
  final clock = FixedClock(DateTime(2026, 11, 25, 9));
  late _Habits habits;
  late _Completions completions;
  late SeedDemoDataUseCase seed;
  late SimulateMissedDaysUseCase simulate;

  setUp(() {
    habits = _Habits();
    completions = _Completions();
    seed = SeedDemoDataUseCase(
      habitRepository: habits,
      completionRepository: completions,
      clock: clock,
    );
    simulate = SimulateMissedDaysUseCase(
      habitRepository: habits,
      completionRepository: completions,
      autoFreezeUseCase: ApplyAutoFreezeUseCase(
        completionRepository: completions,
        clock: clock,
      ),
      clock: clock,
    );
  });

  test('Демо-данные создаются один раз и не дублируются', () async {
    final first = await seed.execute();
    final second = await seed.execute();

    expect(first, 3);
    expect(second, 0);
    expect(habits.items.length, 3);
    expect(completions.items.length, greaterThan(20));
  });

  test('Симуляция пропуска превращает вчерашний день в заморозку', () async {
    await seed.execute();
    final yesterday = clock.now().subtract(const Duration(days: 1));

    final freezes = await simulate.execute('demo_morning', 1);
    final yesterdayCompletion = completions.items.firstWhere(
      (item) =>
          item.habitId == 'demo_morning' &&
          FreezePolicy.normalize(item.date) ==
              FreezePolicy.normalize(yesterday),
    );

    expect(freezes, greaterThanOrEqualTo(1));
    expect(yesterdayCompletion.isFrozen, isTrue);
  });
}

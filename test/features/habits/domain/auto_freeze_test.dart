import 'package:flutter_test/flutter_test.dart';

import 'package:calista_tracker/core/utils/clock.dart';
import 'package:calista_tracker/features/habits/domain/entities/freeze_policy.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_completion.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_schedule.dart';
import 'package:calista_tracker/features/habits/domain/repositories/completion_repository.dart';
import 'package:calista_tracker/features/habits/domain/usecases/apply_auto_freeze_use_case.dart';

class InMemoryCompletionRepository implements CompletionRepository {
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
  Future<List<HabitCompletion>> getCompletionsByDateRange(
    String habitId,
    DateTime from,
    DateTime to,
  ) async {
    final normalizedFrom = FreezePolicy.normalize(from);
    final normalizedTo = FreezePolicy.normalize(to);
    return items
        .where(
          (item) =>
              item.habitId == habitId &&
              !FreezePolicy.normalize(item.date).isBefore(normalizedFrom) &&
              !FreezePolicy.normalize(item.date).isAfter(normalizedTo),
        )
        .toList();
  }

  @override
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    return items.where((item) => item.habitId == habitId).toList();
  }

  @override
  Future<void> removeCompletion(String habitId, DateTime date) async {
    items.removeWhere(
      (item) =>
          item.habitId == habitId &&
          FreezePolicy.normalize(item.date) == FreezePolicy.normalize(date),
    );
  }

  @override
  Future<void> removeCompletionsForHabit(String habitId) async {
    items.removeWhere((item) => item.habitId == habitId);
  }
}

void main() {
  late InMemoryCompletionRepository repository;
  late ApplyAutoFreezeUseCase useCase;
  late FixedClock clock;
  final today = DateTime(2026, 11, 25); // Wednesday

  setUp(() {
    repository = InMemoryCompletionRepository();
    clock = FixedClock(today);
    useCase = ApplyAutoFreezeUseCase(
      completionRepository: repository,
      clock: clock,
    );
  });

  Habit habit({
    String id = 'habit_freeze',
    HabitSchedule schedule = const HabitSchedule.everyDay(),
    int monthlyFreezes = 2,
    bool isArchived = false,
  }) {
    return Habit(
      id: id,
      title: 'Гибкая серия',
      schedule: schedule,
      createdAt: DateTime(2026, 11, 1),
      monthlyFreezesAllowed: monthlyFreezes,
      isArchived: isArchived,
    );
  }

  group('FreezePolicy', () {
    test('1. Разрешает заморозку, пока месячная квота не исчерпана', () {
      const policy = FreezePolicy(monthlyAllowance: 2);

      expect(policy.canFreeze(0), isTrue);
      expect(policy.canFreeze(1), isTrue);
      expect(policy.canFreeze(2), isFalse);
      expect(policy.remainingAfter(1), 1);
      expect(policy.remainingAfter(5), 0);
    });

    test('2. Формирует стабильный ключ месяца и нормализует дату', () {
      expect(FreezePolicy.monthKey(DateTime(2026, 1, 9, 23, 59)), '2026-01');
      expect(
        FreezePolicy.normalize(DateTime(2026, 11, 25, 18, 30)),
        DateTime(2026, 11, 25),
      );
    });
  });

  group('ApplyAutoFreezeUseCase', () {
    test('3. Замораживает пропущенные дни, но никогда — сегодняшний', () async {
      final result = await useCase.execute(habit(), []);

      expect(result.createdFreezes, hasLength(2));
      expect(
        result.createdFreezes.map((c) => c.date),
        containsAll([DateTime(2026, 11, 24), DateTime(2026, 11, 23)]),
      );
      expect(
        result.createdFreezes.every((c) => c.isFrozen),
        isTrue,
        reason: 'Все автоматические записи должны быть заморозками',
      );
      expect(
        repository.items.any((c) => c.date == today),
        isFalse,
        reason: 'Сегодня ещё не закончилось',
      );
    });

    test(
      '4. Не создаёт больше заморозок, чем позволяет месячная квота',
      () async {
        final result = await useCase.execute(habit(monthlyFreezes: 2), []);

        expect(result.createdFreezes, hasLength(2));
        expect(repository.items.where((c) => c.isFrozen), hasLength(2));
      },
    );

    test('5. Повторный запуск идемпотентен', () async {
      final first = await useCase.execute(habit(), []);
      final second = await useCase.execute(habit(), repository.items);

      expect(first.createdFreezes, hasLength(2));
      expect(second.createdFreezes, isEmpty);
      expect(repository.items.where((c) => c.isFrozen), hasLength(2));
    });

    test('6. Учитывает уже существующие заморозки в квоте', () async {
      await repository.addCompletion(
        HabitCompletion(
          id: 'existing_freeze',
          habitId: 'habit_freeze',
          date: DateTime(2026, 11, 20),
          isFrozen: true,
          recordedAt: today,
        ),
      );

      final result = await useCase.execute(habit(), repository.items);

      expect(result.createdFreezes, hasLength(1));
      expect(result.createdFreezes.single.date, DateTime(2026, 11, 24));
    });

    test(
      '7. Останавливается на первом разрыве, когда квота исчерпана',
      () async {
        // 21.11 выполнено, далее 22–24 пропущены. Квота = 2, поэтому
        // замораживаются только 24 и 23, а 22 уже разрывает цепочку.
        await repository.addCompletion(
          HabitCompletion(
            id: 'completed_21',
            habitId: 'habit_freeze',
            date: DateTime(2026, 11, 21),
            recordedAt: DateTime(2026, 11, 21),
          ),
        );

        final result = await useCase.execute(habit(), repository.items);

        expect(result.createdFreezes, hasLength(2));
        expect(
          result.createdFreezes.map((c) => c.date),
          containsAll([DateTime(2026, 11, 24), DateTime(2026, 11, 23)]),
        );
        expect(
          result.createdFreezes.any((c) => c.date == DateTime(2026, 11, 22)),
          isFalse,
        );
      },
    );

    test('8. Не трогает дни вне расписания привычки', () async {
      final weekdaysOnly = habit(
        schedule: const HabitSchedule.specificDays([1, 2, 3, 4, 5]),
      );

      final result = await useCase.execute(weekdaysOnly, []);

      // 24.11 — вторник, 23.11 — понедельник, 22–21 — выходные.
      expect(result.createdFreezes, hasLength(2));
      expect(
        result.createdFreezes.map((c) => c.date.weekday),
        everyElement(inInclusiveRange(1, 5)),
      );
      expect(
        result.createdFreezes.any((c) => c.date == DateTime(2026, 11, 22)),
        isFalse,
      );
    });

    test('9. Не замораживает дни архивированной привычки', () async {
      final result = await useCase.execute(habit(isArchived: true), const []);

      expect(result.createdFreezes, isEmpty);
      expect(repository.items, isEmpty);
    });

    test('10. Уважает переданную дату вместо системных часов', () async {
      final result = await useCase.execute(
        habit(),
        [],
        currentDate: DateTime(2026, 12, 1),
      );

      expect(result.createdFreezes, hasLength(2));
      expect(
        result.createdFreezes.map((c) => c.date.month),
        everyElement(11),
        reason: '30.11 и 29.11 должны быть заморожены в ноябре',
      );
    });
  });
}

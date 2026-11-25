import 'package:flutter_test/flutter_test.dart';
import 'package:calista_tracker/core/utils/clock.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_completion.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_schedule.dart';
import 'package:calista_tracker/features/habits/domain/usecases/calculate_streak_use_case.dart';

void main() {
  late CalculateStreakUseCase useCase;
  late FixedClock clock;
  final baseDate = DateTime(2026, 11, 25); // Wednesday

  setUp(() {
    clock = FixedClock(baseDate);
    useCase = CalculateStreakUseCase(clock: clock);
  });

  Habit createHabit({
    String id = 'habit_1',
    DateTime? createdAt,
    HabitSchedule schedule = const HabitSchedule.everyDay(),
    int monthlyFreezes = 2,
  }) {
    return Habit(
      id: id,
      title: 'Тестовая привычка',
      schedule: schedule,
      createdAt: createdAt ?? DateTime(2026, 10, 1),
      monthlyFreezesAllowed: monthlyFreezes,
    );
  }

  HabitCompletion createCompletion({
    String habitId = 'habit_1',
    required DateTime date,
    bool isFrozen = false,
  }) {
    return HabitCompletion(
      id: 'c_${date.millisecondsSinceEpoch}',
      habitId: habitId,
      date: date,
      isFrozen: isFrozen,
      recordedAt: date,
    );
  }

  group('CalculateStreakUseCase', () {
    test('1. Возвращает 0 при пустой истории и отсутствии отметки сегодня', () {
      final habit = createHabit();
      final streak = useCase.execute(habit, []);

      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.freezesRemaining, 2);
      expect(streak.freezesUsedThisMonth, 0);
      expect(streak.lastCompletedDate, isNull);
    });

    test('2. Возвращает серию 1 при выполнении только сегодня', () {
      final habit = createHabit();
      final completions = [createCompletion(date: baseDate)];

      final streak = useCase.execute(habit, completions);

      expect(streak.currentStreak, 1);
      expect(streak.longestStreak, 1);
      expect(streak.lastCompletedDate, baseDate);
    });

    test('3. Корректно считает непрерывную серию из 7 дней без пропусков', () {
      final habit = createHabit();
      final completions = List.generate(
        7,
        (i) => createCompletion(date: baseDate.subtract(Duration(days: i))),
      );

      final streak = useCase.execute(habit, completions);

      expect(streak.currentStreak, 7);
      expect(streak.longestStreak, 7);
      expect(streak.freezesUsedThisMonth, 0);
      expect(streak.freezesRemaining, 2);
    });

    test('4. Сохраняет серию при 1 пропущенном дне за счет автозаморозки (Streak Freeze)', () {
      final habit = createHabit();
      // Выполнено: сегодня (25.11), 23.11, 22.11, 21.11. Вчера (24.11) пропущено!
      final completions = [
        createCompletion(date: baseDate), // 25.11
        // 24.11 ПРОПУСК
        createCompletion(
          date: baseDate.subtract(const Duration(days: 2)),
        ), // 23.11
        createCompletion(
          date: baseDate.subtract(const Duration(days: 3)),
        ), // 22.11
        createCompletion(
          date: baseDate.subtract(const Duration(days: 4)),
        ), // 21.11
      ];

      final streak = useCase.execute(habit, completions);

      // 4 дня выполнения + 1 замороженный день удерживает цепочку
      expect(streak.currentStreak, 4);
      expect(streak.freezesUsedThisMonth, 1);
      expect(streak.freezesRemaining, 1);
    });

    test(
      '5. Сохраняет серию при 2 пропущенных днях в пределах месячной квоты',
      () {
        final habit = createHabit();
        // Пропуски 24.11 и 22.11 (2 заморозки из 2)
        final completions = [
          createCompletion(date: baseDate), // 25.11
          // 24.11 пропуск (заморозка 1)
          createCompletion(
            date: baseDate.subtract(const Duration(days: 2)),
          ), // 23.11
          // 22.11 пропуск (заморозка 2)
          createCompletion(
            date: baseDate.subtract(const Duration(days: 4)),
          ), // 21.11
          createCompletion(
            date: baseDate.subtract(const Duration(days: 5)),
          ), // 20.11
        ];

        final streak = useCase.execute(habit, completions);

        // 4 дня выполнения (25.11, 23.11, 21.11, 20.11) + 2 замороженных дня
        expect(streak.currentStreak, 4);
        expect(streak.freezesUsedThisMonth, 2);
        expect(streak.freezesRemaining, 0);
      },
    );

    test('6. Обнуляет серию при 3-м пропуске, когда месячный лимит заморозок исчерпан', () {
      final habit = createHabit();
      // Пропуски 24.11, 23.11, 22.11 (лимит только 2)
      final completions = [
        createCompletion(date: baseDate), // 25.11
        // 24.11 пропуск (1)
        // 23.11 пропуск (2)
        // 22.11 пропуск (3 - лимит превышен!)
        createCompletion(
          date: baseDate.subtract(const Duration(days: 4)),
        ), // 21.11
        createCompletion(
          date: baseDate.subtract(const Duration(days: 5)),
        ), // 20.11
      ];

      final streak = useCase.execute(habit, completions);

      // Серия оборвалась на 22.11, учитывается только сегодняшнее выполнение
      expect(streak.currentStreak, 1);
      expect(streak.longestStreak, greaterThanOrEqualTo(2));
    });

    test('7. Квота заморозок обновляется с наступлением нового календарного месяца', () {
      // 1 декабря 2026. В ноябре были потрачены 2 заморозки.
      final decFirst = DateTime(2026, 12, 1);
      clock.setTime(decFirst);

      final habit = createHabit();
      final completions = [
        createCompletion(date: decFirst),
        // В ноябре были заморозки 30.11 и 29.11
        createCompletion(date: DateTime(2026, 11, 30), isFrozen: true),
        createCompletion(date: DateTime(2026, 11, 29), isFrozen: true),
        createCompletion(date: DateTime(2026, 11, 28)),
      ];

      final streak = useCase.execute(habit, completions);

      // В декабре заморозки еще не тратились
      expect(streak.freezesUsedThisMonth, 0);
      expect(streak.freezesRemaining, 2);
      expect(streak.currentStreak, 2);
    });

    test(
      '8. Дни вне расписания (выходные) не ломают серию для привычки по будням',
      () {
        // Привычка только по Пн, Вт, Ср, Чт, Пт (1, 2, 3, 4, 5)
        final habit = createHabit(
          schedule: const HabitSchedule.specificDays([1, 2, 3, 4, 5]),
        );

        // 25.11.2026 - Среда (день 3)
        // Вт (24.11), Пн (23.11), Вс (22.11 - выходной), Сб (21.11 - выходной), Пт (20.11)
        final completions = [
          createCompletion(date: DateTime(2026, 11, 25)), // Ср
          createCompletion(date: DateTime(2026, 11, 24)), // Вт
          createCompletion(date: DateTime(2026, 11, 23)), // Пн
          // Сб и Вс не запланированы
          createCompletion(date: DateTime(2026, 11, 20)), // Пт
        ];

        final streak = useCase.execute(habit, completions);

        expect(streak.currentStreak, 4);
        expect(streak.freezesUsedThisMonth, 0);
      },
    );

    test(
      '9. Невыполненное сегодня не сбрасывает серию, так как день еще идет',
      () {
        final habit = createHabit();
        // Сегодня (25.11) не отмечено. Вчера (24.11) и позавчера (23.11) отмечены.
        final completions = [
          createCompletion(date: DateTime(2026, 11, 24)),
          createCompletion(date: DateTime(2026, 11, 23)),
        ];

        final streak = useCase.execute(habit, completions);

        expect(streak.currentStreak, 2);
        expect(streak.lastCompletedDate, DateTime(2026, 11, 24));
      },
    );

    test('10. Корректно определяет исторический рекорд (longestStreak)', () {
      final habit = createHabit(createdAt: DateTime(2026, 1, 1));
      // В прошлом была серия из 10 дней
      final pastCompletions = List.generate(
        10,
        (i) =>
            createCompletion(date: DateTime(2026, 5, 1).add(Duration(days: i))),
      );
      // Сейчас серия только 2 дня
      final currentCompletions = [
        createCompletion(date: baseDate),
        createCompletion(date: baseDate.subtract(const Duration(days: 1))),
      ];

      final streak = useCase.execute(habit, [
        ...pastCompletions,
        ...currentCompletions,
      ]);

      expect(streak.currentStreak, 2);
      expect(streak.longestStreak, 10);
    });

    test(
      '11. Поддерживает отметку задним числом с мгновенным пересчетом серий',
      () {
        final habit = createHabit();
        final completions = [
          createCompletion(date: baseDate),
          // Пользователь добавил забытую отметку за вчера задним числом:
          createCompletion(date: baseDate.subtract(const Duration(days: 1))),
          createCompletion(date: baseDate.subtract(const Duration(days: 2))),
        ];

        final streak = useCase.execute(habit, completions);

        expect(streak.currentStreak, 3);
      },
    );

    test('12. Корректно работает на границе года (31 декабря -> 1 января)', () {
      final newYearDate = DateTime(2027, 1, 1);
      clock.setTime(newYearDate);

      final habit = createHabit(createdAt: DateTime(2026, 12, 1));
      final completions = [
        createCompletion(date: DateTime(2027, 1, 1)),
        createCompletion(date: DateTime(2026, 12, 31)),
        createCompletion(date: DateTime(2026, 12, 30)),
      ];

      final streak = useCase.execute(habit, completions);

      expect(streak.currentStreak, 3);
      expect(streak.freezesRemaining, 2);
    });
  });
}

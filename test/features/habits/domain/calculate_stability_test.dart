import 'package:flutter_test/flutter_test.dart';
import 'package:calista_tracker/core/utils/clock.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_completion.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_schedule.dart';
import 'package:calista_tracker/features/habits/domain/usecases/calculate_stability_index_use_case.dart';

void main() {
  late CalculateStabilityIndexUseCase useCase;
  late FixedClock clock;
  final baseDate = DateTime(2026, 11, 25);

  setUp(() {
    clock = FixedClock(baseDate);
    useCase = CalculateStabilityIndexUseCase(clock: clock);
  });

  Habit createHabit({
    DateTime? createdAt,
    HabitSchedule schedule = const HabitSchedule.everyDay(),
  }) {
    return Habit(
      id: 'h_1',
      title: 'Стабильность тест',
      schedule: schedule,
      createdAt: createdAt ?? DateTime(2026, 1, 1),
    );
  }

  HabitCompletion createComp(DateTime date, {bool isFrozen = false}) {
    return HabitCompletion(
      id: 'c_${date.millisecondsSinceEpoch}',
      habitId: 'h_1',
      date: date,
      isFrozen: isFrozen,
      recordedAt: date,
    );
  }

  group('CalculateStabilityIndexUseCase', () {
    test('13. Возвращает 100.0% при выполнении всех 30 дней окна', () {
      final habit = createHabit();
      final completions = List.generate(
        30,
        (i) => createComp(baseDate.subtract(Duration(days: i))),
      );

      final metrics = useCase.execute(habit, completions);

      expect(metrics.totalScheduledDays, 30);
      expect(metrics.completedDays, 30);
      expect(metrics.frozenDays, 0);
      expect(metrics.missedDays, 0);
      expect(metrics.stabilityRate30Days, 100.0);
    });

    test('14. Возвращает 0.0% при отсутствии отметок за 30 дней', () {
      final habit = createHabit();
      final metrics = useCase.execute(habit, []);

      expect(metrics.totalScheduledDays, 30);
      expect(metrics.completedDays, 0);
      expect(metrics.missedDays, 30);
      expect(metrics.stabilityRate30Days, 0.0);
    });

    test('15. Точно рассчитывает процент стабильности при наличии пропусков и заморозок', () {
      final habit = createHabit();
      // Из 30 дней: 24 выполнено, 2 заморожено, 4 пропущено
      final completions = <HabitCompletion>[];
      for (int i = 0; i < 24; i++) {
        completions.add(createComp(baseDate.subtract(Duration(days: i))));
      }
      completions.add(
        createComp(baseDate.subtract(const Duration(days: 24)), isFrozen: true),
      );
      completions.add(
        createComp(baseDate.subtract(const Duration(days: 25)), isFrozen: true),
      );

      final metrics = useCase.execute(habit, completions);

      expect(metrics.totalScheduledDays, 30);
      expect(metrics.completedDays, 24);
      expect(metrics.frozenDays, 2);
      expect(metrics.missedDays, 4);
      // 24 / 30 = 80.0%
      expect(metrics.stabilityRate30Days, 80.0);
    });

    test('16. Ограничивает окно датой создания привычки, если привычке меньше 30 дней', () {
      // Привычка создана 5 дней назад (21.11.2026)
      final habit = createHabit(
        createdAt: baseDate.subtract(const Duration(days: 4)),
      );
      // Выполнено 4 дня из 5
      final completions = List.generate(
        4,
        (i) => createComp(baseDate.subtract(Duration(days: i))),
      );

      final metrics = useCase.execute(habit, completions);

      expect(metrics.totalScheduledDays, 5);
      expect(metrics.completedDays, 4);
      expect(metrics.missedDays, 1);
      // 4 / 5 = 80.0%
      expect(metrics.stabilityRate30Days, 80.0);
    });

    test('17. Учитывает только запланированные дни для привычки с выборочным расписанием', () {
      // Привычка только по субботам и воскресеньям (6, 7)
      final habit = createHabit(
        schedule: const HabitSchedule.specificDays([6, 7]),
      );

      // За 30 дней примерно 8-9 выходных дней
      final metrics = useCase.execute(habit, []);

      expect(metrics.totalScheduledDays, lessThan(10));
      expect(metrics.totalScheduledDays, greaterThan(7));
      expect(metrics.stabilityRate30Days, 0.0);
    });
  });
}

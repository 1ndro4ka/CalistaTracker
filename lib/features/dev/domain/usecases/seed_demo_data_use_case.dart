import '../../../../core/utils/clock.dart';
import '../../../habits/domain/entities/freeze_policy.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_completion.dart';
import '../../../habits/domain/entities/habit_schedule.dart';
import '../../../habits/domain/repositories/completion_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

/// Создаёт воспроизводимый набор демо-привычек с историей.
///
/// Идентификаторы фиксированные, поэтому повторное нажатие не дублирует данные:
/// если демо уже есть, температура не меняется и возвращается `0`.
class SeedDemoDataUseCase {
  static const demoIds = <String>{
    'demo_morning',
    'demo_reading',
    'demo_english',
  };

  final HabitRepository habitRepository;
  final CompletionRepository completionRepository;
  final Clock clock;

  const SeedDemoDataUseCase({
    required this.habitRepository,
    required this.completionRepository,
    required this.clock,
  });

  Future<int> execute() async {
    final existing = await habitRepository.getAllHabits(includeArchived: true);
    if (existing.any((habit) => demoIds.contains(habit.id))) {
      return 0; // Уже заполнено — ничего не портим.
    }

    final today = FreezePolicy.normalize(clock.now());
    final createdAt = today.subtract(const Duration(days: 18));

    final habits = <Habit>[
      Habit(
        id: 'demo_morning',
        title: 'Утренняя зарядка',
        description: '15 минут движения сразу после пробуждения',
        createdAt: createdAt,
        reminderTime: '07:30',
        monthlyFreezesAllowed: 2,
      ),
      Habit(
        id: 'demo_reading',
        title: 'Чтение 20 минут',
        description: 'Пн/ср/пт — книга вместо скролла',
        createdAt: createdAt,
        schedule: const HabitSchedule.specificDays([1, 3, 5]),
        reminderTime: '21:00',
        monthlyFreezesAllowed: 1,
      ),
      Habit(
        id: 'demo_english',
        title: 'Английский',
        description: 'Одно предложение каждый день',
        createdAt: createdAt,
        reminderTime: '19:00',
        monthlyFreezesAllowed: 3,
      ),
    ];

    for (final habit in habits) {
      await habitRepository.saveHabit(habit);

      // 17 дней истории: 1–7 числа месяца намеренно пропущены у «Английского»,
      // чтобы после пересчёта включилась автозаморозка и была видна квота.
      for (var daysAgo = 17; daysAgo >= 1; daysAgo--) {
        final day = today.subtract(Duration(days: daysAgo));
        if (!habit.schedule.isScheduledFor(day)) continue;

        final skipMorning =
            habit.id == 'demo_morning' && (daysAgo == 5 || daysAgo == 3);
        final skipEnglish = habit.id == 'demo_english' && daysAgo <= 7;
        if (skipMorning || skipEnglish) continue;

        await completionRepository.addCompletion(
          HabitCompletion(
            id: 'demo_${habit.id}_${day.millisecondsSinceEpoch}',
            habitId: habit.id,
            date: day,
            recordedAt: today,
          ),
        );
      }
    }

    return habits.length;
  }
}

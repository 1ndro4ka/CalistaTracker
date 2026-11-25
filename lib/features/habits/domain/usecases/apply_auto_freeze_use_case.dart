import '../../../../core/utils/clock.dart';
import '../entities/freeze_policy.dart';
import '../entities/habit.dart';
import '../entities/habit_completion.dart';
import '../repositories/completion_repository.dart';

/// Результат применения автозаморозки.
class AutoFreezeResult {
  /// Заморозки, которые были созданы в этом вызове.
  final List<HabitCompletion> createdFreezes;

  /// Полная история привычки с учётом уже существующих и новых заморозок.
  final List<HabitCompletion> allCompletions;

  const AutoFreezeResult({
    required this.createdFreezes,
    required this.allCompletions,
  });

  bool get hasNewFreezes => createdFreezes.isNotEmpty;
}

/// Материализует «Гибкую серию»: пропущенные запланированные дни, которые
/// должны быть покрыты месячной квотой заморозок, сохраняются в БД как
/// [HabitCompletion] с `isFrozen = true`.
///
/// Почему это нужно отдельным сценарием:
/// * `CalculateStreakUseCase` умеет *виртуально* перешагивать пропуски, чтобы
///   посчитать серию, но календарь и статистика должны видеть реальные
///   замороженные ячейки;
/// * запись в БД делает состояние восстановимым и позволяет отличить
///   «день не отмечен» от «день сохранён заморозкой».
///
/// Алгоритм идёт от вчерашнего дня назад и останавливается, как только
/// месячная квота исчерпана: дни старше разрыва уже не могут спасти текущую
/// серию, поэтому тратить на них заморозки нельзя.
class ApplyAutoFreezeUseCase {
  static const int defaultLookbackDays = 366;

  final CompletionRepository completionRepository;
  final Clock clock;

  const ApplyAutoFreezeUseCase({
    required this.completionRepository,
    this.clock = const SystemClock(),
  });

  Future<AutoFreezeResult> execute(
    Habit habit,
    List<HabitCompletion> completions, {
    DateTime? currentDate,
    int lookbackDays = defaultLookbackDays,
  }) async {
    final now = currentDate ?? clock.now();
    final today = FreezePolicy.normalize(now);
    final habitStart = FreezePolicy.normalize(habit.createdAt);
    final lookbackFloor = today.subtract(Duration(days: lookbackDays));
    final floor = habitStart.isAfter(lookbackFloor)
        ? habitStart
        : lookbackFloor;

    final policy = FreezePolicy(monthlyAllowance: habit.monthlyFreezesAllowed);
    final completionByDay = <DateTime, HabitCompletion>{};
    final usedByMonth = <String, int>{};

    for (final completion in completions) {
      if (completion.habitId != habit.id) continue;
      final day = FreezePolicy.normalize(completion.date);
      completionByDay[day] = completion;
      if (completion.isFrozen) {
        final key = FreezePolicy.monthKey(day);
        usedByMonth[key] = (usedByMonth[key] ?? 0) + 1;
      }
    }

    final created = <HabitCompletion>[];
    if (habit.isArchived) {
      return AutoFreezeResult(
        createdFreezes: created,
        allCompletions: List<HabitCompletion>.unmodifiable(completions),
      );
    }

    // Сегодня ещё не закончился — его нельзя считать пропуском.
    var cursor = today.subtract(const Duration(days: 1));

    while (!cursor.isBefore(floor)) {
      if (habit.schedule.isScheduledFor(cursor)) {
        final existing = completionByDay[cursor];

        if (existing == null) {
          final key = FreezePolicy.monthKey(cursor);
          final usedThisMonth = usedByMonth[key] ?? 0;

          if (!policy.canFreeze(usedThisMonth)) {
            // Дальше вглубь истории идти бессмысленно: текущая цепочка уже
            // разорвана этим днём, а заморозки на старые разрывы не спасут её.
            break;
          }

          final frozenCompletion = HabitCompletion(
            id: _freezeId(habit.id, cursor),
            habitId: habit.id,
            date: cursor,
            isFrozen: true,
            recordedAt: now,
          );

          await completionRepository.addCompletion(frozenCompletion);

          created.add(frozenCompletion);
          completionByDay[cursor] = frozenCompletion;
          usedByMonth[key] = usedThisMonth + 1;
        }
      }

      cursor = cursor.subtract(const Duration(days: 1));
    }

    return AutoFreezeResult(
      createdFreezes: List<HabitCompletion>.unmodifiable(created),
      allCompletions: List<HabitCompletion>.unmodifiable([
        ...completions,
        ...created,
      ]),
    );
  }

  /// Детерминированный ID: повторный запуск не создаёт дубликаты.
  String _freezeId(String habitId, DateTime day) {
    final month = day.month.toString().padLeft(2, '0');
    final date = day.day.toString().padLeft(2, '0');
    return '${habitId}_freeze_${day.year}$month$date';
  }
}

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/clock.dart';
import '../entities/habit.dart';
import '../entities/habit_completion.dart';
import '../entities/stability_metrics.dart';

class CalculateStabilityIndexUseCase {
  final Clock clock;

  const CalculateStabilityIndexUseCase({this.clock = const SystemClock()});

  StabilityMetrics execute(
    Habit habit,
    List<HabitCompletion> completions, {
    DateTime? currentDate,
    int windowDays = AppConstants.stabilityWindowDays,
  }) {
    final now = currentDate ?? clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final habitStart = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );

    final completionMap = <DateTime, HabitCompletion>{};
    for (final c in completions) {
      if (c.habitId == habit.id) {
        final d = DateTime(c.date.year, c.date.month, c.date.day);
        completionMap[d] = c;
      }
    }

    int totalScheduledDays = 0;
    int completedDays = 0;
    int frozenDays = 0;
    int missedDays = 0;

    final windowStart = today.subtract(Duration(days: windowDays - 1));

    var scanDate = windowStart;
    while (!scanDate.isAfter(today)) {
      if (!scanDate.isBefore(habitStart)) {
        if (habit.schedule.isScheduledFor(scanDate)) {
          totalScheduledDays++;
          final comp = completionMap[scanDate];
          if (comp != null && !comp.isFrozen) {
            completedDays++;
          } else if (comp != null && comp.isFrozen) {
            frozenDays++;
          } else {
            missedDays++;
          }
        }
      }
      scanDate = scanDate.add(const Duration(days: 1));
    }

    final double stabilityRate = totalScheduledDays > 0
        ? (completedDays / totalScheduledDays) * 100.0
        : 0.0;

    return StabilityMetrics(
      stabilityRate30Days: double.parse(stabilityRate.toStringAsFixed(1)),
      totalScheduledDays: totalScheduledDays,
      completedDays: completedDays,
      frozenDays: frozenDays,
      missedDays: missedDays,
    );
  }
}

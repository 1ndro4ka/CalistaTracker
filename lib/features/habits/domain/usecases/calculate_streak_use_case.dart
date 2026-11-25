import 'dart:math' as math;

import '../../../../core/utils/clock.dart';
import '../entities/habit.dart';
import '../entities/habit_completion.dart';
import '../entities/streak_info.dart';

class CalculateStreakUseCase {
  final Clock clock;

  const CalculateStreakUseCase({this.clock = const SystemClock()});

  StreakInfo execute(
    Habit habit,
    List<HabitCompletion> completions, {
    DateTime? currentDate,
  }) {
    final now = currentDate ?? clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final habitStart = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );

    // Map completions by normalized date
    final completionMap = <DateTime, HabitCompletion>{};
    for (final c in completions) {
      if (c.habitId == habit.id) {
        final d = DateTime(c.date.year, c.date.month, c.date.day);
        completionMap[d] = c;
      }
    }

    // Collect all scheduled days from habitStart up to today
    final scheduledDays = <DateTime>[];
    var dayIter = habitStart;
    while (!dayIter.isAfter(today)) {
      if (habit.schedule.isScheduledFor(dayIter)) {
        scheduledDays.add(dayIter);
      }
      dayIter = dayIter.add(const Duration(days: 1));
    }

    if (scheduledDays.isEmpty) {
      return StreakInfo.zero(freezesAllowed: habit.monthlyFreezesAllowed);
    }

    // Determine current streak
    int currentStreak = 0;
    DateTime? lastCompletedDate;

    // Index of today in scheduledDays, if present
    int currentIndex = scheduledDays.length - 1;
    final lastScheduledDay = scheduledDays[currentIndex];

    // Check if the last scheduled day is today
    if (lastScheduledDay == today) {
      final todayComp = completionMap[today];
      if (todayComp != null && !todayComp.isFrozen) {
        currentStreak++;
        lastCompletedDate = today;
        currentIndex--;
      } else if (todayComp != null && todayComp.isFrozen) {
        currentIndex--;
      } else {
        // Today is scheduled but not yet completed. Today doesn't break the streak.
        currentIndex--;
      }
    }

    // Iterate backwards through scheduled days to build current streak
    final monthlyFreezesTracker = <String, int>{};
    for (final c in completions) {
      if (c.habitId == habit.id && c.isFrozen) {
        final k = '${c.date.year}-${c.date.month}';
        monthlyFreezesTracker[k] = (monthlyFreezesTracker[k] ?? 0) + 1;
      }
    }

    while (currentIndex >= 0) {
      final day = scheduledDays[currentIndex];
      final comp = completionMap[day];

      if (comp != null && !comp.isFrozen) {
        currentStreak++;
        lastCompletedDate ??= day;
        currentIndex--;
      } else if (comp != null && comp.isFrozen) {
        // Pre-recorded freeze keeps streak alive
        currentIndex--;
      } else {
        // Uncompleted scheduled day: examine the gap
        // Count how many consecutive uncompleted days are in this gap
        final gapEndIndex = currentIndex;
        int gapStartIndex = currentIndex;
        while (gapStartIndex >= 0 &&
            (completionMap[scheduledDays[gapStartIndex]] == null)) {
          gapStartIndex--;
        }

        // gap is from gapStartIndex + 1 to gapEndIndex
        // If there are no completions before this gap (gapStartIndex < 0),
        // then the streak simply started after this gap. Stop.
        if (gapStartIndex < 0) {
          break;
        }

        final gapDays = <DateTime>[];
        for (int i = gapStartIndex + 1; i <= gapEndIndex; i++) {
          gapDays.add(scheduledDays[i]);
        }

        // Check if all gap days can be frozen by monthly limits
        bool canBridge = true;
        final tempMonthlyUsage = Map<String, int>.from(monthlyFreezesTracker);

        for (final gapDay in gapDays) {
          final mKey = '${gapDay.year}-${gapDay.month}';
          final used = tempMonthlyUsage[mKey] ?? 0;
          if (used >= habit.monthlyFreezesAllowed) {
            canBridge = false;
            break;
          }
          tempMonthlyUsage[mKey] = used + 1;
        }

        if (canBridge) {
          // Successfully bridged gap!
          monthlyFreezesTracker.clear();
          monthlyFreezesTracker.addAll(tempMonthlyUsage);
          currentIndex = gapStartIndex; // jump across gap
        } else {
          // Gap too wide: streak is broken!
          break;
        }
      }
    }

    // Calculate Longest Streak by scanning history forward
    int longestStreak = currentStreak;
    int runningStreak = 0;
    int scanIdx = 0;

    final historyFreezesTracker = <String, int>{};
    for (final c in completions) {
      if (c.habitId == habit.id && c.isFrozen) {
        final k = '${c.date.year}-${c.date.month}';
        historyFreezesTracker[k] = (historyFreezesTracker[k] ?? 0) + 1;
      }
    }

    while (scanIdx < scheduledDays.length) {
      final day = scheduledDays[scanIdx];
      final comp = completionMap[day];

      if (comp != null && !comp.isFrozen) {
        runningStreak++;
        longestStreak = math.max(longestStreak, runningStreak);
        scanIdx++;
      } else if (comp != null && comp.isFrozen) {
        scanIdx++;
      } else {
        // Check if this gap can bridge to next completion
        int nextCompIdx = scanIdx;
        while (nextCompIdx < scheduledDays.length &&
            (completionMap[scheduledDays[nextCompIdx]] == null)) {
          nextCompIdx++;
        }

        if (nextCompIdx < scheduledDays.length && runningStreak > 0) {
          final gapDays = <DateTime>[];
          for (int i = scanIdx; i < nextCompIdx; i++) {
            gapDays.add(scheduledDays[i]);
          }

          bool canBridge = true;
          final tempUsage = Map<String, int>.from(historyFreezesTracker);
          for (final gDay in gapDays) {
            final mKey = '${gDay.year}-${gDay.month}';
            final used = tempUsage[mKey] ?? 0;
            if (used >= habit.monthlyFreezesAllowed) {
              canBridge = false;
              break;
            }
            tempUsage[mKey] = used + 1;
          }

          if (canBridge) {
            historyFreezesTracker.clear();
            historyFreezesTracker.addAll(tempUsage);
            scanIdx = nextCompIdx;
            continue;
          }
        }

        runningStreak = 0;
        scanIdx++;
      }
    }

    final totalFreezesUsedThisMonth = math.min(
      habit.monthlyFreezesAllowed,
      monthlyFreezesTracker['${today.year}-${today.month}'] ?? 0,
    );
    final freezesRemaining = math.max(
      0,
      habit.monthlyFreezesAllowed - totalFreezesUsedThisMonth,
    );

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: math.max(longestStreak, currentStreak),
      freezesUsedThisMonth: totalFreezesUsedThisMonth,
      freezesRemaining: freezesRemaining,
      lastCompletedDate: lastCompletedDate,
    );
  }
}

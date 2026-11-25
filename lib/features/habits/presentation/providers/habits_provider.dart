import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../../reminders/presentation/providers/reminder_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/stability_metrics.dart';
import '../../domain/entities/streak_info.dart';
import 'database_provider.dart';

/// Счётчик изменений данных. На него смотрят производные провайдеры
/// (например, статистика по дням недели), чтобы не кэшировать старые выборки.
final dataRevisionProvider = NotifierProvider<DataRevisionNotifier, int>(
  DataRevisionNotifier.new,
);

class DataRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

class HabitItemViewData {
  final Habit habit;
  final bool isCompletedToday;
  final bool isScheduledToday;
  final StreakInfo streakInfo;
  final StabilityMetrics stabilityMetrics;

  const HabitItemViewData({
    required this.habit,
    required this.isCompletedToday,
    required this.isScheduledToday,
    required this.streakInfo,
    required this.stabilityMetrics,
  });

  HabitItemViewData copyWith({
    Habit? habit,
    bool? isCompletedToday,
    bool? isScheduledToday,
    StreakInfo? streakInfo,
    StabilityMetrics? stabilityMetrics,
  }) {
    return HabitItemViewData(
      habit: habit ?? this.habit,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      isScheduledToday: isScheduledToday ?? this.isScheduledToday,
      streakInfo: streakInfo ?? this.streakInfo,
      stabilityMetrics: stabilityMetrics ?? this.stabilityMetrics,
    );
  }
}

class HabitsNotifier extends AsyncNotifier<List<HabitItemViewData>> {
  @override
  Future<List<HabitItemViewData>> build() async {
    return _fetchHabits();
  }

  Future<List<HabitItemViewData>> _fetchHabits() async {
    final habitRepo = ref.read(habitRepositoryProvider);
    final compRepo = ref.read(completionRepositoryProvider);
    final streakUseCase = ref.read(calculateStreakUseCaseProvider);
    final stabilityUseCase = ref.read(calculateStabilityUseCaseProvider);
    final autoFreezeUseCase = ref.read(applyAutoFreezeUseCaseProvider);

    final habits = await habitRepo.getAllHabits(includeArchived: false);
    final now = ref.watch(clockProvider).now();
    final today = DateTime(now.year, now.month, now.day);

    final items = <HabitItemViewData>[];
    for (final h in habits) {
      final completions = await compRepo.getCompletionsForHabit(h.id);

      // Материализуем «Гибкую серию» перед расчётом метрик: календарь и
      // статистика должны видеть реальные заморозки, а не только виртуальные.
      final freezeResult = await autoFreezeUseCase.execute(
        h,
        completions,
        currentDate: today,
      );
      final effectiveCompletions = freezeResult.allCompletions;

      final streak = streakUseCase.execute(
        h,
        effectiveCompletions,
        currentDate: today,
      );
      final stability = stabilityUseCase.execute(
        h,
        effectiveCompletions,
        currentDate: today,
      );

      final isCompleted = effectiveCompletions.any((c) {
        final cd = DateTime(c.date.year, c.date.month, c.date.day);
        return cd == today && !c.isFrozen;
      });
      final isScheduled = h.schedule.isScheduledFor(today);

      items.add(
        HabitItemViewData(
          habit: h,
          isCompletedToday: isCompleted,
          isScheduledToday: isScheduled,
          streakInfo: streak,
          stabilityMetrics: stability,
        ),
      );
    }
    return items;
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHabits());
  }

  Future<void> loadHabits() => reload();

  void _bumpRevision() => ref.read(dataRevisionProvider.notifier).bump();

  Future<void> toggleCompletion(String habitId) async {
    try {
      final toggleUseCase = ref.read(toggleCompletionUseCaseProvider);
      final now = ref.read(clockProvider).now();
      final wasCompleted = await toggleUseCase.execute(habitId, now);

      if (wasCompleted) {
        await AppFeedback.checkmark();
      } else {
        await AppFeedback.uncheck();
      }

      state = await AsyncValue.guard(() => _fetchHabits());
      _bumpRevision();

      final currentList = state.value ?? <HabitItemViewData>[];
      final item = currentList
          .where((HabitItemViewData i) => i.habit.id == habitId)
          .firstOrNull;
      if (item != null) {
        final streak = item.streakInfo.currentStreak;
        if (streak == 7 || streak == 30 || streak == 100) {
          await AppFeedback.milestone();
        }
      }
    } catch (_) {
      await AppFeedback.error();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final manageUseCase = ref.read(manageHabitUseCaseProvider);
    await manageUseCase.deleteHabit(habitId);
    try {
      await ref.read(reminderSchedulerProvider).cancelHabitReminder(habitId);
    } catch (_) {
      // Напоминания не должны блокировать удаление привычки.
    }
    state = await AsyncValue.guard(() => _fetchHabits());
    _bumpRevision();
  }

  Future<void> saveHabit(Habit habit) async {
    final manageUseCase = ref.read(manageHabitUseCaseProvider);
    final saved = await manageUseCase.createOrUpdateHabit(habit);
    try {
      await ref.read(reminderSchedulerProvider).syncHabitReminder(saved);
    } catch (_) {
      // Ошибка планировщика не должна отменять сохранение привычки.
    }
    state = await AsyncValue.guard(() => _fetchHabits());
    _bumpRevision();
  }
}

final habitsProvider =
    AsyncNotifierProvider<HabitsNotifier, List<HabitItemViewData>>(
      HabitsNotifier.new,
    );

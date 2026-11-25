import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/freeze_icon.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';
import '../../domain/entities/stability_metrics.dart';
import '../../domain/entities/streak_info.dart';
import '../providers/database_provider.dart';
import '../providers/habits_provider.dart';
import '../widgets/heatmap_calendar.dart';
import '../widgets/stability_meter.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  DateTime _currentMonth = DateTime.now();

  /// Направление листания календаря: -1 назад, 1 вперёд.
  int _monthDirection = 1;
  bool _isLoading = true;
  Habit? _habit;
  List<HabitCompletion> _completions = [];
  StreakInfo _streakInfo = const StreakInfo.zero();
  StabilityMetrics _stabilityMetrics = const StabilityMetrics.empty();

  @override
  void initState() {
    super.initState();
    _currentMonth = ref.read(clockProvider).now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final habitRepo = ref.read(habitRepositoryProvider);
    final compRepo = ref.read(completionRepositoryProvider);
    final streakUseCase = ref.read(calculateStreakUseCaseProvider);
    final stabilityUseCase = ref.read(calculateStabilityUseCaseProvider);
    final autoFreezeUseCase = ref.read(applyAutoFreezeUseCaseProvider);

    final habit = await habitRepo.getHabitById(widget.habitId);
    if (habit != null) {
      final storedCompletions = await compRepo.getCompletionsForHabit(habit.id);
      final now = ref.read(clockProvider).now();
      final freezeResult = await autoFreezeUseCase.execute(
        habit,
        storedCompletions,
        currentDate: now,
      );
      final completions = freezeResult.allCompletions;
      final streak = streakUseCase.execute(
        habit,
        completions,
        currentDate: now,
      );
      final stability = stabilityUseCase.execute(
        habit,
        completions,
        currentDate: now,
      );

      setState(() {
        _habit = habit;
        _completions = completions;
        _streakInfo = streak;
        _stabilityMetrics = stability;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleDate(DateTime date) async {
    final toggle = ref.read(toggleCompletionUseCaseProvider);
    final isCompleted = await toggle.execute(widget.habitId, date);
    if (isCompleted) {
      await AppFeedback.checkmark();
    } else {
      await AppFeedback.uncheck();
    }

    await _loadData();
    await ref.read(habitsProvider.notifier).loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
      );
    }

    final habit = _habit;
    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ОШИБКА')),
        body: const Center(child: Text('Привычка не найдена')),
      );
    }

    final monthTitle = AppDateFormatter.formatMonthYear(_currentMonth);
    final entrance = MotionTokens.getDuration(
      context,
      MotionTokens.durationEntrance,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ДЕТАЛИ ПРИВЫЧКИ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Редактировать',
            onPressed: () async {
              await AppFeedback.selection();
              if (!context.mounted) return;
              await context.push('/habits/${habit.id}/edit');
              await _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалить',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title & Description
          Text(habit.title, style: AppTypography.titleLarge)
              .animate()
              .fadeIn(duration: entrance, curve: MotionTokens.curveAppear)
              .slideY(
                begin: MotionTokens.entranceOffset,
                end: 0,
                duration: entrance,
                curve: MotionTokens.curveAppear,
              ),
          if (habit.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              habit.description,
              style: AppTypography.bodySmall,
            ).animate().fadeIn(
              duration: entrance,
              delay: MotionTokens.staggerDelay(context, 1),
            ),
          ],
          const SizedBox(height: 18),

          // Core Metrics Cards Grid
          Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'ТЕКУЩАЯ СЕРИЯ',
                      value: '${_streakInfo.currentStreak} д',
                      subtext: 'Рекорд: ${_streakInfo.longestStreak} д',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      label: 'ИСПОЛЬЗОВАНО ЗАМОРОЗОК',
                      value:
                          '${_streakInfo.freezesUsedThisMonth} / ${habit.monthlyFreezesAllowed}',
                      subtext: 'Осталось: ${_streakInfo.freezesRemaining}',
                      leading: const FreezeIcon(size: 16),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(
                duration: entrance,
                delay: MotionTokens.staggerDelay(context, 2),
              )
              .slideY(
                begin: MotionTokens.entranceOffset,
                end: 0,
                duration: entrance,
                delay: MotionTokens.staggerDelay(context, 2),
              ),
          const SizedBox(height: 12),

          // 30-Day Stability Meter
          StabilityMeter(percentage: _stabilityMetrics.stabilityRate30Days)
              .animate()
              .fadeIn(
                duration: entrance,
                delay: MotionTokens.staggerDelay(context, 3),
              )
              .slideY(
                begin: MotionTokens.entranceOffset,
                end: 0,
                duration: entrance,
                delay: MotionTokens.staggerDelay(context, 3),
              ),
          const SizedBox(height: 24),

          // Heatmap Calendar Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(monthTitle, style: AppTypography.titleMedium),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () {
                      AppFeedback.selection();
                      setState(() {
                        _monthDirection = -1;
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: () {
                      AppFeedback.selection();
                      setState(() {
                        _monthDirection = 1;
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          AnimatedSwitcher(
            duration: MotionTokens.getDuration(
              context,
              MotionTokens.durationMedium,
            ),
            switchInCurve: MotionTokens.curveAppear,
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: Offset(_monthDirection * 0.08, 0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: HeatmapCalendar(
              key: ValueKey('${_currentMonth.year}-${_currentMonth.month}'),
              habit: habit,
              completions: _completions,
              month: _currentMonth,
              today: ref.watch(clockProvider).now(),
              onDayTap: _toggleDate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите на прошедший день, чтобы отметить его или снять отметку.',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          // Info Box about Streak Freeze protection
          Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ℹ', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'При случайном пропуске запланированного дня серия не сгорает, а помечается как [Заморожено] за счёт вашей месячной квоты.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(
                duration: entrance,
                delay: MotionTokens.staggerDelay(context, 4),
              )
              .slideY(
                begin: MotionTokens.entranceOffset,
                end: 0,
                duration: entrance,
                delay: MotionTokens.staggerDelay(context, 4),
              ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    AppFeedback.selection();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
        title: const Text(
          'УДАЛИТЬ ПРИВЫЧКУ?',
          style: AppTypography.titleMedium,
        ),
        content: const Text(
          'Привычка и вся история её выполнений будут безвозвратно удалены.',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'ОТМЕНА',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(habitsProvider.notifier)
                  .deleteHabit(widget.habitId);
              if (mounted) context.pop();
            },
            child: const Text(
              'УДАЛИТЬ',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final Widget? leading;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtext,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 6),
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Flexible(
                child: Text(
                  value,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

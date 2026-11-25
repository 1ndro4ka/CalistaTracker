import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/freeze_icon.dart';
import '../../../habits/presentation/providers/habits_provider.dart';
import '../providers/weekday_stats_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int? _selectedWeekday;

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final weekdayAsync = ref.watch(weekdayStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('СТАТИСТИКА И СТАБИЛЬНОСТЬ')),
      body: habitsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text('Ошибка: $err')),
        ),
        data: (habits) {
          if (habits.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Нет данных для статистики. Создайте хотя бы одну привычку.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          double totalStability = 0;
          int totalFreezesUsed = 0;
          int maxStreak = 0;

          for (final item in habits) {
            totalStability += item.stabilityMetrics.stabilityRate30Days;
            totalFreezesUsed += item.streakInfo.freezesUsedThisMonth;
            if (item.streakInfo.longestStreak > maxStreak) {
              maxStreak = item.streakInfo.longestStreak;
            }
          }

          final avgStability = (totalStability / habits.length).toStringAsFixed(
            1,
          );
          final weekdayStats = weekdayAsync.value ?? const <WeekdayStat>[];
          final selected = _selectedWeekday == null
              ? null
              : weekdayStats.isEmpty
              ? null
              : weekdayStats.firstWhere(
                  (stat) => stat.weekday == _selectedWeekday,
                  orElse: () => weekdayStats.first,
                );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ОБЩИЙ ИНДЕКС СТАБИЛЬНОСТИ',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: double.tryParse(avgStability) ?? 0,
                      ),
                      duration: MotionTokens.getDuration(
                        context,
                        MotionTokens.durationSlow,
                      ),
                      curve: MotionTokens.curveAppear,
                      builder: (context, value, _) => Text(
                        '${value.toStringAsFixed(1)}%',
                        style: AppTypography.statValue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Среднее постоянство по всем ${habits.length} привычкам за 30 дней',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Обе карточки одинаковой высоты благодаря stretch + SizedBox.
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 122,
                      child: _MetricBox(
                        label: 'СПАСЕНО СЕРИЙ',
                        value: '$totalFreezesUsed',
                        subtext: 'Заморозок в этом месяце',
                        leading: const FreezeIcon(size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 122,
                      child: _MetricBox(
                        label: 'ЛУЧШАЯ СЕРИЯ',
                        value: '$maxStreak д',
                        subtext: 'Максимум среди всех',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'АКТИВНОСТЬ ПО ДНЯМ НЕДЕЛИ',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    weekdayAsync.when(
                      loading: () => const SizedBox(
                        height: 120,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      error: (error, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'Не удалось загрузить график: $error',
                          style: AppTypography.caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      data: (stats) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final stat in stats)
                            _WeekdayBar(
                              stat: stat,
                              selected: _selectedWeekday == stat.weekday,
                              onTap: () => setState(() {
                                _selectedWeekday =
                                    _selectedWeekday == stat.weekday
                                    ? null
                                    : stat.weekday;
                              }),
                            ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: MotionTokens.getDuration(
                        context,
                        MotionTokens.durationMedium,
                      ),
                      curve: MotionTokens.curveAppear,
                      alignment: Alignment.topCenter,
                      child: selected == null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'Нажмите на день, чтобы увидеть детали',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : AnimatedSwitcher(
                              duration: MotionTokens.getDuration(
                                context,
                                MotionTokens.durationFast,
                              ),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: KeyedSubtree(
                                key: ValueKey(selected.weekday),
                                child: _DayDetails(stat: selected),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'СТАБИЛЬНОСТЬ ПО ПРИВЫЧКАМ',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 8),
              ...habits.asMap().entries.map(
                (entry) =>
                    Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.value.habit.title,
                                  style: AppTypography.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${entry.value.stabilityMetrics.stabilityRate30Days}%',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(
                          duration: MotionTokens.getDuration(
                            context,
                            MotionTokens.durationEntrance,
                          ),
                          delay: MotionTokens.staggerDelay(context, entry.key),
                        )
                        .slideY(
                          begin: MotionTokens.entranceOffset,
                          end: 0,
                          duration: MotionTokens.getDuration(
                            context,
                            MotionTokens.durationEntrance,
                          ),
                          delay: MotionTokens.staggerDelay(context, entry.key),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final Widget? leading;

  const _MetricBox({
    required this.label,
    required this.value,
    required this.subtext,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 10),
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Flexible(child: Text(value, style: AppTypography.titleLarge)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtext,
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _WeekdayBar extends StatelessWidget {
  final WeekdayStat stat;
  final bool selected;
  final VoidCallback onTap;

  const _WeekdayBar({
    required this.stat,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final height = 24.0 + 76.0 * stat.rate;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: MotionTokens.getDuration(
            context,
            MotionTokens.durationMedium,
          ),
          curve: MotionTokens.curveAppear,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceMuted : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: selected
                ? Border.all(color: AppColors.borderHighlight, width: 0.8)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: height),
                duration: MotionTokens.getDuration(
                  context,
                  MotionTokens.durationSlow,
                ),
                curve: MotionTokens.curveAppear,
                builder: (context, value, _) => Container(
                  width: 18,
                  height: value,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stat.label,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: selected ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
              Text(
                '${stat.completed}/${stat.scheduled}',
                style: AppTypography.caption.copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayDetails extends StatelessWidget {
  final WeekdayStat stat;

  const _DayDetails({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ДЕТАЛИ: ${stat.label}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(stat.rate * 100).toStringAsFixed(0)}%',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (stat.habits.isEmpty)
            Text(
              'В этот день по расписанию нет привычек',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            )
          else
            ...stat.habits.map(
              (habit) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            habit.title,
                            style: AppTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${habit.completed}/${habit.scheduled}',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: habit.rate,
                        minHeight: 3,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (habit.frozen > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const FreezeIcon(size: 11),
                          const SizedBox(width: 4),
                          Text(
                            'Заморозок: ${habit.frozen}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.freezeActive,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

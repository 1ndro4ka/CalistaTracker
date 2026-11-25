import 'package:flutter/material.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';

class HeatmapCalendar extends StatelessWidget {
  final Habit habit;
  final List<HabitCompletion> completions;
  final DateTime month;
  final ValueChanged<DateTime>? onDayTap;

  const HeatmapCalendar({
    super.key,
    required this.habit,
    required this.completions,
    required this.month,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday = 1, Sunday = 7
    final firstWeekday = firstDayOfMonth.weekday;

    final completionMap = <int, HabitCompletion>{};
    for (final c in completions) {
      if (c.date.year == month.year && c.date.month == month.month) {
        completionMap[c.date.day] = c;
      }
    }

    final today = DateTime.now();
    final isCurrentMonth =
        today.year == month.year && today.month == month.month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Days of week header
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DayHeader('ПН'),
            _DayHeader('ВТ'),
            _DayHeader('СР'),
            _DayHeader('ЧТ'),
            _DayHeader('ПТ'),
            _DayHeader('СБ'),
            _DayHeader('ВС'),
          ],
        ),
        const SizedBox(height: 8),

        // Grid of cells
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.0,
          ),
          itemCount: 42, // 6 weeks * 7 days
          itemBuilder: (context, index) {
            final dayNumber = index - (firstWeekday - 2);

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final cellDate = DateTime(month.year, month.month, dayNumber);
            final isScheduled = habit.schedule.isScheduledFor(cellDate);
            final comp = completionMap[dayNumber];
            final isDone = comp != null && !comp.isFrozen;
            final isFrozen = comp != null && comp.isFrozen;
            final isToday = isCurrentMonth && today.day == dayNumber;
            final isFuture = cellDate.isAfter(
              DateTime(today.year, today.month, today.day),
            );
            final canToggle =
                onDayTap != null && !isFuture && (isScheduled || comp != null);

            Color backgroundColor = Colors.transparent;
            Color borderColor = AppColors.border;
            Color textColor = AppColors.textMuted;

            if (isDone) {
              backgroundColor = AppColors.textPrimary;
              borderColor = AppColors.textPrimary;
              textColor = AppColors.background;
            } else if (isFrozen) {
              backgroundColor = AppColors.freezeBackground;
              borderColor = AppColors.freezeActive;
              textColor = AppColors.freezeActive;
            } else if (isScheduled) {
              borderColor = isToday
                  ? AppColors.textPrimary
                  : AppColors.borderHighlight;
              textColor = isToday
                  ? AppColors.textPrimary
                  : AppColors.textSecondary;
            }

            return TweenAnimationBuilder<double>(
              key: ValueKey(
                '${month.year}-${month.month}-$dayNumber-$isDone-$isFrozen',
              ),
              tween: Tween<double>(begin: 0.82, end: 1),
              duration: MotionTokens.getDuration(
                context,
                MotionTokens.durationMedium,
              ),
              curve: MotionTokens.curveBounce,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: GestureDetector(
                onTap: canToggle ? () => onDayTap!(cellDate) : null,
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: MotionTokens.getDuration(
                    context,
                    MotionTokens.durationMedium,
                  ),
                  curve: MotionTokens.curveAppear,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: borderColor,
                      width: isToday ? 1.2 : 0.8,
                    ),
                  ),
                  child: Center(
                    child: isFrozen
                        ? const Text(
                            '❄',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.freezeActive,
                            ),
                          )
                        : Text(
                            '$dayNumber',
                            style: AppTypography.caption.copyWith(
                              color: textColor,
                              fontWeight: isToday || isDone
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // Legend
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: AppColors.textPrimary, label: 'Выполнено'),
            SizedBox(width: 14),
            _LegendItem(
              color: AppColors.freezeBackground,
              borderColor: AppColors.freezeActive,
              label: 'Заморожено (❄)',
            ),
            SizedBox(width: 14),
            _LegendItem(
              color: Colors.transparent,
              borderColor: AppColors.borderHighlight,
              label: 'Запланировано',
            ),
          ],
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String text;
  const _DayHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: borderColor ?? color, width: 0.8),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 9)),
      ],
    );
  }
}

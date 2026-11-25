import 'package:flutter/material.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/habits_provider.dart';

class HabitCard extends StatefulWidget {
  final HabitItemViewData data;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const HabitCard({
    super.key,
    required this.data,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: MotionTokens.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: MotionTokens.pressedScale)
        .animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _scaleController.forward();
    AppFeedback.selection();
  }

  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.data;
    final habit = item.habit;
    final streak = item.streakInfo;
    final isDone = item.isCompletedToday;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDone ? AppColors.surfaceMuted : AppColors.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDone ? AppColors.borderHighlight : AppColors.border,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              // Checkbox button
              GestureDetector(
                onTap: widget.onToggle,
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: MotionTokens.durationFast,
                  curve: MotionTokens.curveAppear,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDone
                          ? AppColors.accent
                          : AppColors.borderHighlight,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(
                            Icons.check,
                            size: 20,
                            color: AppColors.background,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: AppTypography.titleMedium.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (habit.reminderTime != null) ...[
                          const Icon(
                            Icons.alarm,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            habit.reminderTime!,
                            style: AppTypography.caption,
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Freeze remaining badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.freezeBackground,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '❄ ${streak.freezesRemaining}/${habit.monthlyFreezesAllowed}',
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              color: AppColors.freezeActive,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Streak & Stability pill
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${streak.currentStreak}',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: streak.currentStreak > 0
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'd',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.stabilityMetrics.stabilityRate30Days}%',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

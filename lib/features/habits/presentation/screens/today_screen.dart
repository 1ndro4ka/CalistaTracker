import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../providers/habits_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/skeleton_loader.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final now = ref.watch(clockProvider).now();
    final formattedDate = AppDateFormatter.formatToday(now);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          // Секретный вход в панель тестирования — доступен во всех сборках.
          onLongPress: () {
            AppFeedback.selection();
            context.push('/dev');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(AppConstants.appName, style: AppTypography.titleLarge),
              Text(formattedDate, style: AppTypography.caption),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => context.push('/stats'),
            tooltip: 'Статистика',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/habits/new'),
            tooltip: 'Новая привычка',
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const SkeletonLoader(),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 36, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Ошибка: $err', style: AppTypography.bodySmall),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(habitsProvider.notifier).loadHabits(),
                child: const Text('Повторить', style: AppTypography.bodyMedium),
              ),
            ],
          ),
        ),
        data: (habits) {
          if (habits.isEmpty) {
            return _EmptyHabitsState(onAdd: () => context.push('/habits/new'))
                .animate()
                .fadeIn(
                  duration: MotionTokens.getDuration(
                    context,
                    MotionTokens.durationEntrance,
                  ),
                  curve: MotionTokens.curveAppear,
                )
                .slideY(
                  begin: MotionTokens.entranceOffset,
                  end: 0,
                  duration: MotionTokens.getDuration(
                    context,
                    MotionTokens.durationEntrance,
                  ),
                  curve: MotionTokens.curveAppear,
                );
          }

          final scheduledToday = habits
              .where((h) => h.isScheduledToday)
              .toList();
          final completedToday = scheduledToday
              .where((h) => h.isCompletedToday)
              .length;
          final totalToday = scheduledToday.length;
          final progressPercent = totalToday > 0
              ? ((completedToday / totalToday) * 100).toInt()
              : 0;

          return RefreshIndicator(
            backgroundColor: AppColors.surface,
            color: AppColors.textPrimary,
            onRefresh: () => ref.read(habitsProvider.notifier).loadHabits(),
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              children: [
                // Top Daily Progress Banner
                if (totalToday > 0)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ВЫПОЛНЕНО СЕГОДНЯ: $completedToday / $totalToday',
                              style: AppTypography.caption,
                            ),
                            AnimatedSwitcher(
                              duration: MotionTokens.getDuration(
                                context,
                                MotionTokens.durationMedium,
                              ),
                              switchInCurve: MotionTokens.curveAppear,
                              transitionBuilder: (child, animation) =>
                                  SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.4),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                              child: Text(
                                '[$progressPercent%]',
                                key: ValueKey(progressPercent),
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey(progressPercent),
                            tween: Tween<double>(
                              begin: 0,
                              end: totalToday > 0
                                  ? completedToday / totalToday
                                  : 0,
                            ),
                            duration: MotionTokens.getDuration(
                              context,
                              MotionTokens.durationSlow,
                            ),
                            curve: MotionTokens.curveAppear,
                            builder: (context, value, _) =>
                                LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: AppColors.surfaceMuted,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.textPrimary,
                                      ),
                                  minHeight: 3,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Habit Cards
                ...habits.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Dismissible(
                        key: Key(item.habit.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: AppColors.errorSubtle,
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                        ),
                        onDismissed: (_) {
                          final removedHabit = item.habit;
                          ref
                              .read(habitsProvider.notifier)
                              .deleteHabit(removedHabit.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.surfaceElevated,
                              content: Text(
                                'Привычка «${removedHabit.title}» удалена',
                                style: AppTypography.bodySmall,
                              ),
                              action: SnackBarAction(
                                textColor: AppColors.textPrimary,
                                label: 'Отменить',
                                onPressed: () {
                                  ref
                                      .read(habitsProvider.notifier)
                                      .saveHabit(removedHabit);
                                },
                              ),
                            ),
                          );
                        },
                        child: HabitCard(
                          data: item,
                          onTap: () => context.push('/habits/${item.habit.id}'),
                          onToggle: () {
                            ref
                                .read(habitsProvider.notifier)
                                .toggleCompletion(item.habit.id);
                          },
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: MotionTokens.getDuration(
                          context,
                          MotionTokens.durationEntrance,
                        ),
                        delay: MotionTokens.staggerDelay(context, index),
                        curve: MotionTokens.curveAppear,
                      )
                      .slideY(
                        begin: MotionTokens.entranceOffset,
                        end: 0,
                        duration: MotionTokens.getDuration(
                          context,
                          MotionTokens.durationEntrance,
                        ),
                        delay: MotionTokens.staggerDelay(context, index),
                        curve: MotionTokens.curveAppear,
                      );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyHabitsState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyHabitsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Icon(
                Icons.all_inclusive,
                size: 28,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'НЕТ ПРИВЫЧЕК НА СЕГОДНЯ',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Начните формировать постоянство. При случайном пропуске умная автозаморозка защитит вашу серию от сброса.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(
                  color: AppColors.borderHighlight,
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                AppFeedback.selection();
                onAdd();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'СОЗДАТЬ ПРИВЫЧКУ',
                style: AppTypography.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

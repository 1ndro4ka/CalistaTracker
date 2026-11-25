import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../habits/presentation/providers/habits_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('СТАТИСТИКА И СТАБИЛЬНОСТЬ')),
      body: habitsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: Text(
                'Нет данных для статистики. Создайте хотя бы одну привычку.',
                style: AppTypography.bodySmall,
              ),
            );
          }

          // Calculate aggregate metrics
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Large Aggregate Score Card
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
                    Text('$avgStability%', style: AppTypography.statValue),
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

              // Saved Streaks & Best Streak Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'СПАСЕНО СЕРИЙ',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '❄ $totalFreezesUsed',
                            style: AppTypography.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Заморозок в этом месяце',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ЛУЧШАЯ СЕРИЯ',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: 8),
                          Text('$maxStreak д', style: AppTypography.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Максимум среди всех',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly Day Distribution
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _WeekdayBar(label: 'ПН', heightPercent: 0.9),
                    _WeekdayBar(label: 'ВТ', heightPercent: 0.8),
                    _WeekdayBar(label: 'СР', heightPercent: 0.95),
                    _WeekdayBar(label: 'ЧТ', heightPercent: 0.7),
                    _WeekdayBar(label: 'ПТ', heightPercent: 0.85),
                    _WeekdayBar(label: 'СБ', heightPercent: 0.6),
                    _WeekdayBar(label: 'ВС', heightPercent: 0.75),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Habits List Breakdown
              const Text(
                'СТАБИЛЬНОСТЬ ПО ПРИВЫЧКАМ',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 8),
              ...habits.map(
                (h) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          h.habit.title,
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${h.stabilityMetrics.stabilityRate30Days}%',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WeekdayBar extends StatelessWidget {
  final String label;
  final double heightPercent; // 0.0 to 1.0

  const _WeekdayBar({required this.label, required this.heightPercent});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 80 * heightPercent,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}

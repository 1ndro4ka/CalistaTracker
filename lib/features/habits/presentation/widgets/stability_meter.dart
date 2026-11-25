import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class StabilityMeter extends StatelessWidget {
  final double percentage; // 0.0 to 100.0
  final String label;

  const StabilityMeter({
    super.key,
    required this.percentage,
    this.label = 'ИНДЕКС СТАБИЛЬНОСТИ (30 ДНЕЙ)',
  });

  @override
  Widget build(BuildContext context) {
    final clampedRatio = (percentage / 100.0).clamp(0.0, 1.0);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.caption),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: clampedRatio,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.textPrimary,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class StabilityMetrics {
  final double stabilityRate30Days;
  final int totalScheduledDays;
  final int completedDays;
  final int frozenDays;
  final int missedDays;

  const StabilityMetrics({
    required this.stabilityRate30Days,
    required this.totalScheduledDays,
    required this.completedDays,
    required this.frozenDays,
    required this.missedDays,
  });

  const StabilityMetrics.empty()
    : stabilityRate30Days = 0.0,
      totalScheduledDays = 0,
      completedDays = 0,
      frozenDays = 0,
      missedDays = 0;
}

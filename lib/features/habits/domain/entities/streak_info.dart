class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final int freezesUsedThisMonth;
  final int freezesRemaining;
  final DateTime? lastCompletedDate;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.freezesUsedThisMonth,
    required this.freezesRemaining,
    this.lastCompletedDate,
  });

  const StreakInfo.zero({int freezesAllowed = 2})
    : currentStreak = 0,
      longestStreak = 0,
      freezesUsedThisMonth = 0,
      freezesRemaining = freezesAllowed,
      lastCompletedDate = null;
}

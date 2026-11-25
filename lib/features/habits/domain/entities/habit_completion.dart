class HabitCompletion {
  final String id;
  final String habitId;
  final DateTime date;
  final bool isFrozen;
  final DateTime recordedAt;

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
    this.isFrozen = false,
    required this.recordedAt,
  });

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? isFrozen,
    DateTime? recordedAt,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isFrozen: isFrozen ?? this.isFrozen,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}

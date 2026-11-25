enum ScheduleType { everyDay, specificDays }

class HabitSchedule {
  final ScheduleType type;

  /// ISO 8601 day numbers: 1 = Monday, 7 = Sunday
  final List<int> daysOfWeek;

  const HabitSchedule.everyDay()
    : type = ScheduleType.everyDay,
      daysOfWeek = const [1, 2, 3, 4, 5, 6, 7];

  const HabitSchedule.specificDays(this.daysOfWeek)
    : type = ScheduleType.specificDays;

  bool isScheduledFor(DateTime date) {
    if (type == ScheduleType.everyDay) return true;
    return daysOfWeek.contains(date.weekday);
  }
}

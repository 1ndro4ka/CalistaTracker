import 'habit_schedule.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final HabitSchedule schedule;
  final DateTime createdAt;
  final bool isArchived;
  final int targetPerDay;
  final String? reminderTime; // "HH:mm"
  final int monthlyFreezesAllowed;

  const Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.schedule = const HabitSchedule.everyDay(),
    required this.createdAt,
    this.isArchived = false,
    this.targetPerDay = 1,
    this.reminderTime,
    this.monthlyFreezesAllowed = 2,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    HabitSchedule? schedule,
    DateTime? createdAt,
    bool? isArchived,
    int? targetPerDay,
    String? reminderTime,
    int? monthlyFreezesAllowed,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      reminderTime: reminderTime ?? this.reminderTime,
      monthlyFreezesAllowed:
          monthlyFreezesAllowed ?? this.monthlyFreezesAllowed,
    );
  }
}

import 'package:drift/drift.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_schedule.dart';
import '../database/app_database.dart';

abstract final class HabitMapper {
  static Habit toDomain(HabitsTableData data) {
    final scheduleType = data.scheduleType == 'specificDays'
        ? ScheduleType.specificDays
        : ScheduleType.everyDay;
    final daysOfWeek = data.daysOfWeek
        .split(',')
        .where((s) => s.isNotEmpty)
        .map(int.parse)
        .toList();

    return Habit(
      id: data.id,
      title: data.title,
      description: data.description,
      schedule: scheduleType == ScheduleType.specificDays
          ? HabitSchedule.specificDays(daysOfWeek)
          : const HabitSchedule.everyDay(),
      createdAt: data.createdAt,
      isArchived: data.isArchived,
      targetPerDay: data.targetPerDay,
      reminderTime: data.reminderTime,
      monthlyFreezesAllowed: data.monthlyFreezesAllowed,
    );
  }

  static HabitsTableCompanion toCompanion(Habit habit) {
    return HabitsTableCompanion(
      id: Value(habit.id),
      title: Value(habit.title),
      description: Value(habit.description),
      scheduleType: Value(
        habit.schedule.type == ScheduleType.specificDays
            ? 'specificDays'
            : 'everyDay',
      ),
      daysOfWeek: Value(habit.schedule.daysOfWeek.join(',')),
      createdAt: Value(habit.createdAt),
      isArchived: Value(habit.isArchived),
      targetPerDay: Value(habit.targetPerDay),
      reminderTime: Value(habit.reminderTime),
      monthlyFreezesAllowed: Value(habit.monthlyFreezesAllowed),
    );
  }
}

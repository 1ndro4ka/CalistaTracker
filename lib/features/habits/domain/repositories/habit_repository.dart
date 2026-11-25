import '../entities/habit.dart';

abstract interface class HabitRepository {
  Future<List<Habit>> getAllHabits({bool includeArchived = false});
  Future<Habit?> getHabitById(String id);
  Future<void> saveHabit(Habit habit);
  Future<void> deleteHabit(String id);
}

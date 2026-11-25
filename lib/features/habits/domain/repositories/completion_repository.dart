import '../entities/habit_completion.dart';

abstract interface class CompletionRepository {
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId);
  Future<List<HabitCompletion>> getCompletionsByDateRange(
    String habitId,
    DateTime from,
    DateTime to,
  );
  Future<void> addCompletion(HabitCompletion completion);
  Future<void> removeCompletion(String habitId, DateTime date);
  Future<void> removeCompletionsForHabit(String habitId);
}

import '../entities/habit.dart';
import '../repositories/completion_repository.dart';
import '../repositories/habit_repository.dart';

class ManageHabitUseCase {
  final HabitRepository habitRepository;
  final CompletionRepository completionRepository;

  const ManageHabitUseCase({
    required this.habitRepository,
    required this.completionRepository,
  });

  Future<Habit> createOrUpdateHabit(Habit habit) async {
    final trimmedTitle = habit.title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Название привычки не может быть пустым');
    }

    final sanitizedHabit = habit.copyWith(title: trimmedTitle);
    await habitRepository.saveHabit(sanitizedHabit);
    return sanitizedHabit;
  }

  Future<void> archiveHabit(String habitId) async {
    final habit = await habitRepository.getHabitById(habitId);
    if (habit != null) {
      await habitRepository.saveHabit(habit.copyWith(isArchived: true));
    }
  }

  Future<void> deleteHabit(String habitId) async {
    await completionRepository.removeCompletionsForHabit(habitId);
    await habitRepository.deleteHabit(habitId);
  }
}

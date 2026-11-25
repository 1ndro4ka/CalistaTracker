import '../../../../core/utils/clock.dart';
import '../entities/habit_completion.dart';
import '../repositories/completion_repository.dart';

class ToggleCompletionUseCase {
  final CompletionRepository completionRepository;
  final Clock clock;

  const ToggleCompletionUseCase({
    required this.completionRepository,
    this.clock = const SystemClock(),
  });

  Future<bool> execute(
    String habitId,
    DateTime date, {
    bool isFrozen = false,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final existing = await completionRepository.getCompletionsByDateRange(
      habitId,
      normalizedDate,
      normalizedDate,
    );

    if (existing.isNotEmpty) {
      await completionRepository.removeCompletion(habitId, normalizedDate);
      return false; // uncompleted
    } else {
      final completion = HabitCompletion(
        id: '${habitId}_${normalizedDate.millisecondsSinceEpoch}',
        habitId: habitId,
        date: normalizedDate,
        isFrozen: isFrozen,
        recordedAt: clock.now(),
      );
      await completionRepository.addCompletion(completion);
      return true; // completed
    }
  }
}

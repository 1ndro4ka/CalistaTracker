import '../../../../core/utils/clock.dart';
import '../../../habits/domain/entities/freeze_policy.dart';
import '../../../habits/domain/repositories/completion_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../../habits/domain/usecases/apply_auto_freeze_use_case.dart';

/// Удаляет отметки за последние [days] дней и сразу прогоняет автозаморозку.
///
/// Так можно за секунды проверить и «спасение» серии, и обрыв, когда квота
/// заморозок в месяце уже исчерпана.
class SimulateMissedDaysUseCase {
  final HabitRepository habitRepository;
  final CompletionRepository completionRepository;
  final ApplyAutoFreezeUseCase autoFreezeUseCase;
  final Clock clock;

  const SimulateMissedDaysUseCase({
    required this.habitRepository,
    required this.completionRepository,
    required this.autoFreezeUseCase,
    required this.clock,
  });

  /// Возвращает количество созданных заморозок.
  Future<int> execute(String habitId, int days) async {
    final habit = await habitRepository.getHabitById(habitId);
    if (habit == null || days < 1) return 0;

    final today = FreezePolicy.normalize(clock.now());
    for (var daysAgo = 1; daysAgo <= days; daysAgo++) {
      await completionRepository.removeCompletion(
        habitId,
        today.subtract(Duration(days: daysAgo)),
      );
    }

    final completions = await completionRepository.getCompletionsForHabit(
      habitId,
    );
    final result = await autoFreezeUseCase.execute(
      habit,
      completions,
      currentDate: today,
    );
    return result.createdFreezes.length;
  }
}

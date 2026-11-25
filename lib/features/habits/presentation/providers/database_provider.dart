import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/completion_repository_impl.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/repositories/completion_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/apply_auto_freeze_use_case.dart';
import '../../domain/usecases/calculate_stability_index_use_case.dart';
import '../../domain/usecases/calculate_streak_use_case.dart';
import '../../domain/usecases/manage_habit_use_case.dart';
import '../../domain/usecases/toggle_completion_use_case.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HabitRepositoryImpl(db);
});

final completionRepositoryProvider = Provider<CompletionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CompletionRepositoryImpl(db);
});

final calculateStreakUseCaseProvider = Provider<CalculateStreakUseCase>((ref) {
  return const CalculateStreakUseCase();
});

final calculateStabilityUseCaseProvider =
    Provider<CalculateStabilityIndexUseCase>((ref) {
      return const CalculateStabilityIndexUseCase();
    });

final toggleCompletionUseCaseProvider = Provider<ToggleCompletionUseCase>((
  ref,
) {
  final compRepo = ref.watch(completionRepositoryProvider);
  return ToggleCompletionUseCase(completionRepository: compRepo);
});

final manageHabitUseCaseProvider = Provider<ManageHabitUseCase>((ref) {
  final habitRepo = ref.watch(habitRepositoryProvider);
  final compRepo = ref.watch(completionRepositoryProvider);
  return ManageHabitUseCase(
    habitRepository: habitRepo,
    completionRepository: compRepo,
  );
});

final applyAutoFreezeUseCaseProvider = Provider<ApplyAutoFreezeUseCase>((ref) {
  final compRepo = ref.watch(completionRepositoryProvider);
  return ApplyAutoFreezeUseCase(completionRepository: compRepo);
});

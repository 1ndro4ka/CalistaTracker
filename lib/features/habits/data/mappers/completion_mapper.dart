import 'package:drift/drift.dart';

import '../../domain/entities/habit_completion.dart';
import '../database/app_database.dart';

abstract final class CompletionMapper {
  static HabitCompletion toDomain(CompletionsTableData data) {
    return HabitCompletion(
      id: data.id,
      habitId: data.habitId,
      date: data.date,
      isFrozen: data.isFrozen,
      recordedAt: data.recordedAt,
    );
  }

  static CompletionsTableCompanion toCompanion(HabitCompletion completion) {
    return CompletionsTableCompanion(
      id: Value(completion.id),
      habitId: Value(completion.habitId),
      date: Value(completion.date),
      isFrozen: Value(completion.isFrozen),
      recordedAt: Value(completion.recordedAt),
    );
  }
}

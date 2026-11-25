import 'package:drift/drift.dart';

import '../../domain/entities/habit_completion.dart';
import '../../domain/repositories/completion_repository.dart';
import '../database/app_database.dart';
import '../mappers/completion_mapper.dart';

class CompletionRepositoryImpl implements CompletionRepository {
  final AppDatabase database;

  CompletionRepositoryImpl(this.database);

  @override
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    final query = database.select(database.completionsTable)
      ..where((tbl) => tbl.habitId.equals(habitId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);
    final rows = await query.get();
    return rows.map(CompletionMapper.toDomain).toList();
  }

  @override
  Future<List<HabitCompletion>> getCompletionsByDateRange(
    String habitId,
    DateTime from,
    DateTime to,
  ) async {
    final normalizedFrom = DateTime(from.year, from.month, from.day);
    final normalizedTo = DateTime(to.year, to.month, to.day, 23, 59, 59);

    final query = database.select(database.completionsTable)
      ..where(
        (tbl) =>
            tbl.habitId.equals(habitId) &
            tbl.date.isBiggerOrEqualValue(normalizedFrom) &
            tbl.date.isSmallerOrEqualValue(normalizedTo),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);
    final rows = await query.get();
    return rows.map(CompletionMapper.toDomain).toList();
  }

  @override
  Future<void> addCompletion(HabitCompletion completion) async {
    final companion = CompletionMapper.toCompanion(completion);
    await database
        .into(database.completionsTable)
        .insertOnConflictUpdate(companion);
  }

  @override
  Future<void> removeCompletion(String habitId, DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await (database.delete(database.completionsTable)..where(
          (tbl) => tbl.habitId.equals(habitId) & tbl.date.equals(normalized),
        ))
        .go();
  }

  @override
  Future<void> removeCompletionsForHabit(String habitId) async {
    await (database.delete(
      database.completionsTable,
    )..where((tbl) => tbl.habitId.equals(habitId))).go();
  }
}

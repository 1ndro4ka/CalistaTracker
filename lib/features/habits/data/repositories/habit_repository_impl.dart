import 'package:drift/drift.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../database/app_database.dart';
import '../mappers/habit_mapper.dart';

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase database;

  HabitRepositoryImpl(this.database);

  @override
  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final query = database.select(database.habitsTable);
    if (!includeArchived) {
      query.where((tbl) => tbl.isArchived.equals(false));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]);
    final rows = await query.get();
    return rows.map(HabitMapper.toDomain).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final query = database.select(database.habitsTable)
      ..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? HabitMapper.toDomain(row) : null;
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final companion = HabitMapper.toCompanion(habit);
    await database.into(database.habitsTable).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await (database.delete(
      database.habitsTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }
}

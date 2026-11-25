import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../tables/habits_table.dart';
import '../tables/completions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [HabitsTable, CompletionsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Миграция v1 -> v2: индекс для быстрой выборки истории привычки.
        await m.createIndex(idxCompletionsHabitDate);
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'calista_tracker.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

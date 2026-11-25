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
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'calista_tracker.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

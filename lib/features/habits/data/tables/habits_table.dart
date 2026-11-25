import 'package:drift/drift.dart';

class HabitsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get scheduleType => text()();
  TextColumn get daysOfWeek => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get targetPerDay => integer().withDefault(const Constant(1))();
  TextColumn get reminderTime => text().nullable()();
  IntColumn get monthlyFreezesAllowed =>
      integer().withDefault(const Constant(2))();

  @override
  Set<Column> get primaryKey => {id};
}

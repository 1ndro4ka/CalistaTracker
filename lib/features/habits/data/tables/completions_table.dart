import 'package:drift/drift.dart';

/// Составной индекс ускоряет выборку истории привычки за диапазон дат —
/// основной запрос календаря и расчёта серий.
@TableIndex(name: 'idx_completions_habit_date', columns: {#habitId, #date})
class CompletionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isFrozen => boolean().withDefault(const Constant(false))();
  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

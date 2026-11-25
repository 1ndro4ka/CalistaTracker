import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calista_tracker/features/habits/data/database/app_database.dart';
import 'package:calista_tracker/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit.dart';
import 'package:calista_tracker/features/habits/presentation/providers/database_provider.dart';
import 'package:calista_tracker/features/stats/presentation/screens/stats_screen.dart';

void main() {
  testWidgets('StatsScreen shows empty state with padding', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: StatsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Нет данных для статистики. Создайте хотя бы одну привычку.'),
      findsOneWidget,
    );
    await db.close();
  });

  testWidgets('StatsScreen chart opens details on tap', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await HabitRepositoryImpl(db).saveHabit(
      Habit(
        id: 'stats_test',
        title: 'Тестовая привычка',
        createdAt: DateTime(2026, 11, 1),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: StatsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ОБЩИЙ ИНДЕКС СТАБИЛЬНОСТИ'), findsOneWidget);
    expect(find.text('Нажмите на день, чтобы увидеть детали'), findsOneWidget);

    await tester.tap(find.text('ПН').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('ДЕТАЛИ:'), findsOneWidget);
    expect(find.text('Тестовая привычка'), findsWidgets);
    await db.close();
  });
}

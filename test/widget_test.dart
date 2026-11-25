import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calista_tracker/app.dart';
import 'package:calista_tracker/features/habits/data/database/app_database.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit.dart';
import 'package:calista_tracker/features/habits/domain/entities/stability_metrics.dart';
import 'package:calista_tracker/features/habits/domain/entities/streak_info.dart';
import 'package:calista_tracker/features/habits/presentation/providers/database_provider.dart';
import 'package:calista_tracker/features/habits/presentation/providers/habits_provider.dart';
import 'package:calista_tracker/features/habits/presentation/widgets/habit_card.dart';

void main() {
  testWidgets('CalistaApp renders TodayScreen and empty state correctly', (
    WidgetTester tester,
  ) async {
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(testDb)],
        child: const CalistaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CALISTA TRACKER'), findsOneWidget);
    expect(find.text('НЕТ ПРИВЫЧЕК НА СЕГОДНЯ'), findsOneWidget);
    expect(find.text('СОЗДАТЬ ПРИВЫЧКУ'), findsOneWidget);

    await testDb.close();
  });

  testWidgets('HabitCard displays title, streak and triggers callbacks', (
    WidgetTester tester,
  ) async {
    final habit = Habit(
      id: 'h_card_test',
      title: 'Медитация',
      createdAt: DateTime(2026, 11, 1),
      monthlyFreezesAllowed: 2,
    );
    final data = HabitItemViewData(
      habit: habit,
      isCompletedToday: false,
      isScheduledToday: true,
      streakInfo: const StreakInfo(
        currentStreak: 12,
        longestStreak: 20,
        freezesUsedThisMonth: 1,
        freezesRemaining: 1,
      ),
      stabilityMetrics: const StabilityMetrics(
        stabilityRate30Days: 92.5,
        totalScheduledDays: 24,
        completedDays: 22,
        frozenDays: 1,
        missedDays: 1,
      ),
    );

    bool toggled = false;
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitCard(
            data: data,
            onTap: () => tapped = true,
            onToggle: () => toggled = true,
          ),
        ),
      ),
    );

    expect(find.text('Медитация'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('92.5%'), findsOneWidget);
    expect(find.text('❄ 1/2'), findsOneWidget);

    // Tap checkbox
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    expect(toggled || tapped, isTrue);
  });
}

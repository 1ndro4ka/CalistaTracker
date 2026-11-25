import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calista_tracker/features/habits/data/database/app_database.dart';
import 'package:calista_tracker/features/habits/data/repositories/completion_repository_impl.dart';
import 'package:calista_tracker/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_completion.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_schedule.dart';

void main() {
  late AppDatabase database;
  late HabitRepositoryImpl habitRepo;
  late CompletionRepositoryImpl completionRepo;
  final testDate = DateTime(2026, 11, 25);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    habitRepo = HabitRepositoryImpl(database);
    completionRepo = CompletionRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Drift SQLite Repositories Integration Tests', () {
    test('Сохранение и получение привычки из базы данных', () async {
      final habit = Habit(
        id: 'h_sql_1',
        title: 'Утренняя пробежка',
        description: 'В парке',
        schedule: const HabitSchedule.specificDays([1, 3, 5]),
        createdAt: testDate,
        targetPerDay: 1,
        reminderTime: '07:30',
        monthlyFreezesAllowed: 2,
      );

      await habitRepo.saveHabit(habit);

      final loaded = await habitRepo.getHabitById('h_sql_1');
      expect(loaded, isNotNull);
      expect(loaded!.title, 'Утренняя пробежка');
      expect(loaded.description, 'В парке');
      expect(loaded.schedule.type, ScheduleType.specificDays);
      expect(loaded.schedule.daysOfWeek, [1, 3, 5]);
      expect(loaded.reminderTime, '07:30');
      expect(loaded.monthlyFreezesAllowed, 2);
    });

    test('Фильтрация архивированных привычек', () async {
      final habitActive = Habit(
        id: 'h_act',
        title: 'Активная',
        createdAt: testDate,
        isArchived: false,
      );
      final habitArchived = Habit(
        id: 'h_arch',
        title: 'Архивная',
        createdAt: testDate,
        isArchived: true,
      );

      await habitRepo.saveHabit(habitActive);
      await habitRepo.saveHabit(habitArchived);

      final activeOnly = await habitRepo.getAllHabits(includeArchived: false);
      expect(activeOnly.length, 1);
      expect(activeOnly.first.id, 'h_act');

      final all = await habitRepo.getAllHabits(includeArchived: true);
      expect(all.length, 2);
    });

    test('Удаление привычки', () async {
      final habit = Habit(
        id: 'h_to_del',
        title: 'На удаление',
        createdAt: testDate,
      );
      await habitRepo.saveHabit(habit);

      await habitRepo.deleteHabit('h_to_del');
      final loaded = await habitRepo.getHabitById('h_to_del');
      expect(loaded, isNull);
    });

    test(
      'Добавление, выборка по диапазону и удаление отметок выполнения',
      () async {
        final c1 = HabitCompletion(
          id: 'c_1',
          habitId: 'h_1',
          date: DateTime(2026, 11, 23),
          isFrozen: false,
          recordedAt: DateTime(2026, 11, 23, 10, 0),
        );
        final c2 = HabitCompletion(
          id: 'c_2',
          habitId: 'h_1',
          date: DateTime(2026, 11, 24),
          isFrozen: true,
          recordedAt: DateTime(2026, 11, 24, 10, 0),
        );

        await completionRepo.addCompletion(c1);
        await completionRepo.addCompletion(c2);

        // Получение всех для привычки
        final allComps = await completionRepo.getCompletionsForHabit('h_1');
        expect(allComps.length, 2);
        expect(allComps[1].isFrozen, isTrue);

        // Выборка по дате
        final range = await completionRepo.getCompletionsByDateRange(
          'h_1',
          DateTime(2026, 11, 24),
          DateTime(2026, 11, 24),
        );
        expect(range.length, 1);
        expect(range.first.id, 'c_2');

        // Удаление одной отметки
        await completionRepo.removeCompletion('h_1', DateTime(2026, 11, 23));
        final afterRemove = await completionRepo.getCompletionsForHabit('h_1');
        expect(afterRemove.length, 1);
        expect(afterRemove.first.id, 'c_2');

        // Полная очистка для привычки
        await completionRepo.removeCompletionsForHabit('h_1');
        final empty = await completionRepo.getCompletionsForHabit('h_1');
        expect(empty, isEmpty);
      },
    );
  });
}

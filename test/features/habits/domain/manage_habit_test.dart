import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:calista_tracker/core/utils/clock.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit.dart';
import 'package:calista_tracker/features/habits/domain/entities/habit_completion.dart';
import 'package:calista_tracker/features/habits/domain/repositories/completion_repository.dart';
import 'package:calista_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:calista_tracker/features/habits/domain/usecases/manage_habit_use_case.dart';
import 'package:calista_tracker/features/habits/domain/usecases/toggle_completion_use_case.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class MockCompletionRepository extends Mock implements CompletionRepository {}

class FakeHabit extends Fake implements Habit {}

class FakeHabitCompletion extends Fake implements HabitCompletion {}

void main() {
  late MockHabitRepository mockHabitRepo;
  late MockCompletionRepository mockCompletionRepo;
  late ManageHabitUseCase manageUseCase;
  late ToggleCompletionUseCase toggleUseCase;
  late FixedClock clock;
  final testDate = DateTime(2026, 11, 25);

  setUpAll(() {
    registerFallbackValue(FakeHabit());
    registerFallbackValue(FakeHabitCompletion());
  });

  setUp(() {
    mockHabitRepo = MockHabitRepository();
    mockCompletionRepo = MockCompletionRepository();
    clock = FixedClock(testDate);
    manageUseCase = ManageHabitUseCase(
      habitRepository: mockHabitRepo,
      completionRepository: mockCompletionRepo,
    );
    toggleUseCase = ToggleCompletionUseCase(
      completionRepository: mockCompletionRepo,
      clock: clock,
    );
  });

  group('ManageHabitUseCase & ToggleCompletionUseCase', () {
    test(
      '18. Выбрасывает ArgumentError при пустом названии привычки',
      () async {
        final habit = Habit(id: 'h_empty', title: '   ', createdAt: testDate);

        expect(
          () => manageUseCase.createOrUpdateHabit(habit),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      '19. Автоматически обрезает пробелы в названии привычки при сохранении',
      () async {
        final habit = Habit(
          id: 'h_spaces',
          title: '  Бег по утрам  ',
          createdAt: testDate,
        );

        when(() => mockHabitRepo.saveHabit(any())).thenAnswer((_) async {});

        final result = await manageUseCase.createOrUpdateHabit(habit);

        expect(result.title, 'Бег по утрам');
        verify(
          () => mockHabitRepo.saveHabit(
            any(that: predicate<Habit>((h) => h.title == 'Бег по утрам')),
          ),
        ).called(1);
      },
    );

    test('20. Архивирование привычки переводит isArchived в true', () async {
      final habit = Habit(
        id: 'h_1',
        title: 'Чтение',
        createdAt: testDate,
        isArchived: false,
      );

      when(() => mockHabitRepo.getHabitById('h_1'))
          .thenAnswer((_) async => habit);
      when(() => mockHabitRepo.saveHabit(any())).thenAnswer((_) async {});

      await manageUseCase.archiveHabit('h_1');

      verify(
        () => mockHabitRepo.saveHabit(
          any(that: predicate<Habit>((h) => h.isArchived == true)),
        ),
      ).called(1);
    });

    test(
      '21. Удаление привычки удаляет и саму привычку, и историю ее выполнений',
      () async {
        when(() => mockCompletionRepo.removeCompletionsForHabit('h_del'))
            .thenAnswer((_) async {});
        when(() => mockHabitRepo.deleteHabit('h_del')).thenAnswer((_) async {});

        await manageUseCase.deleteHabit('h_del');

        verify(() => mockCompletionRepo.removeCompletionsForHabit('h_del'))
            .called(1);
        verify(() => mockHabitRepo.deleteHabit('h_del')).called(1);
      },
    );

    test(
      '22. Toggle добавляет отметку, если ее не было, и удаляет, если уже была',
      () async {
        // 1. Отметки нет -> добавляем
        when(
          () =>
              mockCompletionRepo.getCompletionsByDateRange('h_1', any(), any()),
        ).thenAnswer((_) async => []);
        when(() => mockCompletionRepo.addCompletion(any()))
            .thenAnswer((_) async {});

        final added = await toggleUseCase.execute('h_1', testDate);
        expect(added, isTrue);
        verify(() => mockCompletionRepo.addCompletion(any())).called(1);

        // 2. Отметка есть -> снимаем
        final existing = HabitCompletion(
          id: 'c_1',
          habitId: 'h_1',
          date: testDate,
          recordedAt: testDate,
        );
        when(
          () =>
              mockCompletionRepo.getCompletionsByDateRange('h_1', any(), any()),
        ).thenAnswer((_) async => [existing]);
        when(() => mockCompletionRepo.removeCompletion('h_1', any()))
            .thenAnswer((_) async {});

        final removed = await toggleUseCase.execute('h_1', testDate);
        expect(removed, isFalse);
        verify(() => mockCompletionRepo.removeCompletion('h_1', any()))
            .called(1);
      },
    );
    test(
      '23. Нажатие на замороженный день превращает его в выполнение',
      () async {
        final frozen = HabitCompletion(
          id: 'frozen_1',
          habitId: 'h_1',
          date: testDate,
          isFrozen: true,
          recordedAt: testDate,
        );
        when(
          () =>
              mockCompletionRepo.getCompletionsByDateRange('h_1', any(), any()),
        ).thenAnswer((_) async => [frozen]);
        when(() => mockCompletionRepo.addCompletion(any()))
            .thenAnswer((_) async {});

        final result = await toggleUseCase.execute('h_1', testDate);

        expect(result, isTrue);
        verify(
          () => mockCompletionRepo.addCompletion(
            any(
              that: predicate<HabitCompletion>(
                (c) => !c.isFrozen && c.habitId == 'h_1',
              ),
            ),
          ),
        ).called(1);
        verifyNever(() => mockCompletionRepo.removeCompletion(any(), any()));
      },
    );
  });
}

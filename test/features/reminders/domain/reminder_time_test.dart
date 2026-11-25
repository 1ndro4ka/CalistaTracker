import 'package:flutter_test/flutter_test.dart';

import 'package:calista_tracker/features/reminders/domain/entities/reminder_time.dart';

void main() {
  group('ReminderTime', () {
    test('1. Парсит корректное время в форматах HH:mm и H:mm', () {
      expect(
        ReminderTime.tryParse('07:30'),
        const ReminderTime(hour: 7, minute: 30),
      );
      expect(
        ReminderTime.tryParse('7:05'),
        const ReminderTime(hour: 7, minute: 5),
      );
      expect(
        ReminderTime.tryParse('23:59'),
        const ReminderTime(hour: 23, minute: 59),
      );
      expect(
        ReminderTime.tryParse('00:00'),
        const ReminderTime(hour: 0, minute: 0),
      );
    });

    test('2. Возвращает null для некорректных значений', () {
      expect(ReminderTime.tryParse(null), isNull);
      expect(ReminderTime.tryParse(''), isNull);
      expect(ReminderTime.tryParse('24:00'), isNull);
      expect(ReminderTime.tryParse('7:5'), isNull);
      expect(ReminderTime.tryParse('утро'), isNull);
    });

    test('3. Сериализуется обратно в каноничный HH:mm', () {
      expect(const ReminderTime(hour: 7, minute: 5).value, '07:05');
      expect(const ReminderTime(hour: 21, minute: 0).value, '21:00');
      expect(const ReminderTime(hour: 7, minute: 30).minutesSinceMidnight, 450);
    });

    test('4. Поддерживает сравнение по значению', () {
      expect(
        const ReminderTime(hour: 9, minute: 15),
        const ReminderTime(hour: 9, minute: 15),
      );
      expect(
        const ReminderTime(hour: 9, minute: 15),
        isNot(const ReminderTime(hour: 9, minute: 16)),
      );
    });
  });
}

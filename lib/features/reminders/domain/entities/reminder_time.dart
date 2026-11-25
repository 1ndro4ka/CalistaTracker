/// Время ежедневного напоминания без привязки к Flutter (`TimeOfDay`).
///
/// Хранится в домене как обычный value object, чтобы парсинг строки `HH:mm`
/// из БД можно было покрыть unit-тестами и переиспользовать в планировщике.
class ReminderTime {
  final int hour;
  final int minute;

  const ReminderTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour <= 23, 'Час должен быть в диапазоне 0..23'),
      assert(
        minute >= 0 && minute <= 59,
        'Минуты должны быть в диапазоне 0..59',
      );

  factory ReminderTime.fromDateTime(DateTime date) =>
      ReminderTime(hour: date.hour, minute: date.minute);

  /// Парсит строку формата `HH:mm` или `H:mm`.
  /// Возвращает `null`, если строка пустая/некорректная — напоминание просто
  /// не будет запланировано, приложение не упадёт.
  static ReminderTime? tryParse(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$')
        .firstMatch(raw.trim());
    if (match == null) return null;

    return ReminderTime(
      hour: int.parse(match.group(1)!),
      minute: int.parse(match.group(2)!),
    );
  }

  int get minutesSinceMidnight => hour * 60 + minute;

  /// Каноничное представление для хранения в БД.
  String get value =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => value;
}

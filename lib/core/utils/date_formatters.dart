abstract final class AppDateFormatter {
  static const List<String> _weekdaysRu = [
    'ПОНЕДЕЛЬНИК',
    'ВТОРНИК',
    'СРЕДА',
    'ЧЕТВЕРГ',
    'ПЯТНИЦА',
    'СУББОТА',
    'ВОСКРЕСЕНЬЕ',
  ];

  static const List<String> _monthsRu = [
    'ЯНВАРЬ',
    'ФЕВРАЛЬ',
    'МАРТ',
    'АПРЕЛЬ',
    'МАЙ',
    'ИЮНЬ',
    'ИЮЛЬ',
    'АВГУСТ',
    'СЕНТЯБРЬ',
    'ОКТЯБРЬ',
    'НОЯБРЬ',
    'ДЕКАБРЬ',
  ];

  static String formatToday(DateTime date) {
    final dayStr = date.day.toString().padLeft(2, '0');
    final monthStr = date.month.toString().padLeft(2, '0');
    final weekdayStr = _weekdaysRu[date.weekday - 1];
    return '$dayStr.$monthStr • $weekdayStr';
  }

  static String formatMonthYear(DateTime date) {
    final monthStr = _monthsRu[date.month - 1];
    return '$monthStr ${date.year}';
  }
}

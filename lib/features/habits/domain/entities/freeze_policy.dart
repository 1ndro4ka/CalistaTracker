import 'dart:math' as math;

import '../../../../core/constants/app_constants.dart';

/// Value object, описывающий правила расходования заморозок серии.
///
/// Политика намеренно не знает ничего о хранилище и UI: она отвечает только
/// на вопрос «можно ли заморозить ещё один день в этом календарном месяце».
class FreezePolicy {
  final int monthlyAllowance;

  const FreezePolicy({
    this.monthlyAllowance = AppConstants.defaultMonthlyFreezes,
  }) : assert(
         monthlyAllowance >= 0,
         'Лимит заморозок не может быть отрицательным',
       );

  /// Можно ли потратить ещё одну заморозку, если в месяце уже использовано
  /// [usedThisMonth] дней.
  bool canFreeze(int usedThisMonth) => usedThisMonth < monthlyAllowance;

  /// Сколько заморозок останется после [usedThisMonth] использованных.
  int remainingAfter(int usedThisMonth) =>
      math.max(0, monthlyAllowance - usedThisMonth);

  /// Ключ календарного месяца вида `2026-11`.
  static String monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// Унифицированная дата без времени — для сравнения дней.
  static DateTime normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

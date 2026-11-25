import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/clock.dart';

/// Единый источник «сегодня» для всего приложения.
///
/// Обычно это системное время, но секретная панель может подменить его ради
/// проверки серий, заморозок и квоты без ожидания реальных дней.
final clockProvider = Provider<FixedClock>((ref) {
  return FixedClock(DateTime.now());
});

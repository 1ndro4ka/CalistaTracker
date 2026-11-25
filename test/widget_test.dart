import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calista_tracker/app.dart';

void main() {
  testWidgets('CalistaApp renders TodayScreen smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CalistaApp()));
    await tester.pumpAndSettle();

    expect(find.text('CALISTA TRACKER'), findsOneWidget);
    expect(find.text('НЕТ ПРИВЫЧЕК НА СЕГОДНЯ'), findsOneWidget);
  });
}

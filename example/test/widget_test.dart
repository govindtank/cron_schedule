import 'package:flutter_test/flutter_test.dart';
import 'package:cron_schedule_example/main.dart';

void main() {
  testWidgets('Cron schedule example app smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CronDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Cron Schedule Parser'), findsOneWidget);
    expect(find.text('Human Translation'), findsOneWidget);
    expect(find.text('Upcoming Occurrences Forecast'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cron_schedule/cron_schedule.dart';

void main() {
  group('CronSchedule Next Occurrence Tests', () {
    test('Calculates next occurrence for daily schedule at 09:00', () {
      final schedule = CronSchedule.parse('0 9 * * *');

      // Given current time is 2026-10-01 08:30:00
      final base = DateTime(2026, 10, 1, 8, 30);
      final next = schedule.next(after: base);

      expect(next, DateTime(2026, 10, 1, 9, 0));
    });

    test('Calculates next occurrence rolling over to next day', () {
      final schedule = CronSchedule.parse('0 9 * * *');

      // Given current time is 2026-10-01 09:15:00
      final base = DateTime(2026, 10, 1, 9, 15);
      final next = schedule.next(after: base);

      expect(next, DateTime(2026, 10, 2, 9, 0));
    });

    test('nextOccurrences returns multiple upcoming timestamps in order', () {
      final schedule = CronSchedule.parse('0 8 * * *');
      final base = DateTime(2026, 10, 1, 0, 0);

      final upcoming = schedule.nextOccurrences(count: 3, after: base);
      expect(upcoming.length, 3);
      expect(upcoming[0], DateTime(2026, 10, 1, 8, 0));
      expect(upcoming[1], DateTime(2026, 10, 2, 8, 0));
      expect(upcoming[2], DateTime(2026, 10, 3, 8, 0));
    });

    test('isDue correctly matches exact timestamp', () {
      final schedule = CronSchedule.parse('30 14 * * *');

      expect(schedule.isDue(DateTime(2026, 10, 1, 14, 30)), isTrue);
      expect(schedule.isDue(DateTime(2026, 10, 1, 14, 31)), isFalse);
    });

    test('toHumanReadable translates expressions into natural language', () {
      final daily = CronSchedule.parse('0 0 * * *');
      expect(daily.toHumanReadable(), contains('midnight'));

      final weekdays = CronSchedule.parse('0 9 * * 1-5');
      expect(weekdays.toHumanReadable(), contains('Monday through Friday'));
    });
  });
}

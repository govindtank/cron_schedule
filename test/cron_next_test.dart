import 'package:test/test.dart';
import 'package:cron_schedule/cron_schedule.dart';

void main() {
  group('CronSchedule Next & Previous Occurrence Tests', () {
    test('Calculates next occurrence for daily schedule at 09:00', () {
      final schedule = CronSchedule.parse('0 9 * * *');
      final base = DateTime(2026, 6, 15, 8, 30);
      final next = schedule.next(after: base);

      expect(next, DateTime(2026, 6, 15, 9, 0));
    });

    test('Calculates previous occurrence for daily schedule at 09:00', () {
      final schedule = CronSchedule.parse('0 9 * * *');
      final base = DateTime(2026, 6, 15, 8, 30);
      final prev = schedule.previous(before: base);

      expect(prev, DateTime(2026, 6, 14, 9, 0));
    });

    test('Calculates next occurrence rolling over to next day', () {
      final schedule = CronSchedule.parse('0 9 * * *');
      final base = DateTime(2026, 6, 15, 9, 30);
      final next = schedule.next(after: base);

      expect(next, DateTime(2026, 6, 16, 9, 0));
    });

    test('nextOccurrences returns multiple upcoming timestamps in order', () {
      final schedule = CronSchedule.parse('0 0 1 * *'); // 1st of month
      final base = DateTime(2026, 1, 1, 12, 0);
      final occurrences = schedule.nextOccurrences(count: 3, after: base);

      expect(occurrences, [
        DateTime(2026, 2, 1, 0, 0),
        DateTime(2026, 3, 1, 0, 0),
        DateTime(2026, 4, 1, 0, 0),
      ]);
    });

    test('isDue correctly matches exact timestamp', () {
      final schedule = CronSchedule.parse('15 14 1 5 *');
      final match = DateTime(2026, 5, 1, 14, 15);
      final noMatch = DateTime(2026, 5, 1, 14, 16);

      expect(schedule.isDue(match), isTrue);
      expect(schedule.isDue(noMatch), isFalse);
    });

    test('toHumanReadable translates expressions into natural language', () {
      expect(CronSchedule.parse('@daily').toHumanReadable(),
          'Every day at midnight (00:00)');
      expect(CronSchedule.parse('@hourly').toHumanReadable(),
          'Every hour on the hour');
      expect(CronSchedule.parse('0 9 * * 1-5').toHumanReadable(),
          'At 09:00, Monday through Friday');
    });
  });
}

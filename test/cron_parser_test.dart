import 'package:flutter_test/flutter_test.dart';
import 'package:cron_schedule/cron_schedule.dart';

void main() {
  group('CronSchedule Parser Unit Tests', () {
    test('Parses 5-field standard expressions', () {
      final schedule = CronSchedule.parse('30 9 * * 1-5');
      expect(schedule.hasSeconds, isFalse);
      expect(schedule.minutes.allowedValues, {30});
      expect(schedule.hours.allowedValues, {9});
      expect(schedule.dayOfWeek.allowedValues, {1, 2, 3, 4, 5});
    });

    test('Parses 6-field seconds-level expressions', () {
      final schedule = CronSchedule.parse('15 30 14 * * *');
      expect(schedule.hasSeconds, isTrue);
      expect(schedule.seconds.allowedValues, {15});
      expect(schedule.minutes.allowedValues, {30});
      expect(schedule.hours.allowedValues, {14});
    });

    test('Parses macros (@daily, @hourly, @weekly, @monthly, @yearly)', () {
      final daily = CronSchedule.parse('@daily');
      expect(daily.hours.allowedValues, {0});
      expect(daily.minutes.allowedValues, {0});

      final hourly = CronSchedule.parse('@hourly');
      expect(hourly.minutes.allowedValues, {0});
      expect(hourly.hours.allowedValues.length, 24);
    });

    test('Parses named month and day aliases (MON-FRI, JAN-DEC)', () {
      final schedule = CronSchedule.parse('0 12 1 JAN-MAR MON,WED,FRI');
      expect(schedule.month.allowedValues, {1, 2, 3});
      expect(schedule.dayOfWeek.allowedValues, {1, 3, 5});
    });

    test('Throws on invalid expression syntax', () {
      expect(() => CronSchedule.parse('invalid expression'),
          throwsFormatException);
      expect(() => CronSchedule.parse('60 * * * *'),
          throwsFormatException); // Minute > 59
    });
  });
}

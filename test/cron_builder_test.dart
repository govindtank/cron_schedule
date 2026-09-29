import 'package:test/test.dart';
import 'package:cron_schedule/cron_schedule.dart';

void main() {
  group('CronScheduleBuilder Unit Tests', () {
    test('Builds daily schedule', () {
      final schedule =
          CronSchedule.builder().daily(hour: 8, minute: 30).build();

      expect(schedule.hours.allowedValues, {8});
      expect(schedule.minutes.allowedValues, {30});
    });

    test('Builds weekdays schedule', () {
      final schedule =
          CronSchedule.builder().weekdays(hour: 9, minute: 0).build();

      expect(schedule.hours.allowedValues, {9});
      expect(schedule.minutes.allowedValues, {0});
      expect(schedule.dayOfWeek.allowedValues, {1, 2, 3, 4, 5});
    });

    test('Builds periodic minute schedule', () {
      final schedule = CronSchedule.builder().everyMinutes(15).build();

      expect(schedule.minutes.allowedValues, {0, 15, 30, 45});
    });
  });
}

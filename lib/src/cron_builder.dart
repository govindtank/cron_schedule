import 'cron_schedule.dart';

/// Days of the week for cron scheduling.
enum CronDay {
  /// Sunday (0)
  sunday(0, 'SUN'),

  /// Monday (1)
  monday(1, 'MON'),

  /// Tuesday (2)
  tuesday(2, 'TUE'),

  /// Wednesday (3)
  wednesday(3, 'WED'),

  /// Thursday (4)
  thursday(4, 'THU'),

  /// Friday (5)
  friday(5, 'FRI'),

  /// Saturday (6)
  saturday(6, 'SAT');

  /// Integer value in cron standard (0-6).
  final int value;

  /// Short alias code.
  final String code;

  const CronDay(this.value, this.code);
}

/// Fluent type-safe builder for constructing [CronSchedule] instances.
class CronScheduleBuilder {
  final String _sec = '0';
  String _min = '*';
  String _hour = '*';
  String _dom = '*';
  String _month = '*';
  String _dow = '*';
  bool _includeSeconds = false;

  /// Enables 6-field seconds-level precision.
  CronScheduleBuilder withSeconds() {
    _includeSeconds = true;
    return this;
  }

  /// Runs every [minutes] minutes.
  CronScheduleBuilder everyMinutes(int minutes) {
    _min = '*/$minutes';
    _hour = '*';
    _dom = '*';
    _month = '*';
    _dow = '*';
    return this;
  }

  /// Runs every [hours] hours.
  CronScheduleBuilder everyHours(int hours, {int minute = 0}) {
    _min = '$minute';
    _hour = '*/$hours';
    _dom = '*';
    _month = '*';
    _dow = '*';
    return this;
  }

  /// Runs daily at the specified [hour] and [minute].
  CronScheduleBuilder daily({int hour = 0, int minute = 0}) {
    _min = '$minute';
    _hour = '$hour';
    _dom = '*';
    _month = '*';
    _dow = '*';
    return this;
  }

  /// Runs weekly on the given [days] at [hour] and [minute].
  CronScheduleBuilder weekly(List<CronDay> days,
      {int hour = 0, int minute = 0}) {
    _min = '$minute';
    _hour = '$hour';
    _dom = '*';
    _month = '*';
    _dow = days.map((d) => d.value.toString()).join(',');
    return this;
  }

  /// Runs every weekday (Monday through Friday) at [hour] and [minute].
  CronScheduleBuilder weekdays({int hour = 9, int minute = 0}) {
    return weekly([
      CronDay.monday,
      CronDay.tuesday,
      CronDay.wednesday,
      CronDay.thursday,
      CronDay.friday,
    ], hour: hour, minute: minute);
  }

  /// Runs monthly on day [dayOfMonth] at [hour] and [minute].
  CronScheduleBuilder monthly(
      {int dayOfMonth = 1, int hour = 0, int minute = 0}) {
    _min = '$minute';
    _hour = '$hour';
    _dom = '$dayOfMonth';
    _month = '*';
    _dow = '*';
    return this;
  }

  /// Builds the compiled [CronSchedule].
  CronSchedule build() {
    final String expr = _includeSeconds
        ? '$_sec $_min $_hour $_dom $_month $_dow'
        : '$_min $_hour $_dom $_month $_dow';
    return CronSchedule.parse(expr);
  }
}

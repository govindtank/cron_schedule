import 'cron_builder.dart';
import 'cron_field.dart';

/// Predefined macro mapping.
const Map<String, String> _cronMacros = {
  '@yearly': '0 0 1 1 *',
  '@annually': '0 0 1 1 *',
  '@monthly': '0 0 1 * *',
  '@weekly': '0 0 * * 0',
  '@daily': '0 0 * * *',
  '@midnight': '0 0 * * *',
  '@hourly': '0 * * * *',
};

const Map<String, int> _dayAliases = {
  'SUN': 0,
  'MON': 1,
  'TUE': 2,
  'WED': 3,
  'THU': 4,
  'FRI': 5,
  'SAT': 6,
  '7': 0, // 7 is Sunday in some cron formats
};

const Map<String, int> _monthAliases = {
  'JAN': 1,
  'FEB': 2,
  'MAR': 3,
  'APR': 4,
  'MAY': 5,
  'JUN': 6,
  'JUL': 7,
  'AUG': 8,
  'SEP': 9,
  'OCT': 10,
  'NOV': 11,
  'DEC': 12,
};

/// A compiled, high-performance cron schedule evaluator, next-occurrence predictor,
/// and human-readable translator for Dart and Flutter.
class CronSchedule {
  /// The canonical cron expression string.
  final String expression;

  /// Whether this expression includes seconds precision (6-field format).
  final bool hasSeconds;

  /// Parsed seconds field (0-59).
  final CronField seconds;

  /// Parsed minutes field (0-59).
  final CronField minutes;

  /// Parsed hours field (0-23).
  final CronField hours;

  /// Parsed day of month field (1-31).
  final CronField dayOfMonth;

  /// Parsed month field (1-12).
  final CronField month;

  /// Parsed day of week field (0-6, Sunday = 0).
  final CronField dayOfWeek;

  /// Private constructor for parsed fields.
  const CronSchedule._({
    required this.expression,
    required this.hasSeconds,
    required this.seconds,
    required this.minutes,
    required this.hours,
    required this.dayOfMonth,
    required this.month,
    required this.dayOfWeek,
  });

  /// Starts a type-safe fluent schedule builder.
  static CronScheduleBuilder builder() => CronScheduleBuilder();

  /// Parses a cron expression string into a [CronSchedule].
  /// Throws [FormatException] if the syntax is invalid.
  factory CronSchedule.parse(String rawExpression) {
    String cleanExpr = rawExpression.trim();
    if (_cronMacros.containsKey(cleanExpr.toLowerCase())) {
      cleanExpr = _cronMacros[cleanExpr.toLowerCase()]!;
    }

    final List<String> parts = cleanExpr.split(RegExp(r'\s+'));
    if (parts.length != 5 && parts.length != 6) {
      throw FormatException(
        'Invalid cron expression "$rawExpression". Must contain 5 or 6 fields, got ${parts.length}',
      );
    }

    final bool hasSeconds = parts.length == 6;
    final int offset = hasSeconds ? 1 : 0;

    final CronField secondsField = hasSeconds
        ? CronField.parse(parts[0], 'seconds', 0, 59)
        : const CronField(name: 'seconds', min: 0, max: 0, allowedValues: {0});

    final CronField minutesField =
        CronField.parse(parts[offset], 'minutes', 0, 59);
    final CronField hoursField =
        CronField.parse(parts[offset + 1], 'hours', 0, 23);
    final CronField domField =
        CronField.parse(parts[offset + 2], 'day-of-month', 1, 31);
    final CronField monthField = CronField.parse(
      parts[offset + 3],
      'month',
      1,
      12,
      aliases: _monthAliases,
    );
    final CronField dowField = CronField.parse(
      parts[offset + 4],
      'day-of-week',
      0,
      6,
      aliases: _dayAliases,
    );

    return CronSchedule._(
      expression: rawExpression,
      hasSeconds: hasSeconds,
      seconds: secondsField,
      minutes: minutesField,
      hours: hoursField,
      dayOfMonth: domField,
      month: monthField,
      dayOfWeek: dowField,
    );
  }

  /// Attempts to parse a cron expression. Returns null if invalid.
  static CronSchedule? tryParse(String expression) {
    try {
      return CronSchedule.parse(expression);
    } catch (_) {
      return null;
    }
  }

  /// Determines if this schedule matches the exact given [dateTime].
  bool isDue(DateTime dateTime) {
    if (hasSeconds && !seconds.matches(dateTime.second)) return false;
    if (!minutes.matches(dateTime.minute)) return false;
    if (!hours.matches(dateTime.hour)) return false;
    if (!month.matches(dateTime.month)) return false;

    final bool domMatches = dayOfMonth.matches(dateTime.day);
    // Convert Dart weekday (1=Mon..7=Sun) to cron standard (0=Sun..6=Sat)
    final int cronDow = dateTime.weekday % 7;
    final bool dowMatches = dayOfWeek.matches(cronDow);

    // If both DOM and DOW are restricted, standard cron evaluates as OR; otherwise AND
    final bool domRestricted = dayOfMonth.allowedValues.length < 31;
    final bool dowRestricted = dayOfWeek.allowedValues.length < 7;

    if (domRestricted && dowRestricted) {
      return domMatches || dowMatches;
    }
    return domMatches && dowMatches;
  }

  /// Computes the exact next occurrence [DateTime] after [after] (defaults to `DateTime.now()`).
  DateTime? next({DateTime? after}) {
    final DateTime start = (after ?? DateTime.now());
    DateTime candidate = hasSeconds
        ? start.add(const Duration(seconds: 1))
        : DateTime(start.year, start.month, start.day, start.hour, start.minute)
            .add(const Duration(minutes: 1));

    // Fast lookahead iteration up to 5 years (max 2,628,000 minutes)
    final DateTime limit = candidate.add(const Duration(days: 365 * 5));

    while (candidate.isBefore(limit)) {
      if (!month.matches(candidate.month)) {
        // Fast-forward to start of next month
        candidate = DateTime(candidate.year, candidate.month + 1, 1);
        continue;
      }

      final int cronDow = candidate.weekday % 7;
      final bool domMatches = dayOfMonth.matches(candidate.day);
      final bool dowMatches = dayOfWeek.matches(cronDow);
      final bool domRestricted = dayOfMonth.allowedValues.length < 31;
      final bool dowRestricted = dayOfWeek.allowedValues.length < 7;
      final bool dayMatches = (domRestricted && dowRestricted)
          ? (domMatches || dowMatches)
          : (domMatches && dowMatches);

      if (!dayMatches) {
        // Fast-forward to start of next day
        candidate =
            DateTime(candidate.year, candidate.month, candidate.day + 1);
        continue;
      }

      if (!hours.matches(candidate.hour)) {
        candidate = DateTime(
            candidate.year, candidate.month, candidate.day, candidate.hour + 1);
        continue;
      }

      if (!minutes.matches(candidate.minute)) {
        candidate = candidate.add(const Duration(minutes: 1));
        continue;
      }

      if (hasSeconds && !seconds.matches(candidate.second)) {
        candidate = candidate.add(const Duration(seconds: 1));
        continue;
      }

      return candidate;
    }

    return null;
  }

  /// Computes a list of the next [count] occurrence timestamps.
  List<DateTime> nextOccurrences({int count = 5, DateTime? after}) {
    final List<DateTime> results = [];
    DateTime cursor = after ?? DateTime.now();

    for (int i = 0; i < count; i++) {
      final nextTime = next(after: cursor);
      if (nextTime == null) break;
      results.add(nextTime);
      cursor = nextTime;
    }

    return results;
  }

  /// Converts the cron schedule into a human-readable English summary.
  String toHumanReadable() {
    final String clean = expression.trim().toLowerCase();
    if (clean == '@daily' || clean == '0 0 * * *')
      return 'Every day at midnight (00:00)';
    if (clean == '@hourly' || clean == '0 * * * *')
      return 'Every hour on the hour';
    if (clean == '@weekly' || clean == '0 0 * * 0')
      return 'Every Sunday at midnight';
    if (clean == '@monthly' || clean == '0 0 1 * *')
      return 'On the first day of every month at midnight';

    final buffer = StringBuffer();

    // Time summary
    if (hours.allowedValues.length == 24 &&
        minutes.allowedValues.length == 60) {
      buffer.write('Every minute');
    } else if (hours.allowedValues.length == 24 &&
        minutes.allowedValues.length == 1) {
      buffer.write('At minute ${minutes.allowedValues.first} past every hour');
    } else {
      final hourStr = hours.allowedValues
          .map((h) => h.toString().padLeft(2, '0'))
          .join(',');
      final minStr = minutes.allowedValues
          .map((m) => m.toString().padLeft(2, '0'))
          .join(',');
      buffer.write('At $hourStr:$minStr');
    }

    // Days of week
    if (dayOfWeek.allowedValues.length == 5 &&
        dayOfWeek.allowedValues.contains(1) &&
        dayOfWeek.allowedValues.contains(5) &&
        !dayOfWeek.allowedValues.contains(0) &&
        !dayOfWeek.allowedValues.contains(6)) {
      buffer.write(', Monday through Friday');
    } else if (dayOfWeek.allowedValues.length < 7) {
      final days = dayOfWeek.allowedValues
          .map((d) => CronDay.values.firstWhere((cd) => cd.value == d).code)
          .join(', ');
      buffer.write(', on $days');
    }

    // Day of Month
    if (dayOfMonth.allowedValues.length < 31) {
      buffer
          .write(', on day ${dayOfMonth.allowedValues.join(',')} of the month');
    }

    return buffer.toString();
  }

  @override
  String toString() => 'CronSchedule($expression)';
}

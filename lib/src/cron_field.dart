/// Represents a parsed single field within a cron expression (seconds, minutes, hours, dom, month, dow).
class CronField {
  /// Name of this field for error reporting (e.g. 'minute', 'day-of-week').
  final String name;

  /// Minimum allowed integer value.
  final int min;

  /// Maximum allowed integer value.
  final int max;

  /// Set of integer values matched by this field.
  final Set<int> allowedValues;

  /// Creates a [CronField].
  const CronField({
    required this.name,
    required this.min,
    required this.max,
    required this.allowedValues,
  });

  /// Parses a cron field token string (e.g. `*`, `*/15`, `1-5`, `1,3,5`, `MON-FRI`).
  factory CronField.parse(String token, String name, int min, int max,
      {Map<String, int>? aliases}) {
    final String clean = token.trim().toUpperCase();
    if (clean.isEmpty) {
      throw FormatException('Empty cron field for $name');
    }

    final Set<int> values = {};

    final List<String> segments = clean.split(',');
    for (final segment in segments) {
      if (segment.isEmpty) {
        continue;
      }

      if (segment == '*') {
        for (int i = min; i <= max; i++) {
          values.add(i);
        }
      } else if (segment.startsWith('*/')) {
        final int step = int.parse(segment.substring(2));
        if (step <= 0) {
          throw FormatException('Invalid step $step in $name');
        }
        for (int i = min; i <= max; i += step) {
          values.add(i);
        }
      } else if (segment.contains('-')) {
        final List<String> rangeParts = segment.split('/');
        final List<String> bounds = rangeParts[0].split('-');
        if (bounds.length != 2) {
          throw FormatException('Invalid range $segment in $name');
        }

        final int start = _resolveValue(bounds[0], min, max, aliases);
        final int end = _resolveValue(bounds[1], min, max, aliases);
        final int step = rangeParts.length > 1 ? int.parse(rangeParts[1]) : 1;

        if (start > end) {
          throw FormatException(
              'Range start $start greater than end $end in $name');
        }

        for (int i = start; i <= end; i += step) {
          values.add(i);
        }
      } else {
        final int val = _resolveValue(segment, min, max, aliases);
        values.add(val);
      }
    }

    return CronField(
      name: name,
      min: min,
      max: max,
      allowedValues: values,
    );
  }

  static int _resolveValue(
      String token, int min, int max, Map<String, int>? aliases) {
    if (aliases != null && aliases.containsKey(token)) {
      return aliases[token]!;
    }
    final int? parsed = int.tryParse(token);
    if (parsed == null || parsed < min || parsed > max) {
      throw FormatException('Value "$token" out of valid bounds [$min, $max]');
    }
    return parsed;
  }

  /// Returns true if the given [value] is matched by this field.
  bool matches(int value) => allowedValues.contains(value);
}

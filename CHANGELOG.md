## 1.1.2

* docs: update centered vector badges and documentation.

## 1.1.1

* Added `MultiCronSchedule` to evaluate multiple cron schedules together and return the earliest upcoming trigger.
* Verified CI/CD workflows.

## 1.1.0

* Converted to pure Dart package (zero Flutter SDK dependency).
* Added `previous({DateTime? before})` method to compute previous occurrences.
* Added explicit `platforms` declaration (Android, iOS, Web, macOS, Windows, Linux).

## 1.0.0

* Initial stable release of `cron_schedule`.
* Strict 5-field and 6-field (seconds-level) cron expression parser.
* Predefined macros support: `@yearly`, `@monthly`, `@weekly`, `@daily`, `@midnight`, `@hourly`.
* Next-occurrence predictor (`next()` and `nextOccurrences(count: N)`).
* Human-readable English natural language summary generator (`toHumanReadable()`).
* Fluent type-safe builder (`CronSchedule.builder()`).
* Interactive example app with real-time expression parsing, presets, and upcoming forecast list.
* 100% test coverage and zero pub.dev warnings.

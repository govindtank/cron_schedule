## 1.0.0

* Initial stable release of `cron_schedule`.
* Strict 5-field and 6-field (seconds-level) cron expression parser.
* Predefined macros support: `@yearly`, `@monthly`, `@weekly`, `@daily`, `@midnight`, `@hourly`.
* Next-occurrence predictor (`next()` and `nextOccurrences(count: N)`).
* Human-readable English natural language summary generator (`toHumanReadable()`).
* Fluent type-safe builder (`CronSchedule.builder()`).
* Interactive example app with real-time expression parsing, presets, and upcoming forecast list.
* 100% test coverage and zero pub.dev warnings.

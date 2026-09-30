# cron_schedule

[![Pub Version](https://img.shields.io/pub/v/cron_schedule.svg?style=flat-square&color=blue)](https://pub.dev/packages/cron_schedule)
[![Pub Points](https://img.shields.io/pub/points/cron_schedule?style=flat-square&color=2E8B57&label=pub%20points)](https://pub.dev/packages/cron_schedule/score)
[![Pub Likes](https://img.shields.io/pub/likes/cron_schedule?style=flat-square)](https://pub.dev/packages/cron_schedule)
[![CI](https://github.com/govindtank/cron_schedule/actions/workflows/ci.yml/badge.svg)](https://github.com/govindtank/cron_schedule/actions)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square)](LICENSE)

A lightweight, high-performance, pure-Dart **cron expression parser**, **next-occurrence timestamp predictor**, **human-readable natural language translator**, and **fluent schedule builder** for Dart and Flutter.

<p align="center">
  <img src="https://raw.githubusercontent.com/govindtank/cron_schedule/main/screenshot.svg" width="750" alt="cron_schedule demo"/>
</p>

---

## ⚡ Why cron_schedule?

When building reminders, background tasks, or scheduling local notifications with `flutter_local_notifications`, developers face common friction points:
1. **Predicting Future Timestamps**: In-memory cron timers don't calculate upcoming execution timestamps. `cron_schedule` calculates the next $N$ future occurrences with microsecond accuracy.
2. **Natural Language Explanation**: Explaining `"0 9 * * 1-5"` in the UI requires messy custom code. `schedule.toHumanReadable()` outputs clean English summaries like `"At 09:00, Monday through Friday"`.
3. **Type-Safe Builder**: Construct complex schedules programmatically without error-prone cron string concatenation.
4. **Zero Dependencies & All 6 Platforms**: Pure Dart implementation that runs natively on iOS, Android, Web, macOS, Windows, and Linux.

---

## 📦 Installation

Add `cron_schedule` to your `pubspec.yaml`:

```yaml
dependencies:
  cron_schedule: ^1.1.1
```

Or run:

```bash
flutter pub add cron_schedule
```

---

## 🚀 Quick Start

### 1. Parse & Predict Next Occurrences

```dart
import 'package:cron_schedule/cron_schedule.dart';

// Parse standard 5-part cron, 6-part seconds, or macros (@daily, @weekly)
final schedule = CronSchedule.parse('0 9 * * 1-5');

// Get the immediate next execution time:
final DateTime? nextRun = schedule.next();
print('Next run: $nextRun');

// Get the next 5 upcoming occurrence timestamps:
final List<DateTime> nextFive = schedule.nextOccurrences(count: 5);
for (final dt in nextFive) {
  print('Upcoming: $dt');
}

// Translate to natural human-readable English:
print(schedule.toHumanReadable()); // "At 09:00, Monday through Friday"
```

---

### 2. Schedule Local Notifications (`flutter_local_notifications`)

```dart
final schedule = CronSchedule.parse('0 8 * * 1,3,5'); // Mon, Wed, Fri at 8 AM
final upcomingDates = schedule.nextOccurrences(count: 4);

for (final date in upcomingDates) {
  // Pass exact future DateTime instances to your notification plugin
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    'Workout Reminder',
    'Time for your morning stretch!',
    tz.TZDateTime.from(date, tz.local),
    notificationDetails,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

---

### 3. Type-Safe Schedule Builder

```dart
// Daily at 08:30
final daily = CronSchedule.builder()
    .daily(hour: 8, minute: 30)
    .build();

// Weekdays (Mon-Fri) at 09:00
final weekdays = CronSchedule.builder()
    .weekdays(hour: 9, minute: 0)
    .build();

// Every 15 minutes
final periodic = CronSchedule.builder()
    .everyMinutes(15)
    .build();
```

---

## 🛠️ API Reference

### `CronSchedule` Methods

| Method | Return Type | Description |
| :--- | :--- | :--- |
| `CronSchedule.parse(String)` | `CronSchedule` | Parses standard 5/6 field expression or macro (`@daily`, `@weekly`). |
| `CronSchedule.tryParse(String)` | `CronSchedule?` | Safe parser returning `null` on syntax error. |
| `next({DateTime? after})` | `DateTime?` | Calculates the single next execution timestamp. |
| `nextOccurrences({int count, DateTime? after})` | `List<DateTime>` | Generates a list of upcoming execution timestamps. |
| `isDue(DateTime)` | `bool` | Checks if the schedule triggers at the exact given timestamp. |
| `toHumanReadable()` | `String` | Formats the cron expression into clear English. |

---

## 👨💻 Author & Maintainer

Developed and maintained by **Govind Tank**.

Issues, feature requests, and pull requests are welcomed on [GitHub](https://github.com/govindtank/cron_schedule)!

---

## 🌐 Ecosystem & Related Packages

Explore complementary production-grade libraries built for high-performance Flutter & Dart development:

| Package | Description | Version |
| :--- | :--- | :--- |
| **[`ambient_backdrop_glow`](https://pub.dev/packages/ambient_backdrop_glow)** | Dynamic ambient background glow and fluid animated mesh gradients from image artwork with OKLab color blending for Flutter. | `^1.1.2` |
| **[`country_mobile_validator`](https://pub.dev/packages/country_mobile_validator)** | Validate mobile numbers per country using real length ranges (8-10, 10-11 digits), mobile-only detection, and a country_code_picker-friendly API. | `^0.2.1` |
| **[`currency_field_formatter`](https://pub.dev/packages/currency_field_formatter)** | Bulletproof Flutter currency TextInputFormatter with exact cursor tracking, backspace handling, Indian Lakhs/Crores, and ISO 4217 presets. | `^1.1.1` |
| **[`flutter_whisper`](https://pub.dev/packages/flutter_whisper)** | On-device speech-to-text transcription using whisper.cpp. Automatic model download, streaming segment results, Android support. | `^0.2.1` |
| **[`offline_outbox`](https://pub.dev/packages/offline_outbox)** | Resilient offline-first outbox and retry queue for Dart and Flutter with disk persistence, exponential backoff, priority scheduling, and deduplication. | `^1.1.1` |
| **[`quote_painter`](https://pub.dev/packages/quote_painter)** | Flutter package for rendering styled text on image/video canvas with gradient fill, stroke, shadow, decorative quotation marks, line badges, and themes. | `^0.2.4` |
| **[`scratch_reveal`](https://pub.dev/packages/scratch_reveal)** | High-performance GPU-accelerated scratch card and scratch-to-reveal canvas widget for Flutter with sub-millisecond bitmask progress tracking. | `^1.1.1` |
| **[`segmented_ring_painter`](https://pub.dev/packages/segmented_ring_painter)** | High-performance segmented circular progress and concentric activity ring widget for Flutter with gradient arcs, rounded caps, gap math, and tap hit-testing. | `^1.1.2` |
| **[`waveform_pro`](https://pub.dev/packages/waveform_pro)** | Production-quality Flutter waveform widget with GPU-accelerated rendering, discrete bars, curved splines, dual-color progress, zoom, markers, and audio peak extraction. | `^1.1.4` |

---

## 📄 License

This package is licensed under the [Apache-2.0 License](LICENSE).

# cron_schedule

<p align="center">
  <a href="https://pub.dev/packages/cron_schedule"><img src="https://img.shields.io/pub/v/cron_schedule.svg?style=flat-square&color=blue" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/cron_schedule/score"><img src="https://img.shields.io/pub/points/cron_schedule?style=flat-square&color=2E8B57&label=pub%20points" alt="Pub Points"></a>
  <a href="https://pub.dev/packages/cron_schedule"><img src="https://img.shields.io/pub/likes/cron_schedule?style=flat-square" alt="Pub Likes"></a>
  <a href="https://github.com/govindtank/cron_schedule/actions"><img src="https://github.com/govindtank/cron_schedule/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square" alt="License"></a>
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

## 💖 Support the Project

If you find this project useful, consider supporting its active maintenance and future development:

<p align="left">
  <a href="https://buymeacoffee.com/govindtanko"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee" /></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/GitHub%20Sponsors-EA4AAA?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Sponsors" /></a>
  <a href="https://www.patreon.com/govindtank"><img src="https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Patreon" /></a>
</p>

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

*Maintained with ❤️ by [Govind Tank](https://github.com/govindtank).*

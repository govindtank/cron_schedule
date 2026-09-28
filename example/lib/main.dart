import 'package:flutter/material.dart';
import 'package:cron_schedule/cron_schedule.dart';

void main() {
  runApp(const CronDemoApp());
}

class CronDemoApp extends StatelessWidget {
  const CronDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cron Schedule Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const CronDemoScreen(),
    );
  }
}

class CronDemoScreen extends StatefulWidget {
  const CronDemoScreen({super.key});

  @override
  State<CronDemoScreen> createState() => _CronDemoScreenState();
}

class _CronDemoScreenState extends State<CronDemoScreen> {
  final TextEditingController _controller =
      TextEditingController(text: '0 9 * * 1-5');
  CronSchedule? _schedule;
  String? _errorMessage;

  final List<Map<String, String>> _presets = [
    {'label': 'Weekdays 9 AM', 'expr': '0 9 * * 1-5'},
    {'label': 'Every 15 Mins', 'expr': '*/15 * * * *'},
    {'label': 'Daily Midnight', 'expr': '@daily'},
    {'label': 'Every Sunday', 'expr': '0 0 * * 0'},
    {'label': '1st of Month', 'expr': '0 0 1 * *'},
  ];

  @override
  void initState() {
    super.initState();
    _parseExpression(_controller.text);
  }

  void _parseExpression(String text) {
    try {
      final parsed = CronSchedule.parse(text);
      setState(() {
        _schedule = parsed;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _schedule = null;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> upcoming = _schedule?.nextOccurrences(count: 6) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cron Schedule Parser',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expression Input Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cron Expression',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF38BDF8)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onChanged: _parseExpression,
                  ),
                  const SizedBox(height: 14),

                  // Presets
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _presets.map((preset) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(preset['label']!,
                                style: const TextStyle(fontSize: 11)),
                            backgroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFF334155)),
                            onPressed: () {
                              _controller.text = preset['expr']!;
                              _parseExpression(preset['expr']!);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Human Translation Banner
            if (_schedule != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.record_voice_over,
                        color: Color(0xFF10B981), size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Human Translation',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6EE7B7),
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            _schedule!.toHumanReadable(),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Upcoming Next N Occurrences List
              const Text('Upcoming Occurrences Forecast',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...upcoming.asMap().entries.map((entry) {
                final int idx = entry.key;
                final DateTime dt = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              shape: BoxShape.circle,
                            ),
                            child: Text('${idx + 1}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF38BDF8))),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(dt),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        _formatTime(dt),
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF38BDF8)),
                      ),
                    ],
                  ),
                );
              }),
            ] else if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                ),
                child: Text(_errorMessage!,
                    style: const TextStyle(
                        color: Color(0xFFFCA5A5), fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return '${days[dt.weekday % 7]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

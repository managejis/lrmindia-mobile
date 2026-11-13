import 'package:flutter/material.dart';

import '../notifications.dart';
import '../settings.dart';
import '../theme.dart';

/// Theme colour and font size.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final s = AppSettings.instance;
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(padding: const EdgeInsets.all(20), children: [
            const Text('Theme colour', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Brand.heading)),
            const SizedBox(height: 12),
            Wrap(spacing: 14, runSpacing: 14, children: [
              for (final e in AppSettings.palette.entries)
                Semantics(
                  label: e.key,
                  button: true,
                  child: GestureDetector(
                    onTap: () => s.setColor(e.value),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: e.value,
                        shape: BoxShape.circle,
                        border: Border.all(color: Brand.accent.value == e.value.value ? Brand.heading : Colors.transparent, width: 3),
                      ),
                      child: Brand.accent.value == e.value.value ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 30),
            const Text('Font size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Brand.heading)),
            Row(children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: s.fontScale,
                  min: AppSettings.minScale,
                  max: AppSettings.maxScale,
                  divisions: 13,
                  label: '${(s.fontScale * 100).round()}%',
                  onChanged: s.setFontScale,
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 26)),
            ]),
            Center(child: Text('${(s.fontScale * 100).round()}%', style: TextStyle(color: Colors.grey.shade600))),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Brand.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Preview', style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(height: 6),
                Text('In the beginning God created the heavens and the earth.', style: TextStyle(fontSize: 16.5, height: 1.6)),
                SizedBox(height: 4),
                Text('आदि में परमेश्वर ने आकाश और पृथ्वी की सृष्टि की।', style: TextStyle(fontSize: 16.5, height: 1.6)),
                SizedBox(height: 4),
                Text('ಆದಿಯಲ್ಲಿ ದೇವರು ಆಕಾಶವನ್ನೂ ಭೂಮಿಯನ್ನೂ ಸೃಷ್ಟಿಸಿದನು.', style: TextStyle(fontSize: 16.5, height: 1.6)),
              ]),
            ),
            const SizedBox(height: 30),
            const Text('Sunday class alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Brand.heading)),
            const SizedBox(height: 4),
            Text('A weekly reminder to prepare for your Sunday School class. It also tells you the next lesson you have not completed.',
                style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: Brand.accent,
              title: const Text('Remind me every week'),
              value: s.alertOn,
              onChanged: (v) async {
                if (v && !await Notifier.requestPermission()) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications are blocked. Allow them for this app in your phone settings.')));
                  }
                  return;
                }
                await s.setAlert(on: v);
                await Notifier.refresh();
              },
            ),
            if (s.alertOn) ...[
              Row(children: [
                const Expanded(child: Text('Day')),
                DropdownButton<int>(
                  value: s.alertWeekday,
                  items: const [
                    DropdownMenuItem(value: DateTime.monday, child: Text('Monday')),
                    DropdownMenuItem(value: DateTime.tuesday, child: Text('Tuesday')),
                    DropdownMenuItem(value: DateTime.wednesday, child: Text('Wednesday')),
                    DropdownMenuItem(value: DateTime.thursday, child: Text('Thursday')),
                    DropdownMenuItem(value: DateTime.friday, child: Text('Friday')),
                    DropdownMenuItem(value: DateTime.saturday, child: Text('Saturday')),
                    DropdownMenuItem(value: DateTime.sunday, child: Text('Sunday')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    await s.setAlert(weekday: v);
                    await Notifier.refresh();
                  },
                ),
              ]),
              Row(children: [
                const Expanded(child: Text('Time')),
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(TimeOfDay(hour: s.alertHour, minute: s.alertMinute).format(context)),
                  onPressed: () async {
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: s.alertHour, minute: s.alertMinute));
                    if (t == null) return;
                    await s.setAlert(hour: t.hour, minute: t.minute);
                    await Notifier.refresh();
                  },
                ),
              ]),
              const SizedBox(height: 4),
              Text('Tip: Saturday evening gives you time to prepare for Sunday.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(onPressed: s.resetLook, icon: const Icon(Icons.restart_alt), label: const Text('Reset to default')),
          ]),
        );
      },
    );
  }
}

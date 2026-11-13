import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'data/local_db.dart';
import 'settings.dart';

/// The weekly "Sunday class preparation" reminder (Settings > Sunday class alert).
class Notifier {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _id = 101;
  static bool _ready = false;

  static Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }
    await _plugin.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
    _ready = true;
  }

  /// Android 13+ asks the user for permission. Returns false when the user says no.
  static Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return (await android?.requestNotificationsPermission()) ?? true;
  }

  /// Plans (or cancels) the reminder to match the current settings. Safe to call any time.
  static Future<void> refresh() async {
    try {
      await _init();
      final s = AppSettings.instance;
      await _plugin.cancel(_id);
      if (!s.alertOn) return;

      var body = 'Time to prepare for the Sunday School class.';
      final next = await LocalDb.instance.nextLesson(s.lastLang);
      if (next != null) body = 'Next lesson: Book ${next.bookNo} · Lesson ${next.lessonNo} – ${next.titleNative}';

      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, s.alertHour, s.alertMinute);
      while (when.weekday != s.alertWeekday || !when.isAfter(now)) {
        when = when.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        _id,
        'Sunday class preparation',
        body,
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails('sunday_prep', 'Sunday class preparation',
              channelDescription: 'Weekly reminder to prepare for the Sunday School class',
              importance: Importance.high, priority: Priority.high),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,   // repeats every week
      );
    } catch (_) {/* never block the app because of a reminder */}
  }
}

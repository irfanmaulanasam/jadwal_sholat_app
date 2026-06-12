import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_day.dart';

class PrayerNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleToday({
    required PrayerDay day,
    required bool isMale,
  }) async {
    await _plugin.cancelAll();

    await _schedule(
      id: 1,
      name: 'Subuh',
      time: day.fajr,
      reminderMinutes: 10,
    );

    await _schedule(
      id: 2,
      name: _middayName(isMale),
      time: day.dhuhr,
      reminderMinutes: _middayReminderMinutes(isMale),
    );

    await _schedule(
      id: 3,
      name: 'Ashar',
      time: day.asr,
      reminderMinutes: 10,
    );

    await _schedule(
      id: 4,
      name: 'Maghrib',
      time: day.maghrib,
      reminderMinutes: 10,
    );

    await _schedule(
      id: 5,
      name: 'Isya',
      time: day.isha,
      reminderMinutes: 10,
    );
  }

  String _middayName(bool isMale) {
    final isFriday = DateTime.now().weekday == DateTime.friday;

    if (isFriday && isMale) {
      return 'Jumat';
    }

    return 'Dzuhur';
  }

  int _middayReminderMinutes(bool isMale) {
    final isFriday = DateTime.now().weekday == DateTime.friday;

    if (isFriday && isMale) {
      return 30;
    }

    return 10;
  }

  Future<void> _schedule({
    required int id,
    required String name,
    required String time,
    required int reminderMinutes,
  }) async {
    final prayerTime = _parseTodayTime(time);
    final notificationTime =
        prayerTime.subtract(Duration(minutes: reminderMinutes));

    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      id,
      'Pengingat Sholat',
      '$name $reminderMinutes menit lagi',
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Pengingat Sholat',
          channelDescription: 'Notifikasi sebelum waktu sholat',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  DateTime _parseTodayTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
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

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleToday({
    required PrayerDay day,
    required bool isMale,
    required int offsetMinutes,
  }) async {
    await _plugin.cancelAll();

    await _schedule(
      id: 1,
      name: 'Subuh',
      time: day.subuh,
      reminderMinutes: 10,
      offsetMinutes: offsetMinutes,
    );

    await _schedule(
      id: 2,
      name: _middayName(isMale),
      time: day.dzuhur,
      reminderMinutes: _middayReminderMinutes(isMale),
      offsetMinutes: offsetMinutes,
    );

    await _schedule(
      id: 3,
      name: 'Ashar',
      time: day.ashar,
      reminderMinutes: 10,
      offsetMinutes: offsetMinutes,
    );

    await _schedule(
      id: 4,
      name: 'Maghrib',
      time: day.maghrib,
      reminderMinutes: 10,
      offsetMinutes: offsetMinutes,
    );

    await _schedule(
      id: 5,
      name: 'Isya',
      time: day.isya,
      reminderMinutes: 10,
      offsetMinutes: offsetMinutes,
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

  Future<void> showTestNotificationInSeconds({
    required int seconds,
  }) async {
    final scheduledTime = DateTime.now().add(
      Duration(seconds: seconds),
    );

    await _plugin.zonedSchedule(
      999,
      'Test Scheduled Notification',
      'Kalau ini muncul, scheduled notification sudah jalan.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_channel',
          'Debug Notification',
          channelDescription: 'Channel untuk test notifikasi',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showInstantTestNotification() async {
    await _plugin.show(
      998,
      'Test Notifikasi Langsung',
      'Kalau ini muncul, berarti permission dan channel aman.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_channel',
          'Debug Notification',
          channelDescription: 'Channel untuk test notifikasi',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }
  Future<void> _schedule({
    required int id,
    required String name,
    required String time,
    required int reminderMinutes,
    required int offsetMinutes,
  }) async {
    final prayerTime = _parseTodayTime(time).add(
      Duration(minutes: offsetMinutes),
    );

    final notificationTime = prayerTime.subtract(
      Duration(minutes: reminderMinutes),
    );

    final now = DateTime.now();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel',
        'Pengingat Sholat',
        channelDescription: 'Notifikasi sebelum waktu sholat',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      ),
    );

    if (notificationTime.isAfter(now)) {
      await _plugin.zonedSchedule(
        id,
        'Pengingat Sholat',
        '$name $reminderMinutes menit lagi',
        tz.TZDateTime.from(notificationTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return;
    }

    if (prayerTime.isAfter(now)) {
      await _plugin.show(
        id,
        'Pengingat Sholat',
        '$name sudah dekat. Masuk waktu pukul ${_formatTime(prayerTime)}',
        details,
      );
      return;
    }
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
  Future<String> getPendingDebugText() async {
    final pending = await _plugin.pendingNotificationRequests();

    if (pending.isEmpty) {
      return 'Tidak ada notifikasi terjadwal.';
    }

    return pending.map((item) {
      return 'ID: ${item.id}\nTitle: ${item.title}\nBody: ${item.body}';
    }).join('\n\n');
  }
  Future<void> showTestNotificationInMinutes({
    required int minutes,
  }) async {
    final scheduledTime = DateTime.now().add(
      Duration(minutes: minutes),
    );

    await _plugin.zonedSchedule(
      1000 + minutes,
      'Test Notification',
      'Notif test $minutes menit',
      tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_channel',
          'Debug Notification',
          channelDescription: 'Debug Notification',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
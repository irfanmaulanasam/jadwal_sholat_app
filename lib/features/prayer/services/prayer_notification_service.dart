import 'package:flutter/material.dart';
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

  Future<void> scheduleUpcomingDays({
    required List<PrayerDay> days,
    required bool isMale,
    int numberOfDays = 7,
  }) async {
    await _plugin.cancelAll();

    final today = DateTime.now();

    final upcomingDays = days.where((day) {
      final date = _parseDate(day.tanggalLengkap);
      final cleanToday = DateTime(today.year, today.month, today.day);
      return !date.isBefore(cleanToday);
    }).take(numberOfDays);

    int notificationId = 1;

    for (final day in upcomingDays) {
      await _schedulePrayerDay(
        day: day,
        isMale: isMale,
        startId: notificationId,
      );

      notificationId += 10;
    }
    final pending =
    await _plugin.pendingNotificationRequests();
    
    debugPrint(
      'TOTAL SCHEDULED: ${pending.length}',
    );
  }

  Future<void> _schedulePrayerDay({
    required PrayerDay day,
    required bool isMale,
    required int startId,
  }) async {
    final isFriday = day.hari.toLowerCase() == 'jumat';
    final middayName = isFriday && isMale ? 'Jumat' : 'Dzuhur';
    final middayReminder = isFriday && isMale ? 30 : 10;

    await _scheduleForDate(
      id: startId,
      name: 'Subuh',
      date: day.tanggalLengkap,
      time: day.subuh,
      reminderMinutes: 10,
    );

    await _scheduleForDate(
      id: startId + 1,
      name: middayName,
      date: day.tanggalLengkap,
      time: day.dzuhur,
      reminderMinutes: middayReminder,
    );

    await _scheduleForDate(
      id: startId + 2,
      name: 'Ashar',
      date: day.tanggalLengkap,
      time: day.ashar,
      reminderMinutes: 10,
    );

    await _scheduleForDate(
      id: startId + 3,
      name: 'Maghrib',
      date: day.tanggalLengkap,
      time: day.maghrib,
      reminderMinutes: 10,
    );

    await _scheduleForDate(
      id: startId + 4,
      name: 'Isya',
      date: day.tanggalLengkap,
      time: day.isya,
      reminderMinutes: 10,
    );
  }

  Future<void> _scheduleForDate({
    required int id,
    required String name,
    required String date,
    required String time,
    required int reminderMinutes,
  }) async {
    final prayerTime = _parsePrayerDateTime(date, time);

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
    }
  }

  DateTime _parsePrayerDateTime(String date, String time) {
    final dateParts = date.split('-');

    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    final timeParts = time.split(':');

    return DateTime(
      year,
      month,
      day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  DateTime _parseDate(String date) {
    final parts = date.split('-');

    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> showInstantTestNotification() async {
    await _plugin.show(
      998,
      'Test Notifikasi Langsung',
      'Kalau ini muncul, permission dan channel aman.',
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
      tz.TZDateTime.from(scheduledTime, tz.local),
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
}
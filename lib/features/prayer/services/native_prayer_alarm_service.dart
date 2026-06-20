import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_day.dart';

class NativePrayerAlarmService {
  static const _channel = MethodChannel('prayer_widget_channel');

  Future<void> scheduleUpcomingDays({
    required List<PrayerDay> days,
    required bool isMale,
    int numberOfDays = 7,
  }) async {
    final now = DateTime.now();
    final cleanToday = DateTime(now.year, now.month, now.day);
    final debugItems = <String>[];
    final rawItems = <String>[];

    final upcomingDays = days.where((day) {
      final date = _parseDate(day.tanggalLengkap);
      return !date.isBefore(cleanToday);
    }).take(numberOfDays);

    for (final day in upcomingDays) {
      final isFriday = day.hari.toLowerCase() == 'jumat';
      final middayName = isFriday && isMale ? 'Jumat' : 'Dzuhur';
      final middayReminder = isFriday && isMale ? 30 : 10;

      final prayers = [
        _PrayerAlarmData('Subuh', day.subuh, 10),
        _PrayerAlarmData(middayName, day.dzuhur, middayReminder),
        _PrayerAlarmData('Ashar', day.ashar, 10),
        _PrayerAlarmData('Maghrib', day.maghrib, 10),
        _PrayerAlarmData('Isya', day.isya, 10),
      ];

      for (final prayer in prayers) {
        final prayerTime = _parsePrayerDateTime(
          day.tanggalLengkap,
          prayer.time,
        );

        final triggerAt = prayerTime.subtract(
          Duration(minutes: prayer.reminderMinutes),
        );

        if (triggerAt.isAfter(now)) {
          await _channel.invokeMethod(
            'scheduleNativePrayerAlarm',
            {
              'triggerAt': triggerAt.millisecondsSinceEpoch,
              'prayerName': prayer.name,
              'prayerTime': prayer.time,
            },
          );

          rawItems.add(
            '${triggerAt.millisecondsSinceEpoch}|${prayer.name}|${prayer.time}',
          );

          debugItems.add(
            '${prayer.name} | notif ${_formatTime(triggerAt)} | sholat ${prayer.time}',
          );
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'native_prayer_alarm_triggers',
      rawItems.join(';;'),
    );

    await prefs.setStringList(
      'debug_scheduled_notifications',
      debugItems,
    );
  }

  DateTime _parsePrayerDateTime(
    String date,
    String time,
  ) {
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
}

class _PrayerAlarmData {
  final String name;
  final String time;
  final int reminderMinutes;

  const _PrayerAlarmData(
    this.name,
    this.time,
    this.reminderMinutes,
  );
}
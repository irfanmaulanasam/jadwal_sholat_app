import 'package:jadwal_sholat_app/features/prayer/models/prayer_status.dart';

import '../models/prayer_day.dart';

class PrayerStatusHelper {
  static PrayerStatus getStatus(
    PrayerDay today,
    bool isMale,
  ) {
    final now = DateTime.now();

    final prayers = [
      ('Subuh', today.subuh),
      ('Dhuha', today.dhuha),
      (_middayName(isMale), today.dzuhur),
      ('Ashar', today.ashar),
      ('Maghrib', today.maghrib),
      ('Isya', today.isya),
    ];

    final prayerTimes = prayers.map((prayer) {
      final parts = prayer.$2.split(':');

      return (
        prayer.$1,
        prayer.$2,
        DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        ),
      );
    }).toList();

    for (int i = 0; i < prayerTimes.length; i++) {
      final current = prayerTimes[i];

      final next = i == prayerTimes.length - 1
          ? prayerTimes[0]
          : prayerTimes[i + 1];

      final nextTime = i == prayerTimes.length - 1
          ? next.$3.add(const Duration(days: 1))
          : next.$3;

      if (now.isBefore(current.$3)) {
        final previous =
            i == 0 ? prayerTimes.last : prayerTimes[i - 1];

        return PrayerStatus(
          currentPrayerName: previous.$1,
          currentPrayerTime: previous.$2,
          nextPrayerName: current.$1,
          nextPrayerTime: current.$2,
        );
      }

      if (now.isAfter(current.$3) &&
          now.isBefore(nextTime)) {
        return PrayerStatus(
          currentPrayerName: current.$1,
          currentPrayerTime: current.$2,
          nextPrayerName: next.$1,
          nextPrayerTime: next.$2,
        );
      }
    }

    return PrayerStatus(
      currentPrayerName: 'Isya',
      currentPrayerTime: today.isya,
      nextPrayerName: 'Subuh',
      nextPrayerTime: today.subuh,
    );
  }

  static String _middayName(bool isMale) {
    final isFriday =
        DateTime.now().weekday == DateTime.friday;

    if (isFriday && isMale) {
      return 'Jumat';
    }

    return 'Dzuhur';
  }
}
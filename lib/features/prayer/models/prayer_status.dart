class PrayerStatus {
  final String currentPrayerName;
  final String currentPrayerTime;

  final String nextPrayerName;
  final String nextPrayerTime;

  const PrayerStatus({
    required this.currentPrayerName,
    required this.currentPrayerTime,
    required this.nextPrayerName,
    required this.nextPrayerTime,
  });
}
class PrayerDay {
  final String date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerDay({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerDay.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'];
    final gregorian = json['date']['gregorian'];

    String clean(String value) {
      return value.split(' ').first;
    }

    return PrayerDay(
      date: gregorian['date'], // format: 12-06-2026
      fajr: clean(timings['Fajr']),
      sunrise: clean(timings['Sunrise']),
      dhuhr: clean(timings['Dhuhr']),
      asr: clean(timings['Asr']),
      maghrib: clean(timings['Maghrib']),
      isha: clean(timings['Isha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  factory PrayerDay.fromCache(Map<String, dynamic> json) {
    return PrayerDay(
      date: json['date'],
      fajr: json['fajr'],
      sunrise: json['sunrise'],
      dhuhr: json['dhuhr'],
      asr: json['asr'],
      maghrib: json['maghrib'],
      isha: json['isha'],
    );
  }
}
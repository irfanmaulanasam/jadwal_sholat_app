class PrayerDay {
  final int tanggal;
  final String tanggalLengkap;
  final String hari;

  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  PrayerDay({
    required this.tanggal,
    required this.tanggalLengkap,
    required this.hari,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory PrayerDay.fromEquranJson(Map<String, dynamic> json) {
    return PrayerDay(
      tanggal: json['tanggal'],
      tanggalLengkap: json['tanggal_lengkap'],
      hari: json['hari'],
      imsak: json['imsak'],
      subuh: json['subuh'],
      terbit: json['terbit'],
      dhuha: json['dhuha'],
      dzuhur: json['dzuhur'],
      ashar: json['ashar'],
      maghrib: json['maghrib'],
      isya: json['isya'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'tanggal_lengkap': tanggalLengkap,
      'hari': hari,
      'imsak': imsak,
      'subuh': subuh,
      'terbit': terbit,
      'dhuha': dhuha,
      'dzuhur': dzuhur,
      'ashar': ashar,
      'maghrib': maghrib,
      'isya': isya,
    };
  }

  factory PrayerDay.fromCache(Map<String, dynamic> json) {
    return PrayerDay.fromEquranJson(json);
  }
}
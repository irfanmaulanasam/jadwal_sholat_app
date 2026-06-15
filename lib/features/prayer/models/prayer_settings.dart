class PrayerSettings {
  final bool onboardingDone;
  final bool isMale;

  final String provinceName;
  final String cityName;
  final int minuteOffset;

  const PrayerSettings({
    required this.onboardingDone,
    required this.isMale,
    required this.provinceName,
    required this.cityName,
    required this.minuteOffset,
  });

  factory PrayerSettings.defaultValue() {
    return const PrayerSettings(
      onboardingDone: false,
      isMale: true,
      provinceName: 'Jawa Barat',
      cityName: 'Kab. Cianjur',
      minuteOffset: 0,
    );
  }

  PrayerSettings copyWith({
    bool? onboardingDone,
    bool? isMale,
    String? provinceName,
    String? cityName,
    int? minuteOffset,
  }) {
    return PrayerSettings(
      onboardingDone: onboardingDone ?? this.onboardingDone,
      isMale: isMale ?? this.isMale,
      provinceName: provinceName ?? this.provinceName,
      cityName: cityName ?? this.cityName,
      minuteOffset: minuteOffset ?? this.minuteOffset,
    );
  }
}
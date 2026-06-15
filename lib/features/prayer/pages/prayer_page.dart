import 'package:flutter/material.dart';
import 'package:jadwal_sholat_app/features/prayer/helpers/hijr_date_helpers.dart';
import 'package:jadwal_sholat_app/features/prayer/pages/monthy_prayer_page.dart';
import 'package:jadwal_sholat_app/features/prayer/pages/travel_page.dart';
import '../models/prayer_day.dart';
import '../models/prayer_settings.dart';
import '../services/prayer_api_service.dart'; 
import '../services/prayer_notification_service.dart';
import '../services/prayer_settings_service.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  final _apiService = PrayerApiService();
  // final _cacheService = PrayerCacheService();
  final _settingsService = PrayerSettingsService();
  final _notificationService = PrayerNotificationService();

  bool _loading = true;
  String? _error;

  PrayerSettings? _settings;
  List<PrayerDay> _days = [];
  
  String _applyOffset(String time) {
    final offset = _settings?.minuteOffset ?? 0;
    final parts = time.split(':');
    final now = DateTime.now();

    final adjusted = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    ).add(Duration(minutes: offset));

    return '${adjusted.hour.toString().padLeft(2, '0')}:${adjusted.minute.toString().padLeft(2, '0')}';
  }

  String _todayTitle() {
    final now = DateTime.now();

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];

    return '$dayName, ${now.day} $monthName ${now.year}';
  }
  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _notificationService.init();
    await _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final settings = await _settingsService.load();
      final now = DateTime.now();

      final freshDays = await _apiService.fetchMonthlyPrayerTimes(
        provinceName: settings.provinceName,
        cityName: settings.cityName,
        month: now.month,
        year: now.year,
      );

      final today = _findTodayPrayer(freshDays);

      if (today != null) {
        await _notificationService.scheduleToday(
          day: today,
          isMale: settings.isMale,
          offsetMinutes: settings.minuteOffset,
        );
      }

      if (!mounted) return;

      setState(() {
        _settings = settings;
        _days = freshDays;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Gagal mengambil jadwal: $e';
        _loading = false;
      });
    }
  }

  PrayerDay? _findTodayPrayer(List<PrayerDay> days) {
    final now = DateTime.now();
    final todayKey =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      return days.firstWhere((day) => day.tanggalLengkap == todayKey);
    } catch (_) {
      return days.isNotEmpty ? days.first : null;
    }
  }

  PrayerDay? get todayPrayer {
    return _findTodayPrayer(_days);
  }

  String getMiddayLabel(PrayerDay today) {
    final isFriday = today.hari.toLowerCase() == 'jumat';
    final isMale = _settings?.isMale ?? true;

    if (isFriday && isMale) {
      return 'Jumat';
    }

    return 'Dzuhur';
  }

  @override
  Widget build(BuildContext context) {
    final today = todayPrayer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        actions: [
          IconButton(
            tooltip: 'Mode perjalanan',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TravelPage(),
                ),
              );

              setState(() {
                _loading = true;
                _error = null;
              });

              await _loadPrayerTimes();
            },
            icon: const Icon(Icons.travel_explore),
          ),
          IconButton(
            tooltip: 'Jadwal bulanan',
            onPressed: () {
              final settings = _settings;

              if (settings == null || _days.isEmpty) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MonthlyPrayerPage(
                    days: _days,
                    settings: settings,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () async {
              setState(() {
                _loading = true;
                _error = null;
              });

              await _loadPrayerTimes();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : today == null
              ? const Center(child: Text('Jadwal belum tersedia'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_error != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      ),
                    Text(
                      'Jadwal Hari Ini',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_todayTitle()}/Hijriah: ${HijriHelper.fromGregorian(DateTime.now())}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _PrayerTile(name: 'Subuh', time: _applyOffset(today.subuh)),
                    _PrayerTile(name: 'Terbit', time: _applyOffset(today.terbit)),
                    _PrayerTile(name: getMiddayLabel(today), time: _applyOffset(today.dzuhur)),
                    _PrayerTile(name: 'Ashar', time: _applyOffset(today.ashar)),
                    _PrayerTile(name: 'Maghrib', time: _applyOffset(today.maghrib)),
                    _PrayerTile(name: 'Isya', time: _applyOffset(today.isya)),
                    const SizedBox(height: 12),
                    Text(
                      'Jadwal untuk:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _settings == null
                        ? '-'
                        : '${_settings!.cityName}, ${_settings!.provinceName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sumber jadwal: EQuran.id - Jadwal Shalat Indonesia',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      'Metode: jadwal kota/kabupaten',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
    );
  }
}


class _PrayerTile extends StatelessWidget {
  final String name;
  final String time;

  const _PrayerTile({
    required this.name,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: Text(
          time,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
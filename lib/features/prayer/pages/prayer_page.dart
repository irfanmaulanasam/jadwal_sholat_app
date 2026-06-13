import 'package:flutter/material.dart';
import 'package:jadwal_sholat_app/features/prayer/pages/tavel_page.dart';

import '../models/prayer_day.dart';
import '../models/prayer_settings.dart';
import '../services/prayer_api_service.dart';
import '../services/prayer_cache_service.dart';
import '../services/prayer_notification_service.dart';
import '../services/prayer_settings_service.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  final _apiService = PrayerApiService();
  final _cacheService = PrayerCacheService();
  final _settingsService = PrayerSettingsService();
  final _notificationService = PrayerNotificationService();

  bool _loading = true;
  String? _error;

  PrayerSettings? _settings;
  List<PrayerDay> _days = [];

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

      final lat = settings.activeLatitude;
      final lng = settings.activeLongitude;

      if (lat == null || lng == null) {
        throw Exception('Lokasi belum diset');
      }

      final now = DateTime.now();

      final freshDays = await _apiService.fetchMonthlyPrayerTimes(
        latitude: lat,
        longitude: lng,
        month: now.month,
        year: now.year,
      );

      await _cacheService.saveCache(
        latitude: lat,
        longitude: lng,
        days: freshDays,
      );

      final today = _findTodayPrayer(freshDays);

      if (today != null) {
        await _notificationService.scheduleToday(
          day: today,
          isMale: settings.isMale,
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
      final lastCache = await _cacheService.loadLastCache();

      if (!mounted) return;

      setState(() {
        _days = lastCache?.days ?? [];
        _error =
            'Offline atau lokasi gagal. Jadwal memakai cache terakhir.';
        _loading = false;
      });
    }
  }

  PrayerDay? _findTodayPrayer(List<PrayerDay> days) {
    final now = DateTime.now();
    final todayKey =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    try {
      return days.firstWhere((day) => day.date == todayKey);
    } catch (_) {
      return days.isNotEmpty ? days.first : null;
    }
  }

  PrayerDay? get todayPrayer {
    return _findTodayPrayer(_days);
  }

  String getMiddayLabel() {
    final isFriday = DateTime.now().weekday == DateTime.friday;
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
            tooltip: 'Lihat response API',
            onPressed: () async {
              final settings = await _settingsService.load();
              final lat = settings.activeLatitude;
              final lng = settings.activeLongitude;

              if (lat == null || lng == null) return;

              final now = DateTime.now();

              final raw = await _apiService.fetchRawMonthlyPrayerResponse(
                latitude: lat,
                longitude: lng,
                month: now.month,
                year: now.year,
              );

              if (!context.mounted) return;

              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Raw API Response'),
                    content: SingleChildScrollView(
                      child: SelectableText(raw),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.data_object),
          ),
          IconButton(
            tooltip: 'Test notifikasi langsung',
            onPressed: () async {
              await _notificationService.showInstantTestNotification();
            },
            icon: const Icon(Icons.notifications_active),
          ),

          IconButton(
            tooltip: 'Test notifikasi 10 detik',
            onPressed: () async {
              await _notificationService.showTestNotificationInSeconds(seconds: 10);
            },
            icon: const Icon(Icons.timer),
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
                      _todayTitle(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _PrayerTile(name: 'Subuh', time: today.fajr),
                    _PrayerTile(name: 'Terbit', time: today.sunrise),
                    _PrayerTile(
                      name: getMiddayLabel(),
                      time: today.dhuhr,
                    ),
                    _PrayerTile(name: 'Ashar', time: today.asr),
                    _PrayerTile(name: 'Maghrib', time: today.maghrib),
                    _PrayerTile(name: 'Isya', time: today.isha),
                    const SizedBox(height: 12),
                    Text(
                      'Jadwal untuk:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _settings?.activeLocationInfo ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sumber jadwal: AlAdhan Prayer Times API',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      'Metode: koordinat lokasi aktif',
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
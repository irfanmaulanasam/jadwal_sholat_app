import 'package:flutter/material.dart';
import 'package:jadwal_sholat_app/features/prayer/helpers/prayer_status_helper.dart';
import 'package:jadwal_sholat_app/features/prayer/pages/monthy_prayer_page.dart';
import 'package:jadwal_sholat_app/features/prayer/pages/travel_page.dart';
import 'package:jadwal_sholat_app/features/prayer/services/hijri_api_service.dart';
import 'package:jadwal_sholat_app/features/prayer/widgets/prayer_tile.dart';
import 'package:jadwal_sholat_app/features/prayer/widgets/prayer_widget_data_service.dart';
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
  final _widgetDataService = PrayerWidgetDataService();
  final _apiService = PrayerApiService();
  final _hijrApiService = HijriApiService();
  final _settingsService = PrayerSettingsService();
  final _notificationService = PrayerNotificationService();
  
  bool _loading = true;
  String? _error;
  String? _hijriDate;

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
  
  Future<void> _scheduleWidgetUpdatesForDays(
    List<PrayerDay> days,
  ) async {
    final now = DateTime.now();
    final scheduledTimes = <DateTime>[];

    for (final day in days.take(7)) {
      final times = [
        day.subuh,
        day.dzuhur,
        day.ashar,
        day.maghrib,
        day.isya,
      ];

      for (final time in times) {
        final dateTime = _parsePrayerDateTime(
          day.tanggalLengkap,
          time,
        );

        if (dateTime.isAfter(now)) {
          scheduledTimes.add(dateTime);

          await _widgetDataService.scheduleWidgetUpdate(
            dateTime,
          );
        }
      }
    }

    await _widgetDataService.saveWidgetUpdateTriggers(
      scheduledTimes,
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
      final hijriDate = await _hijrApiService.fetchTodayHijriDate();
      await _scheduleWidgetUpdatesForDays(freshDays);
      if (today != null) {
        await _notificationService.scheduleUpcomingDays(
          days: freshDays,
          isMale: settings.isMale,
          numberOfDays: 7,
        );

        await _widgetDataService.saveTodayWidgetData(
          today: today,
          settings: settings,
        );
      }

      if (!mounted) return;

      setState(() {
        _settings = settings;
        _days = freshDays;
        _hijriDate = hijriDate; 
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
    final status =
      today == null || _settings == null
        ? null
      : PrayerStatusHelper.getStatus(
          today,
          _settings!.isMale,
      );
    final middayName = today == null ? 'Dzuhur' : getMiddayLabel(today);
    bool isActive(String name) => status?.currentPrayerName == name;
    bool isNext(String name) => status?.nextPrayerName == name;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        actions: [
          IconButton(
            tooltip: 'Lihat alarm',
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              final text =
                  await _notificationService.getPendingDebugText();

              if (!context.mounted) return;

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Alarm Terjadwal'),
                  content: SingleChildScrollView(
                    child: SelectableText(text),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
          ),
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
                  const SizedBox(height: 4),
                  Text(
                    _todayTitle(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Hijriah: ${_hijriDate ?? "-"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
                  const SizedBox(height: 12),
                  PrayerTile(
                    name: 'Subuh',
                    time: _applyOffset(today.subuh),
                    isActive: isActive('Subuh'),
                    isNext: isNext('Subuh'),
                  ),
                  PrayerTile(
                    name: 'Terbit',
                    time: _applyOffset(today.terbit),
                  ),
                  PrayerTile(
                    name: middayName,
                    time: _applyOffset(today.dzuhur),
                    isActive: isActive(middayName),
                    isNext: isNext(middayName),
                  ),
                  PrayerTile(
                    name: 'Ashar',
                    time: _applyOffset(today.ashar),
                    isActive: isActive('Ashar'),
                    isNext: isNext('Ashar'),
                  ),
                  PrayerTile(
                    name: 'Maghrib',
                    time: _applyOffset(today.maghrib),
                    isActive: isActive('Maghrib'),
                    isNext: isNext('Maghrib'),
                  ),
                  PrayerTile(
                    name: 'Isya',
                    time: _applyOffset(today.isya),
                    isActive: isActive('Isya'),
                    isNext: isNext('Isya'),
                  ),
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
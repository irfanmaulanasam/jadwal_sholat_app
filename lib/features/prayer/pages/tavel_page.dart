import 'package:flutter/material.dart';

import '../models/prayer_settings.dart';
import '../services/location_service.dart';
import '../services/prayer_settings_service.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  final _settingsService = PrayerSettingsService();
  final _locationService = LocationService();

  bool _loading = false;
  PrayerSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.load();

    if (!mounted) return;

    setState(() {
      _settings = settings;
    });
  }

  Future<void> _enableTravelMode() async {
    setState(() => _loading = true);

    try {
      final position = await _locationService.getCurrentPosition();
      final current = await _settingsService.load();

      final updated = current.copyWith(
        travelMode: true,
        travelCityName: 'Lokasi perjalanan',
        travelLatitude: position.latitude,
        travelLongitude: position.longitude,
      );

      await _settingsService.save(updated);

      if (!mounted) return;

      setState(() {
        _settings = updated;
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mode perjalanan aktif'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil lokasi: $e'),
        ),
      );
    }
  }

  Future<void> _disableTravelMode() async {
    final current = await _settingsService.load();

    final updated = current.copyWith(
      travelMode: false,
    );

    await _settingsService.save(updated);

    if (!mounted) return;

    setState(() {
      _settings = updated;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mode perjalanan dimatikan'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Perjalanan'),
      ),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Status'),
                    subtitle: Text(
                      settings.travelMode
                          ? 'Mode perjalanan aktif'
                          : 'Mode normal',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: const Text('Lokasi aktif'),
                    subtitle: Text(
                      settings.travelMode
                          ? 'Perjalanan: ${settings.travelLatitude}, ${settings.travelLongitude}'
                          : 'Utama: ${settings.homeLatitude}, ${settings.homeLongitude}',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _enableTravelMode,
                  child: Text(
                    _loading
                        ? 'Mengambil lokasi...'
                        : 'Pakai lokasi sekarang sebagai perjalanan',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loading ? null : _disableTravelMode,
                  child: const Text('Selesai perjalanan'),
                ),
              ],
            ),
    );
  }
}
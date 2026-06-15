import 'package:flutter/material.dart';
import '../services/prayer_settings_service.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  final _settingsService = PrayerSettingsService();

  String _selectedCity = 'Kab. Cianjur';

  final Map<String, String> _cityProvince = const {
    'Kab. Cianjur': 'Jawa Barat',
    'Kota Bandung': 'Jawa Barat',
    'Kab. Bandung': 'Jawa Barat',
    'Kota Bogor': 'Jawa Barat',
    'Kota Sukabumi': 'Jawa Barat',
    'Kota Jakarta': 'DKI Jakarta',
  };

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final settings = await _settingsService.load();

    if (!mounted) return;

    setState(() {
      _selectedCity = settings.cityName;
    });
  }

  Future<void> _saveLocation() async {
    final current = await _settingsService.load();

    final province = _cityProvince[_selectedCity] ?? 'Jawa Barat';

    final updated = current.copyWith(
      provinceName: province,
      cityName: _selectedCity,
      minuteOffset: 0,
    );

    await _settingsService.save(updated);

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> _backToCianjur() async {
    final current = await _settingsService.load();

    final updated = current.copyWith(
      provinceName: 'Jawa Barat',
      cityName: 'Kab. Cianjur',
      minuteOffset: 0,
    );

    await _settingsService.save(updated);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Jadwal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Jadwal sholat akan mengikuti kota/kabupaten ini.'),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: const InputDecoration(
              labelText: 'Kota / Kabupaten',
              border: OutlineInputBorder(),
            ),
            items: _cityProvince.keys.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedCity = value);
            },
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: _saveLocation,
            child: const Text('Pakai lokasi ini'),
          ),

          const SizedBox(height: 12),

          if (_selectedCity != 'Kab. Cianjur') ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _backToCianjur,
              child: const Text('Kembali ke Kab. Cianjur'),
            ),
          ],
        ],
      ),
    );
  }
}
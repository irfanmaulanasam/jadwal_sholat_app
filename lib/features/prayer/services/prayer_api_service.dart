import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/prayer_day.dart';

class PrayerApiService {
  Future<List<PrayerDay>> fetchMonthlyPrayerTimes({
    required String provinceName,
    required String cityName,
    required int month,
    required int year,
  }) async {
    final uri = Uri.parse('https://equran.id/api/v2/shalat');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'provinsi': provinceName,
        'kabkota': cityName,
        'bulan': month,
        'tahun': year,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil jadwal sholat');
    }

    final body = jsonDecode(response.body);
    final List jadwal = body['data']['jadwal'];

    return jadwal
        .map((item) => PrayerDay.fromEquranJson(item))
        .toList();
  }

  Future<List<String>> fetchProvinces() async {
    final uri = Uri.parse('https://equran.id/api/v2/shalat/provinsi');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil daftar provinsi');
    }

    final body = jsonDecode(response.body);
    final List data = body['data'];

    return data.map((item) => item.toString()).toList();
  }

  Future<List<String>> fetchCities({
    required String provinceName,
  }) async {
    final uri = Uri.parse('https://equran.id/api/v2/shalat/kabkota');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'provinsi': provinceName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil daftar kota');
    }

    final body = jsonDecode(response.body);
    final List data = body['data'];

    return data.map((item) => item.toString()).toList();
  }
}
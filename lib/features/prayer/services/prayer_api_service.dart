import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_day.dart';

class PrayerApiService {
  Future<List<PrayerDay>> fetchMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    final uri = Uri.https(
      'api.aladhan.com',
      '/v1/calendar',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'method': '20',
        'school': '0',
        'month': month.toString(),
        'year': year.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil jadwal sholat');
    }

    final body = jsonDecode(response.body);
    final List data = body['data'];

    return data.map((item) => PrayerDay.fromJson(item)).toList();
  }
}
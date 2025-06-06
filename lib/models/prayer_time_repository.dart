import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimeRepository {
  Future<Map<String, String>> fetchPrayerTimes(double lat, double lng) async {
    final url =
        'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=2';
    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final timings = jsonData['data']['timings'] as Map<String, dynamic>;

      return {
        'Subuh': timings['Fajr'],
        'Dzuhur': timings['Dhuhr'],
        'Ashar': timings['Asr'],
        'Maghrib': timings['Maghrib'],
        'Isya\'': timings['Isha'],
      };
    } else {
      throw Exception('Gagal mengambil data waktu salat');
    }
  }
}

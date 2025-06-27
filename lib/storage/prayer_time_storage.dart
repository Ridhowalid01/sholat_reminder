import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimeStorage {
  static const String _key = "prayer_times";

  static Future<void> savePrayerTimes(Map<String, String> prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(prayerTimes);
    await prefs.setString(_key, jsonString);
  }

  static Future<Map<String, String>?> loadPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    }
    return null;
  }

  static Future<void> clearPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

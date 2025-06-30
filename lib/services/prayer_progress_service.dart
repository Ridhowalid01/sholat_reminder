// lib/services/prayer_progress_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class PrayerProgressService {
  static const String _progressPrefix = 'prayer_progress_';
  static const String _lastResetDateKey =
      'prayer_progress_last_reset_date'; // Kunci untuk tanggal reset terakhir

  // Mendapatkan kunci SharedPreferences untuk progres sholat pada tanggal tertentu
  String _getPrayerProgressKeyForDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return '$_progressPrefix${formatter.format(date)}';
  }

  // Mendapatkan string tanggal hari ini
  String _getTodayDateString() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(DateTime.now());
  }

  /// Memeriksa apakah hari telah berganti. Jika ya, progres hari sebelumnya tidak akan dimuat
  /// untuk hari ini, efektifnya "mereset" untuk hari baru.
  /// Ini juga memastikan bahwa jika aplikasi dibuka pertama kali di hari baru,
  /// data lama tidak tercampur.
  Future<void> checkAndClearOldProgressIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final String todayDateString = _getTodayDateString();
    final String? lastResetDateString = prefs.getString(_lastResetDateKey);

    bool needsCleanup = false;

    if (lastResetDateString == null) {
      await prefs.setString(_lastResetDateKey, todayDateString);
      needsCleanup = true;
    } else if (lastResetDateString != todayDateString) {
      await prefs.setString(_lastResetDateKey, todayDateString);
      needsCleanup = true;
    } else {
      return;
    }

    if (needsCleanup) {
      final Set<String> keys = prefs.getKeys();
      final String todayProgressKey =
          _getPrayerProgressKeyForDate(DateTime.now());

      for (String key in keys) {
        if (key.startsWith(_progressPrefix) && key != todayProgressKey) {
          await prefs.remove(key);
        }
      }
    }
  }

  Future<void> saveTodaysProgress(Map<String, bool> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getPrayerProgressKeyForDate(DateTime.now());
    await prefs.setString(key, jsonEncode(progress));
  }

  Future<Map<String, bool>> getTodaysProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getPrayerProgressKeyForDate(DateTime.now());
    final String? progressString = prefs.getString(key);

    if (progressString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(progressString);
        final Map<String, bool> progress =
            decoded.map((k, v) => MapEntry(k, v as bool));

        return progress;
      } catch (e) {
        return {};
      }
    }

    return {};
  }

  Future<void> updatePrayerStatus(String prayerName, bool isDone) async {
    final currentProgress = await getTodaysProgress();
    currentProgress[prayerName] = isDone;
    await saveTodaysProgress(currentProgress);
  }

  Future<void> clearAllPrayerProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final Set<String> keysToRemove = prefs
        .getKeys()
        .where((key) =>
            key.startsWith(_progressPrefix) || key == _lastResetDateKey)
        .toSet();
    for (String key in keysToRemove) {
      await prefs.remove(key);
    }
  }
}

import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerProgressService {
  static const String _progressPrefix = 'prayer_progress_';

  String _getPrayerProgressKeyForDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String key = '$_progressPrefix${formatter.format(date)}';

    return key;
  }

  Future<void> saveProgressForDate(
      DateTime date, Map<String, bool> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getPrayerProgressKeyForDate(date);
    await prefs.setString(key, jsonEncode(progress));
  }

  Future<Map<String, bool>> getProgressForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getPrayerProgressKeyForDate(date);
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

  Future<void> saveTodaysProgress(Map<String, bool> progress) async {
    await saveProgressForDate(DateTime.now(), progress);
  }

  Future<Map<String, bool>> getTodaysProgress() async {
    return await getProgressForDate(DateTime.now());
  }

  Future<Map<String, bool>> getYesterdaysProgress() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return await getProgressForDate(yesterday);
  }

  Future<void> updatePrayerStatus(String prayerName, bool isDone) async {
    final currentProgress = await getTodaysProgress();
    currentProgress[prayerName] = isDone;
    await saveTodaysProgress(currentProgress);
  }

  Future<void> clearAllPrayerProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final Set<String> keysToRemove =
        prefs.getKeys().where((key) => key.startsWith(_progressPrefix)).toSet();
    for (String key in keysToRemove) {
      await prefs.remove(key);
    }
  }
}

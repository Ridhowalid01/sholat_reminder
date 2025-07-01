import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';

import '../models/prayer_time_data.dart';
import '../services/prayer_progress_service.dart';

class PrayerChecklistCubit extends Cubit<List<PrayerTimeData>> {
  final PrayerProgressService _progressService;
  final List<PrayerTimeData> _basePrayerSchedule;
  final Map<String, String> _prayerTimesMap;

  PrayerChecklistCubit({
    required PrayerProgressService progressService,
    required List<PrayerTimeData> initialPrayerSchedule,
    required Map<String, String> prayerTimesMap,
  })  : _progressService = progressService,
        _basePrayerSchedule = List.unmodifiable(
          initialPrayerSchedule.map((p) => p.copyWith(isDone: false)).toList(),
        ),
        _prayerTimesMap = prayerTimesMap,
        super([]) {
    _initializeOrLoadAppropriateChecklist();
  }

  Future<void> _initializeOrLoadAppropriateChecklist() async {
    final now = DateTime.now();
    Map<String, bool> progressToUse = await _progressService.getTodaysProgress();

    if (progressToUse.isEmpty) {
      final subuhStr = _prayerTimesMap['Subuh'];

      if (subuhStr != null) {
        final subuhParts = subuhStr.split(':');
        if (subuhParts.length == 2) {
          final subuhHour = int.tryParse(subuhParts[0]);
          final subuhMinute = int.tryParse(subuhParts[1]);

          if (subuhHour != null && subuhMinute != null) {
            final subuhTimeToday = DateTime(
              now.year,
              now.month,
              now.day,
              subuhHour,
              subuhMinute,
            );

            if (now.isBefore(subuhTimeToday)) {
              progressToUse = await _progressService.getYesterdaysProgress();
            }
          }
        }
      }
    }

    final checklist = _basePrayerSchedule.map((basePrayer) {
      return basePrayer.copyWith(
        isDone: progressToUse[basePrayer.name] ?? basePrayer.isDone,
      );
    }).toList();

    emit(checklist);
  }

  Future<void> togglePrayerStatus(String prayerName) async {
    final prayerToUpdate = state.firstWhereOrNull((p) => p.name == prayerName);
    if (prayerToUpdate == null) return;

    final newStatus = !prayerToUpdate.isDone;
    final updatedList = state.map((p) {
      return p.name == prayerName ? p.copyWith(isDone: newStatus) : p;
    }).toList();

    emit(updatedList);

    final progressMap = {
      for (var p in updatedList) p.name: p.isDone,
    };

    await _progressService.saveTodaysProgress(progressMap);
  }

  Future<void> resetChecklistForNewDay() async {
    final newChecklist = List<PrayerTimeData>.from(_basePrayerSchedule);
    emit(newChecklist);

    final newProgress = {
      for (var prayer in _basePrayerSchedule) prayer.name: false,
    };

    await _progressService.saveTodaysProgress(newProgress);
  }

  Future<void> forceRefreshChecklistFromStorage() async {
    await _initializeOrLoadAppropriateChecklist();
  }
}

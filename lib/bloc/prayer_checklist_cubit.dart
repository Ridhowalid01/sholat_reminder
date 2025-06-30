import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';

import '../models/prayer_time_data.dart';
import '../services/prayer_progress_service.dart';

class PrayerChecklistCubit extends Cubit<List<PrayerTimeData>> {
  final PrayerProgressService _progressService;
  final List<PrayerTimeData> _basePrayerSchedule;

  PrayerChecklistCubit({
    required PrayerProgressService progressService,
    required List<PrayerTimeData> initialPrayerSchedule,
  })  : _progressService = progressService,
        _basePrayerSchedule = List.unmodifiable(initialPrayerSchedule
            .map((p) => p.copyWith(isDone: false))
            .toList()),
        super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _progressService.checkAndClearOldProgressIfNeeded();
    final Map<String, bool> todaysProgress =
        await _progressService.getTodaysProgress();

    final List<PrayerTimeData> checklist =
        _basePrayerSchedule.map((basePrayer) {
      return basePrayer.copyWith(
          isDone: todaysProgress[basePrayer.name] ?? basePrayer.isDone);
    }).toList();

    emit(checklist);
  }

  Future<void> togglePrayerStatus(String prayerName) async {
    final PrayerTimeData? prayerToUpdate =
        state.firstWhereOrNull((p) => p.name == prayerName);

    if (prayerToUpdate == null) {
      return;
    }

    final bool newStatus = !prayerToUpdate.isDone;
    await _progressService.updatePrayerStatus(prayerName, newStatus);

    final List<PrayerTimeData> updatedList = state.map((prayer) {
      if (prayer.name == prayerName) {
        return prayer.copyWith(isDone: newStatus);
      }
      return prayer;
    }).toList();

    emit(updatedList);
  }

  Future<void> refreshProgress() async {
    await _initialize();
  }
}

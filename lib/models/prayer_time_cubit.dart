import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/prayer_time_storage.dart';
import 'prayer_time_repository.dart';

class PrayerTimeState {
  final bool isLoading;
  final String? error;
  final Map<String, String> prayerTimes;

  PrayerTimeState({
    this.isLoading = false,
    this.error,
    this.prayerTimes = const {},
  });

  PrayerTimeState copyWith({
    bool? isLoading,
    String? error,
    Map<String, String>? prayerTimes,
  }) {
    return PrayerTimeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      prayerTimes: prayerTimes ?? this.prayerTimes,
    );
  }
}

class PrayerTimeCubit extends Cubit<PrayerTimeState> {
  final PrayerTimeRepository repository;

  PrayerTimeCubit(this.repository) : super(PrayerTimeState());

  Future<void> loadPrayerTimes(double lat, double lng) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final data = await repository.fetchPrayerTimes(lat, lng);
      emit(PrayerTimeState(prayerTimes: data, isLoading: false));

      await PrayerTimeStorage.savePrayerTimes(data);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('prayer_times');
    if (cached != null) {
      final data = jsonDecode(cached) as Map<String, dynamic>;
      final map = data.map((key, value) => MapEntry(key, value.toString()));
      emit(PrayerTimeState(prayerTimes: map));
    }
  }
}

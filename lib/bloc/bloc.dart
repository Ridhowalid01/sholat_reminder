import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sholat_reminder/bloc/prayer_checklist_cubit.dart';
import 'package:sholat_reminder/bloc/state.dart';
import '../utils/logger.dart';
import 'event.dart';

class ThemeBloc extends Cubit<bool> {
  ThemeBloc() : super(true);

  void changeTheme() => emit(!state);
}

class ClockBloc extends Bloc<ClockEvent, ClockState> {
  final PrayerChecklistCubit checklistCubit;
  final Map<String, String> prayerTimes;
  late final Timer _timer;
  DateTime? _lastResetDate;

  static const String _lastResetDateKeyPrefs = 'clock_bloc_last_reset_date_prefs';

  ClockBloc({
    required this.checklistCubit,
    required this.prayerTimes,
  }) : super(
    ClockState(
      DateTime.now(),
      _formatTime(DateTime.now()),
      _formatDate(DateTime.now()),
    ),
  ) {
    _initialize();
    on<Tick>(_onTick);
  }

  /// Inisialisasi timer dan pengecekan reset subuh
  Future<void> _initialize() async {
    await _loadLastResetDateFromPrefs();
    await _checkForSubuhReset(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(Tick(DateTime.now()));
    });
  }

  /// Handler untuk event Tick
  Future<void> _onTick(Tick event, Emitter<ClockState> emit) async {
    emit(
      ClockState(
        event.currentTime,
        _formatTime(event.currentTime),
        _formatDate(event.currentTime),
      ),
    );

    await _checkForSubuhReset(event.currentTime);
  }

  /// Memuat data reset terakhir dari SharedPreferences
  Future<void> _loadLastResetDateFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString(_lastResetDateKeyPrefs);
      if (dateString != null) {
        _lastResetDate = DateTime.tryParse(dateString);
      }
    } catch (e) {
      // print('ERROR: Gagal memuat _lastResetDate dari SharedPreferences: $e');
      logger.e('ERROR: Gagal memuat _lastResetDate dari SharedPreferences: $e');
    }
  }

  /// Menyimpan tanggal reset terbaru ke SharedPreferences
  Future<void> _saveLastResetDateToPrefs(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateToSave = DateTime(date.year, date.month, date.day);
      await prefs.setString(_lastResetDateKeyPrefs, dateToSave.toIso8601String());
      _lastResetDate = dateToSave;
    } catch (e) {
      // print('ERROR: Gagal menyimpan _lastResetDate ke SharedPreferences: $e');
    }
  }

  /// Mengecek apakah perlu mereset checklist berdasarkan waktu Subuh
  Future<void> _checkForSubuhReset(DateTime now) async {
    final subuhStr = prayerTimes['Subuh'];
    if (subuhStr == null) return;

    final today = DateTime(now.year, now.month, now.day);

    if (_lastResetDate != null &&
        _lastResetDate!.year == today.year &&
        _lastResetDate!.month == today.month &&
        _lastResetDate!.day == today.day) {
      return; // Sudah di-reset hari ini
    }

    try {
      final parts = subuhStr.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);

        if (hour != null && minute != null) {
          final subuhTimeToday = DateTime(today.year, today.month, today.day, hour, minute);
          if (now.isAfter(subuhTimeToday)) {
            await checklistCubit.resetChecklistForNewDay();
            await _saveLastResetDateToPrefs(today);
          }
        }
      }
    } catch (e) {
      // print('ERROR: Gagal parsing waktu Subuh: $e');
      logger.e('ERROR: Gagal parsing waktu Subuh: $e');
    }
  }

  static String _formatTime(DateTime time) {
    return DateFormat('HH : mm : ss').format(time);
  }

  static String _formatDate(DateTime time) {
    return DateFormat('dd MMMM yyyy', 'id').format(time);
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}

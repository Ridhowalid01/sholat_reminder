import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sholat_reminder/bloc/prayer_checklist_cubit.dart';
import 'package:sholat_reminder/bloc/state.dart';
import '../services/notification_service.dart';
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

  final Set<String> _notifiedPrayerTimesToday = {};
  DateTime? _lastNotificationResetDay;

  static const String _lastResetDateKeyPrefs =
      'clock_bloc_last_reset_date_prefs';

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
  }

  /// Inisialisasi timer dan pengecekan reset subuh
  Future<void> _initialize() async {
    await _loadLastResetDateFromPrefs();

    final now = state.dateTime;
    if (_lastResetDate != null) {
      _lastNotificationResetDay = DateTime(
          _lastResetDate!.year, _lastResetDate!.month, _lastResetDate!.day);
    } else {
      _lastNotificationResetDay = DateTime(now.year, now.month, now.day);
    }

    _resetNotifiedPrayersIfNeeded(now);

    await _checkForSubuhReset(now);

    _checkAndSendPrayerNotifications(now);

    on<Tick>(_onTick);

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
    _checkAndSendPrayerNotifications(event.currentTime);
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
      logger.e('ERROR: Gagal memuat _lastResetDate dari SharedPreferences: $e');
    }
  }

  /// Menyimpan tanggal reset terbaru ke SharedPreferences
  Future<void> _saveLastResetDateToPrefs(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateToSave = DateTime(date.year, date.month, date.day);
      await prefs.setString(
          _lastResetDateKeyPrefs, dateToSave.toIso8601String());
      _lastResetDate = dateToSave;
    } catch (e) {
      logger
          .e('ERROR: Gagal menyimpan _lastResetDate ke SharedPreferences: $e');
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Mereset daftar sholat yang sudah dinotifikasi jika hari telah berganti.
  void _resetNotifiedPrayersIfNeeded(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (_lastNotificationResetDay == null ||
        !_isSameDay(_lastNotificationResetDay!, today)) {
      logger.d(
          "ClockBloc: Hari baru terdeteksi ($today) untuk notifikasi. Mereset daftar notifikasi.");
      _notifiedPrayerTimesToday.clear();
      _lastNotificationResetDay = today;
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
          final subuhTimeToday =
              DateTime(today.year, today.month, today.day, hour, minute);
          if (now.isAfter(subuhTimeToday)) {
            await checklistCubit.resetChecklistForNewDay();
            _notifiedPrayerTimesToday.clear();
            logger.d("Reset daftar notifikasi saat Subuh.");
            await _saveLastResetDateToPrefs(today);
          }
        }
      }
    } catch (e) {
      logger.e('ERROR: Gagal parsing waktu Subuh: $e');
    }
  }

  /// Mengecek waktu sholat dan mengirim notifikasi jika belum dikirim
  void _checkAndSendPrayerNotifications(DateTime now) {
    _resetNotifiedPrayersIfNeeded(now); // Pastikan ini dipanggil

    prayerTimes.forEach((prayerName, timeStr) {
      // Cek apakah notifikasi untuk sholat ini sudah dikirim hari ini
      if (_notifiedPrayerTimesToday.contains(prayerName)) {
        return; // Lewati jika sudah dinotifikasi
      }

      DateTime? prayerTimeToday;
      try {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);

          if (hour != null && minute != null) {
            prayerTimeToday =
                DateTime(now.year, now.month, now.day, hour, minute);
          }
        }
      } catch (e) {
        logger.e('ERROR: Gagal parsing waktu $prayerName ($timeStr): $e');
        return;
      }

      if (prayerTimeToday == null) {
        logger.w(
            'ClockBloc: Gagal mendapatkan prayerTimeToday untuk $prayerName');
        return;
      }

      if (now.year == prayerTimeToday.year &&
              now.month == prayerTimeToday.month &&
              now.day == prayerTimeToday.day &&
              now.hour == prayerTimeToday.hour &&
              now.minute == prayerTimeToday.minute &&
              !_notifiedPrayerTimesToday.contains(prayerName) // Double check
          ) {
        logger.i(
            "Waktu notifikasi untuk $prayerName ($timeStr) telah tiba pada $now.");
        NotificationService.showPrayerTimeNotification(
            prayerName); // Panggil fungsi notifikasi dari notification_service.dart
        _notifiedPrayerTimesToday.add(prayerName);
      }
    });
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

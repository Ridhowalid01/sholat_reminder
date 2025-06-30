import 'dart:async';
import 'dart:math' as logger;

import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:sholat_reminder/bloc/prayer_checklist_cubit.dart';
import 'package:sholat_reminder/bloc/state.dart';

import 'event.dart';

class ThemeBloc extends Cubit<bool> {
  ThemeBloc() : super(true);

  void changeTheme() {
    emit(!state);
  }
}

class ClockBloc extends Bloc<ClockEvent, ClockState> {
  late Timer _timer;
  DateTime? _lastResetDate;
  final PrayerChecklistCubit checklistCubit;
  final Map<String, String> prayerTimes;

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      add(Tick(now));
    });

    on<Tick>((event, emit) async {
      emit(
        ClockState(
          event.currentTime,
          _formatTime(event.currentTime),
          _formatDate(event.currentTime),
        ),
      );
      await _checkForSubuhReset(event.currentTime);
    });
  }

  Future<void> _checkForSubuhReset(DateTime now) async {
    final subuhStr = prayerTimes['Subuh'];
    if (subuhStr == null) return;

    final today = DateTime(now.year, now.month, now.day);
    if (_lastResetDate == today) return;

    try {
      final subuhParts = subuhStr.split(':');
      final subuhTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(subuhParts[0]),
        int.parse(subuhParts[1]),
      );

      if (now.isAfter(subuhTime)) {
        await checklistCubit.refreshProgress();
        _lastResetDate = today;
      }
    } catch (e) {
      logger.e;
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
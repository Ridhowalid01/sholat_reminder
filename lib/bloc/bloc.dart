import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
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

  ClockBloc()
      : super(ClockState(
            _formatTime(DateTime.now()), _formatDate(DateTime.now()))) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      add(Tick(now));
    });

    on<Tick>((event, emit) {
      emit(
        ClockState(
            _formatTime(event.currentTime), _formatDate(event.currentTime)),
      );
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

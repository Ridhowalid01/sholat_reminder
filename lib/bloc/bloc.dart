import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:sholat_reminder/bloc/state.dart';

import 'event.dart';

class ClockBloc extends Bloc<ClockEvent, ClockState> {
  late Timer _timer;

  ClockBloc() : super(ClockState(_formatTime(DateTime.now()))) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      add(Tick(now));
    });

    on<Tick>((event, emit) {
      emit(ClockState(_formatTime(event.currentTime)));
    });
  }

  static String _formatTime(DateTime time) {
    return DateFormat('HH : mm : ss').format(time);
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}

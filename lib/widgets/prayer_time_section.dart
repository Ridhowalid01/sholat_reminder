import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sholat_reminder/widgets/prayer_times_row.dart';

import '../bloc/bloc.dart';
import '../bloc/state.dart';
import '../models/prayer_time_cubit.dart';
import '../models/prayer_time_data.dart';

class PrayerTimeSection extends StatelessWidget {
  const PrayerTimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, ClockState>(
      buildWhen: (previous, current) =>
          previous.dateTime.minute != current.dateTime.minute,
      builder: (context, clockState) {
        final now = clockState.dateTime;

        return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
          builder: (context, state) {
            if (state.error != null) {
              return Center(child: Text("Error: ${state.error}"));
            }

            final times = state.prayerTimes.isEmpty
                ? {
                    'Subuh': '-',
                    'Dzuhur': '-',
                    'Ashar': '-',
                    'Maghrib': '-',
                    'Isya\'': '-',
                  }
                : state.prayerTimes;

            final prayerList = buildPrayerTimeList(times);

            final prayerDateTimes = times.entries.map((e) {
              try {
                final parts = e.value.split(':');
                final hour = int.parse(parts[0]);
                final minute = int.parse(parts[1]);
                return MapEntry(e.key,
                    DateTime(now.year, now.month, now.day, hour, minute));
              } catch (_) {
                return MapEntry(e.key, DateTime(2100));
              }
            }).toList()
              ..sort((a, b) => a.value.compareTo(b.value));

            String? currentPrayer;

            try {
              final subuh =
                  prayerDateTimes.firstWhere((e) => e.key == 'Subuh').value;
              final isya = prayerDateTimes.last.value;

              final subuhEnd = subuh.add(const Duration(hours: 2));
              final subuhTomorrow = subuh.add(const Duration(days: 1));
              final isyaYesterday = isya.subtract(const Duration(days: 1));

              if ((now.isAfter(isya) && now.isBefore(subuhTomorrow)) ||
                  (now.isAfter(isyaYesterday) && now.isBefore(subuh))) {
                currentPrayer = 'Isya\'';
              } else {
                for (var i = 0; i < prayerDateTimes.length; i++) {
                  final start = prayerDateTimes[i].value;
                  final end = i < prayerDateTimes.length - 1
                      ? prayerDateTimes[i + 1].value
                      : subuhTomorrow;

                  if (now.isAfter(start) && now.isBefore(end)) {
                    currentPrayer = prayerDateTimes[i].key;
                    break;
                  }
                }
              }

              if (currentPrayer == 'Subuh' && now.isAfter(subuhEnd)) {
                currentPrayer = null;
              }
            } catch (_) {
              currentPrayer = null;
            }

            return PrayerTimesRow(
              prayers: prayerList,
              currentPrayer: currentPrayer,
            );
          },
        );
      },
    );
  }
}

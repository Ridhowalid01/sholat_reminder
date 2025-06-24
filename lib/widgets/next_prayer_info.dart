import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sholat_reminder/bloc/bloc.dart';
import 'package:sholat_reminder/models/prayer_time_cubit.dart';

import '../bloc/state.dart';

class NextPrayerInfo extends StatelessWidget {
  const NextPrayerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, ClockState>(
      buildWhen: (previous, current) =>
          previous.dateTime.minute != current.dateTime.minute,
      builder: (context, clockState) {
        final now = clockState.dateTime;

        return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
          builder: (context, prayerState) {
            final prayerTimes = prayerState.prayerTimes;

            if (prayerTimes.isEmpty || prayerTimes.values.contains('-')) {
              return const SizedBox.shrink();
            }

            String nextPrayer = '-';
            String timeRemaining = '-';

            List<MapEntry<String, DateTime>> prayerDateTimes = [];

            prayerTimes.forEach((name, time) {
              try {
                final parts = time.split(':');
                final hour = int.parse(parts[0]);
                final minute = int.parse(parts[1]);

                final dt = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  hour,
                  minute,
                );

                prayerDateTimes.add(MapEntry(name, dt));
              } catch (_) {}
            });

            prayerDateTimes.sort((a, b) => a.value.compareTo(b.value));

            for (var entry in prayerDateTimes) {
              if (entry.value.isAfter(now)) {
                final diff = entry.value.difference(now);
                nextPrayer = entry.key;
                timeRemaining = diff.inHours > 0
                    ? "${diff.inHours} jam ${diff.inMinutes % 60} menit"
                    : "${diff.inMinutes} menit";
                break;
              }
            }

            if (nextPrayer == '-') {
              final firstPrayer = prayerDateTimes.first;
              final tomorrow = firstPrayer.value.add(const Duration(days: 1));
              final diff = tomorrow.difference(now);

              nextPrayer = firstPrayer.key;
              timeRemaining = diff.inHours > 0
                  ? "${diff.inHours} jam ${diff.inMinutes % 60} menit"
                  : "${diff.inMinutes} menit";
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$nextPrayer kurang dari ",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  timeRemaining,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sholat_reminder/models/prayer_time_cubit.dart';

import '../bloc/bloc.dart';
import '../bloc/location_cubit.dart';
import '../bloc/state.dart';
import '../models/prayer_time_data.dart';
import '../utils/colors/app_colors.dart';
import '../widgets/prayer_times_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeBloc myTheme = context.read<ThemeBloc>();

    return BlocBuilder<ThemeBloc, bool>(
      bloc: myTheme,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: state
              ? DarkAppColors.backgroundColor
              : LightAppColors.backgroundColor,
          appBar: AppBar(
            leadingWidth: 250,
            backgroundColor: state
                ? DarkAppColors.backgroundColor
                : LightAppColors.backgroundColor,
            leading: Container(
              padding: EdgeInsets.only(left: 16.r),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.iconColor,
                    size: 24.r,
                  ),
                  SizedBox(width: 4.r),
                  Flexible(child: BlocBuilder<LocationCubit, LocationState>(
                    builder: (context, state) {
                      if (state is LocationLoaded) {
                        final position = state.position;

                        return FutureBuilder<String?>(
                          future: context
                              .read<LocationCubit>()
                              .getAddressFromPosition(position),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Mencari alamat..");
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else {
                              return Text(
                                '${snapshot.data}',
                                style: TextStyle(
                                    fontSize: 14.r,
                                    fontWeight: FontWeight.w500),
                              );
                            }
                          },
                        );
                      } else if (state is LocationError) {
                        return Text("Error: ${state.message}");
                      }
                      return Text("Memuat..");
                    },
                  )),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.r),
                child: IconButton(
                    onPressed: () {
                      myTheme.changeTheme();
                    },
                    icon: Icon(
                      state
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: AppColors.iconColor,
                      size: 24.r,
                    )),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20.r,
              children: [
                Text(
                  "Selamat Datang, Xyzel",
                  style: TextStyle(
                    fontSize: 24.r,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Card(
                    color: state
                        ? DarkAppColors.cardColor
                        : LightAppColors.cardColor,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          spacing: 16.r,
                          children: [
                            Column(
                              children: [
                                BlocBuilder<ClockBloc, ClockState>(
                                  buildWhen: (prev, current) =>
                                      prev.date != current.date,
                                  builder: (context, state) {
                                    return Text(
                                      state.date,
                                      style: TextStyle(fontSize: 14.r),
                                    );
                                  },
                                ),
                                BlocBuilder<ClockBloc, ClockState>(
                                  builder: (context, state) {
                                    return Text(
                                      state.time,
                                      style: TextStyle(
                                        fontSize: 48.r,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    );
                                  },
                                ),
                                BlocBuilder<ClockBloc, ClockState>(
                                  // buildWhen: (previous, current) =>
                                  // previous.dateTime.minute != current.dateTime.minute,
                                  builder: (context, clockState) {
                                    final now = clockState.dateTime;

                                    return BlocBuilder<PrayerTimeCubit,
                                        PrayerTimeState>(
                                      builder: (context, prayerState) {
                                        final prayerTimes =
                                            prayerState.prayerTimes;

                                        if (prayerTimes.isEmpty ||
                                            prayerTimes.values.contains('-')) {
                                          return const Text(" ");
                                        }

                                        String nextPrayer = '-';
                                        String timeRemaining = '-';

                                        List<MapEntry<String, DateTime>>
                                            prayerDateTimes = [];

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

                                            prayerDateTimes
                                                .add(MapEntry(name, dt));
                                          } catch (_) {}
                                        });

                                        // Urutkan dari waktu paling awal ke paling akhir
                                        prayerDateTimes.sort((a, b) =>
                                            a.value.compareTo(b.value));

                                        // Cari waktu sholat berikutnya (masih hari ini)
                                        for (var entry in prayerDateTimes) {
                                          final diff =
                                              entry.value.difference(now);
                                          if (entry.value.isAfter(now)) {
                                            nextPrayer = entry.key;
                                            timeRemaining = diff.inHours > 0
                                                ? "${diff.inHours} jam ${diff.inMinutes % 60} menit"
                                                : "${diff.inMinutes} menit";
                                            break;
                                          }
                                        }

                                        // Kalau semua waktu sudah lewat, ambil waktu pertama besok
                                        if (nextPrayer == '-') {
                                          final firstPrayer =
                                              prayerDateTimes.first;

                                          // Ambil tanggal besok
                                          final tomorrowDate =
                                              now.add(const Duration(days: 1));

                                          final tomorrow = DateTime(
                                            tomorrowDate.year,
                                            tomorrowDate.month,
                                            tomorrowDate.day,
                                            firstPrayer.value.hour,
                                            firstPrayer.value.minute,
                                          );

                                          final diff = tomorrow.difference(now);
                                          nextPrayer = firstPrayer.key;
                                          timeRemaining = diff.inHours > 0
                                              ? "${diff.inHours} jam ${diff.inMinutes % 60} menit"
                                              : "${diff.inMinutes} menit";
                                        }

                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "$nextPrayer kurang dari ",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                            Text(
                                              timeRemaining,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              ],
                            ),
                            const Divider(
                              color: Colors.grey,
                              thickness: 1,
                              height: 1,
                            ),

                            BlocBuilder<ClockBloc, ClockState>(
                              builder: (context, clockState) {
                                final now = clockState.dateTime;

                                return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
                                  builder: (context, prayerState) {
                                    final prayerTimes = prayerState.prayerTimes.isEmpty
                                        ? {
                                      'Subuh': '-',
                                      'Dzuhur': '-',
                                      'Ashar': '-',
                                      'Maghrib': '-',
                                      'Isya\'': '-',
                                    }
                                        : prayerState.prayerTimes;

                                    if (prayerState.error != null) {
                                      return Center(child: Text("Error: ${prayerState.error}"));
                                    }

                                    final prayerList = buildPrayerTimeList(prayerTimes);

                                    final prayerDateTimes = prayerTimes.entries.map((e) {
                                      try {
                                        final parts = e.value.split(':');
                                        final hour = int.parse(parts[0]);
                                        final minute = int.parse(parts[1]);
                                        final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
                                        return MapEntry(e.key, dateTime);
                                      } catch (_) {
                                        return MapEntry(e.key, DateTime(2100));
                                      }
                                    }).toList();

                                    prayerDateTimes.sort((a, b) => a.value.compareTo(b.value));

                                    String? currentPrayer;

                                    final subuhToday = prayerDateTimes.firstWhere((e) => e.key == 'Subuh').value;
                                    final isyaToday = prayerDateTimes.last.value;
                                    final subuhTomorrow = subuhToday.add(const Duration(days: 1));
                                    final isyaYesterday = isyaToday.subtract(const Duration(days: 1));

                                    final subuhEnd = subuhToday.add(const Duration(hours: 2)); // Subuh aktif hanya 3 jam

                                    if (now.isAfter(isyaToday) && now.isBefore(subuhTomorrow)) {
                                      currentPrayer = 'Isya\'';
                                    } else if (now.isAfter(isyaYesterday) && now.isBefore(subuhToday)) {
                                      currentPrayer = 'Isya\'';
                                    } else {
                                      for (int i = 0; i < prayerDateTimes.length; i++) {
                                        final current = prayerDateTimes[i].value;
                                        final next = i < prayerDateTimes.length - 1
                                            ? prayerDateTimes[i + 1].value
                                            : subuhTomorrow;

                                        if (now.isAfter(current) && now.isBefore(next)) {
                                          currentPrayer = prayerDateTimes[i].key;
                                          break;
                                        }
                                      }

                                      if (now.isBefore(subuhToday)) {
                                        currentPrayer = null;
                                      }
                                    }

                                    // Matikan status aktif jika sudah lewat 3 jam dari Subuh
                                    if (currentPrayer == 'Subuh' && now.isAfter(subuhEnd)) {
                                      currentPrayer = null;
                                    }

                                    return PrayerTimesRow(
                                      prayers: prayerList,
                                      currentPrayer: currentPrayer,
                                    );
                                  },
                                );
                              },
                            )

                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }
}

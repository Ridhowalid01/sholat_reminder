import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/bloc.dart';
import '../bloc/state.dart';
import '../utils/colors/app_colors.dart';
import '../widgets/prayer_times_row.dart';
import '../models/prayer_time_data.dart';
import '../bloc/location_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeBloc myTheme = context.read<ThemeBloc>();
    return BlocBuilder<ThemeBloc, bool>(
      bloc: myTheme,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: state ? DarkAppColors.backgroundColor : LightAppColors.backgroundColor,
          appBar: AppBar(
            leadingWidth: 250,
            backgroundColor: state ? DarkAppColors.backgroundColor : LightAppColors.backgroundColor,
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
                      state ? Icons
                          .light_mode_outlined : Icons.dark_mode_outlined,
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
                    color: state ? DarkAppColors.cardColor : LightAppColors.cardColor,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: SizedBox(
                        // height: 300.r,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Magrib kurang dari ",
                                      style: TextStyle(
                                          fontSize: 14.r, color: Colors.grey),
                                    ),
                                    Text(
                                      "5 menit",
                                      style: TextStyle(fontSize: 14.r),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.grey,
                              thickness: 1,
                              height: 1,
                            ),
                            PrayerTimesRow(
                              prayers: prayerTimes,
                            ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sholat_reminder/widgets/current_time_display.dart';
import 'package:sholat_reminder/widgets/location_display.dart';
import 'package:sholat_reminder/widgets/prayer_time_section.dart';

import '../bloc/bloc.dart';
import '../models/prayer_time_cubit.dart';
import '../models/prayer_time_data.dart';
import '../utils/colors/app_colors.dart';
import '../widgets/checklist_prayer_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeBloc myTheme = context.read<ThemeBloc>();

    return BlocBuilder<ThemeBloc, bool>(
      bloc: myTheme,
      builder: (context, themeState) {
        return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
          builder: (context, state) {
            final prayerMap = state.prayerTimes;
            final initialChecklist = buildPrayerTimeList(prayerMap);
            return BlocProvider(
              create: (_) => PrayerChecklistCubit(initialChecklist),
              child: Scaffold(
                backgroundColor: themeState
                    ? DarkAppColors.backgroundColor
                    : LightAppColors.backgroundColor,
                appBar: AppBar(
                  leadingWidth: 250,
                  backgroundColor: themeState
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
                        Flexible(child: LocationDisplay()),
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
                            themeState
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            color: AppColors.iconColor,
                            size: 24.r,
                          )),
                    ),
                  ],
                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 16.r, horizontal: 20.r),
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
                          color: themeState
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
                                  const CurrentTimeDisplay(),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                    height: 1,
                                  ),
                                  const PrayerTimeSection()
                                ],
                              ),
                            ),
                          )),
                      Card(
                          color: themeState
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
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.checklist_outlined,
                                        size: 24.r,
                                      ),
                                      Text(
                                        "Progress Sholat",
                                        style: TextStyle(
                                          fontSize: 20.r,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      BlocBuilder<PrayerChecklistCubit,
                                          List<PrayerTimeData>>(
                                        builder: (context, prayers) {
                                          final doneCount = prayers
                                              .where((e) => e.isDone)
                                              .length;
                                          final total = prayers.length;
                                          return Text(
                                            "$doneCount/$total",
                                            style: TextStyle(
                                              fontSize: 16.r,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                    height: 1,
                                  ),
                                  const ChecklistPrayerRow()
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sholat_reminder/widgets/current_time_display.dart';
import 'package:sholat_reminder/widgets/location_display.dart';
import 'package:sholat_reminder/widgets/prayer_time_section.dart';

import '../bloc/bloc.dart';
import '../bloc/location_cubit.dart';
import '../bloc/prayer_checklist_cubit.dart';
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
        return Scaffold(
          backgroundColor: themeState
              ? DarkAppColors.backgroundColor
              : LightAppColors.backgroundColor,
          appBar: AppBar(
            leadingWidth: 320.r,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final locCubit = context.read<LocationCubit>();
                          // final checklistCubit = context.read<PrayerChecklistCubit>();

                          await locCubit.refreshLocation();
                          // checklistCubit.forceRefreshChecklistFromStorage();
                        },
                        icon: Icon(
                          Icons.refresh_outlined,
                          color: AppColors.iconColor,
                          size: 24.r,
                        )),
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
                  ],
                ),
              ),
            ],
          ),
          body: BlocBuilder<PrayerChecklistCubit, List<PrayerTimeData>>(
            builder: (context, prayerChecklist) {
              final themeState = context.watch<ThemeBloc>().state;
              final doneCount = prayerChecklist.where((e) => e.isDone).length;
              final totalPrayers = prayerChecklist.length;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20.r,
                  children: [
                    Text(
                      "Selamat Datang, Ridho-kun",
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
                                    Text(
                                      totalPrayers > 0
                                          ? "$doneCount/$totalPrayers"
                                          : "0/0",
                                      style: TextStyle(
                                        fontSize: 16.r,
                                        fontWeight: FontWeight.bold,
                                      ),
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
              );
            },
          ),
        );
      },
    );
  }
}

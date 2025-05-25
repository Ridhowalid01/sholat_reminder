import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors/app_colors.dart';
import '../widgets/prayer_times_row.dart';
import '../models/prayer_time_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightAppColors.backgroundColor,
      appBar: AppBar(
        leadingWidth: 250,
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
              Flexible(
                child: Text(
                  "Pamekasan, Jawa Timur",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.r),
            child: Icon(
              Icons.dark_mode_outlined,
              color: AppColors.iconColor,
              size: 24.r,
            ),
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
                color: LightAppColors.cardColor,
                elevation: 2,
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
                            Text(
                              "28 April 2025 M",
                              style: TextStyle(fontSize: 14.r),
                            ),
                            Text(
                              "17 : 21",
                              style: TextStyle(
                                fontSize: 48.r,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Magrib kurang dari ",
                                  style: TextStyle(fontSize: 14.r, color: Colors.grey),
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
                        PrayerTimesRow(prayers: prayerTimes,),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

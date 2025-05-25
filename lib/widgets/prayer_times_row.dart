import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/prayer_time_data.dart';

class PrayerTimesRow extends StatelessWidget {
  final List<PrayerTimeData> prayers;
  const PrayerTimesRow({super.key, required this.prayers});


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: prayers.map((prayer) {
        return Column(
          children: [
            Text(
              prayer.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.r,
              ),
            ),
            Icon(
              prayer.icon,
              size: 32.r,
            ),
            Text(
              prayer.time,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.r,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/prayer_time_data.dart';

class PrayerTimesRow extends StatelessWidget {
  final List<PrayerTimeData> prayers;
  final String? currentPrayer;

  const PrayerTimesRow(
      {super.key, required this.prayers, required this.currentPrayer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: prayers.map((prayer) {
        final isActive = currentPrayer != null && prayer.name == currentPrayer;

        return Column(
          children: [
            Text(
              prayer.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.r,
                color: isActive
                    ? Colors.blue
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            Icon(
              prayer.icon,
              size: 32.r,
              color: isActive ? Colors.blue : IconTheme.of(context).color,
            ),
            Text(
              prayer.time,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.r,
                color: isActive
                    ? Colors.blue
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sholat_reminder/models/prayer_time_data.dart';

import '../bloc/prayer_checklist_cubit.dart';

class ChecklistPrayerRow extends StatelessWidget {

  const ChecklistPrayerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerChecklistCubit, List<PrayerTimeData>>(
      builder: (context, prayers) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: prayers.map((prayer) {
            return Column(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<PrayerChecklistCubit>().togglePrayerStatus(prayer.name);
                  },
                  icon: Icon(
                    prayer.isDone
                        ? Icons.check_circle_outline_outlined
                        : Icons.radio_button_unchecked_outlined,
                    size: 24.r,
                    color: prayer.isDone ? Colors.blue : IconTheme
                        .of(context)
                        .color,
                  ),
                ),
                Text(
                  prayer.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.r,
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

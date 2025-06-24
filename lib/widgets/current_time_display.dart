import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sholat_reminder/bloc/bloc.dart';

import '../bloc/state.dart';
import 'next_prayer_info.dart';

class CurrentTimeDisplay extends StatelessWidget {
  const CurrentTimeDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ClockBloc, ClockState>(
          buildWhen: (prev, current) => prev.date != current.date,
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
        NextPrayerInfo(),
      ],
    );
  }
}

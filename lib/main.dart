import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sholat_reminder/pages/home_screen.dart';

import 'bloc/bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ClockBloc clockBloc = ClockBloc();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411.4, 866.2),
      child: BlocProvider(
        create: (_) => clockBloc,
        child: const MaterialApp(
            title: 'Sholat Reminder App',
            debugShowCheckedModeBanner: false,
            home: HomeScreen()
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sholat_reminder/bloc/location_cubit.dart';
import 'package:sholat_reminder/models/prayer_time_cubit.dart';
import 'package:sholat_reminder/models/prayer_time_repository.dart';
import 'package:sholat_reminder/pages/home_screen.dart';

import 'bloc/bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411.4, 866.2),
      child: Builder(
        builder: (context) {
          final ClockBloc clockBloc = ClockBloc();
          final ThemeBloc myTheme = ThemeBloc();
          final prayerTimeCubit = PrayerTimeCubit(PrayerTimeRepository())..loadFromCache();

          return MultiBlocProvider(
            providers: [
              BlocProvider<ThemeBloc>(create: (_) => myTheme),
              BlocProvider<ClockBloc>(create: (_) => clockBloc),
              BlocProvider<PrayerTimeCubit>(create: (_) => prayerTimeCubit),
              BlocProvider<LocationCubit>(
                create: (context) =>
                    LocationCubit(prayerTimeCubit)..getCurrentLocation(),
              ),
            ],
            child: BlocBuilder<ThemeBloc, bool>(
              bloc: myTheme,
              builder: (context, state) {
                return MaterialApp(
                  title: 'Sholat Reminder App',
                  debugShowCheckedModeBanner: false,
                  theme: state ? ThemeData.dark() : ThemeData.light(),
                  home: const HomeScreen(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

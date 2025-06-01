import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sholat_reminder/bloc/location_cubit.dart';
import 'package:sholat_reminder/pages/home_screen.dart';

import 'bloc/bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ClockBloc clockBloc = ClockBloc();
  final ThemeBloc myTheme = ThemeBloc();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(411.4, 866.2),
        child: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeBloc>(create: (context) => myTheme),
              BlocProvider<ClockBloc>(create: (_) => clockBloc),
              BlocProvider<LocationCubit>(
                  create: (_) => LocationCubit()..getCurrentLocation())
            ],
            child: BlocBuilder<ThemeBloc, bool>(
              bloc: myTheme,
              builder: (context, state) {
                return MaterialApp(
                    title: 'Sholat Reminder App',
                    debugShowCheckedModeBanner: false,
                    theme: state ? ThemeData.dark() : ThemeData.light(),
                    home: HomeScreen());
              },
            )));
  }
}

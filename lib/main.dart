import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sholat_reminder/models/prayer_time_cubit.dart';
import 'package:sholat_reminder/models/prayer_time_repository.dart';
import 'package:sholat_reminder/pages/home_screen.dart';
import 'package:sholat_reminder/services/prayer_progress_service.dart';

import 'bloc/bloc.dart';
import 'bloc/location_cubit.dart';
import 'bloc/prayer_checklist_cubit.dart';
import 'models/prayer_time_data.dart';

Future<List<PrayerTimeData>> getInitialPrayerScheduleFromRepository(
    LocationCubit locationCubit, PrayerTimeRepository prayerTimeRepo) async {
  Position? position;

  if (locationCubit.state is! LocationLoaded) {
    await locationCubit.getCurrentLocation();
    if (locationCubit.state is LocationLoaded) {
      position = (locationCubit.state as LocationLoaded).position;
    } else {
      return buildPrayerTimeList({});
    }
  } else {
    position = (locationCubit.state as LocationLoaded).position;
  }

  try {
    final Map<String, String> prayerTimesMap =
    await prayerTimeRepo.fetchPrayerTimes(position.latitude, position.longitude);

    if (prayerTimesMap.isEmpty) {
      return buildPrayerTimeList({});
    }
    return buildPrayerTimeList(prayerTimesMap);
  } catch (e) {
    return buildPrayerTimeList({});
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);

  final prayerProgressService = PrayerProgressService();
  final prayerTimeRepository = PrayerTimeRepository();


  final prayerTimeCubit = PrayerTimeCubit(prayerTimeRepository);

  final locationCubit = LocationCubit(prayerTimeCubit);


  List<PrayerTimeData> initialScheduleForChecklist =
  await getInitialPrayerScheduleFromRepository(locationCubit, prayerTimeRepository);

  final Map<String, String> prayerTimesForClock = initialScheduleForChecklist.fold<Map<String, String>>(
    {},
        (map, prayer) => map..[prayer.name] = prayer.time,
  );


  runApp(MyApp(
    prayerProgressService: prayerProgressService,
    locationCubit: locationCubit,
    initialPrayerScheduleForChecklist: initialScheduleForChecklist,

    prayerTimeCubit: prayerTimeCubit,
    prayerTimesForClock: prayerTimesForClock,
  ));
}

class MyApp extends StatelessWidget {
  final PrayerProgressService prayerProgressService;
  final LocationCubit locationCubit;
  final List<PrayerTimeData> initialPrayerScheduleForChecklist;
  final PrayerTimeCubit prayerTimeCubit;
  final Map<String, String> prayerTimesForClock;

  const MyApp({
    super.key,
    required this.prayerProgressService,
    required this.locationCubit,
    required this.initialPrayerScheduleForChecklist,
    required this.prayerTimeCubit,
    required this.prayerTimesForClock,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411.4, 866.2),
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
          BlocProvider<PrayerTimeCubit>.value(value: prayerTimeCubit),
          BlocProvider<LocationCubit>.value(value: locationCubit),

          BlocProvider<PrayerChecklistCubit>(
            create: (context) => PrayerChecklistCubit(
              progressService: prayerProgressService,
              initialPrayerSchedule: initialPrayerScheduleForChecklist,
            ),
          ),

          BlocProvider<ClockBloc>(
            create: (newContext) {
              final checklistCubitInstance = newContext.read<PrayerChecklistCubit>();
              return ClockBloc(
                checklistCubit: checklistCubitInstance,
                prayerTimes: prayerTimesForClock,
              );
            },
          ),
        ],
        child: BlocBuilder<ThemeBloc, bool>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Sholat Reminder App',
              debugShowCheckedModeBanner: false,
              theme: themeState ? ThemeData.dark() : ThemeData.light(),
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}

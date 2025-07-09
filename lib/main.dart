import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sholat_reminder/utils/logger.dart';

import 'bloc/bloc.dart';
import 'bloc/location_cubit.dart';
import 'bloc/prayer_checklist_cubit.dart';
import 'models/prayer_time_cubit.dart';
import 'models/prayer_time_data.dart';
import 'models/prayer_time_repository.dart';
import 'pages/home_screen.dart';
import 'services/prayer_progress_service.dart';

Future<Map<String, String>> getRawPrayerTimesMap(
  LocationCubit locationCubit,
  PrayerTimeRepository prayerTimeRepo,
) async {
  try {
    if (locationCubit.state is! LocationLoaded) return {};

    final position = (locationCubit.state as LocationLoaded).position;
    return await prayerTimeRepo.fetchPrayerTimes(
        position.latitude, position.longitude);
  } catch (e) {
    logger.e(e);
    return {};
  }
}

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> enableBackgroundMode() async {
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Sholat Reminder aktif",
    notificationText:
        "Aplikasi berjalan di background untuk mengingatkan waktu sholat.",
    notificationImportance: AndroidNotificationImportance.high,
    notificationIcon:
        const AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
  );

  // await FlutterBackground.initialize(androidConfig: androidConfig);
  // await FlutterBackground.enableBackgroundExecution();

  try {
    bool initialized =
        await FlutterBackground.initialize(androidConfig: androidConfig);
    if (initialized) {
      logger.d("FlutterBackground: Initialized successfully.");
      bool enabled = await FlutterBackground.enableBackgroundExecution();
      logger.d("FlutterBackground: Background execution enabled: $enabled");
      if (!enabled) {
        logger.w(
            "FlutterBackground: Failed to enable background execution. Check permissions and logs (adb logcat).");
      }
    } else {
      logger.w("FlutterBackground: Initialization failed.");
    }
  } catch (e) {
    logger.e("FlutterBackground: Error setting up background mode: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();
  await initializeDateFormatting('id', null);

  final prayerProgressService = PrayerProgressService();
  final prayerTimeRepository = PrayerTimeRepository();

  final prayerTimeCubit = PrayerTimeCubit(prayerTimeRepository);
  final locationCubit = LocationCubit(prayerTimeCubit);

  // Ambil lokasi awal
  await locationCubit.getCurrentLocation();

  // Ambil data waktu sholat berdasarkan lokasi
  final rawPrayerTimes =
      await getRawPrayerTimesMap(locationCubit, prayerTimeRepository);

  // Konversi ke model
  final initialScheduleForChecklist = buildPrayerTimeList(rawPrayerTimes);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  enableBackgroundMode();

  runApp(MyApp(
    prayerProgressService: prayerProgressService,
    locationCubit: locationCubit,
    prayerTimeCubit: prayerTimeCubit,
    initialPrayerScheduleForChecklist: initialScheduleForChecklist,
    rawPrayerTimesMap: rawPrayerTimes,
  ));
}

class MyApp extends StatelessWidget {
  final PrayerProgressService prayerProgressService;
  final LocationCubit locationCubit;
  final PrayerTimeCubit prayerTimeCubit;
  final List<PrayerTimeData> initialPrayerScheduleForChecklist;
  final Map<String, String> rawPrayerTimesMap;

  const MyApp({
    super.key,
    required this.prayerProgressService,
    required this.locationCubit,
    required this.prayerTimeCubit,
    required this.initialPrayerScheduleForChecklist,
    required this.rawPrayerTimesMap,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411.4, 866.2),
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeBloc()),
          BlocProvider.value(value: prayerTimeCubit),
          BlocProvider.value(value: locationCubit),
          BlocProvider(
            create: (_) => PrayerChecklistCubit(
              progressService: prayerProgressService,
              initialPrayerSchedule: initialPrayerScheduleForChecklist,
              prayerTimesMap: rawPrayerTimesMap,
            ),
          ),
          BlocProvider(
            create: (context) => ClockBloc(
              checklistCubit: context.read<PrayerChecklistCubit>(),
              prayerTimes: rawPrayerTimesMap,
            ),
          ),
        ],
        child: BlocBuilder<ThemeBloc, bool>(
          builder: (context, isDarkTheme) {
            return MaterialApp(
              title: 'Sholat Reminder App',
              debugShowCheckedModeBanner: false,
              theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}

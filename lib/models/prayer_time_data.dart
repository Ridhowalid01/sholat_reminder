import 'package:flutter/cupertino.dart';

class PrayerTimeData {
  final String name;
  final String time;
  final IconData icon;

  PrayerTimeData({
    required this.name,
    required this.time,
    required this.icon,
  });
}

final List<PrayerTimeData> prayerTimes = [
  PrayerTimeData(name: 'Subuh', time: '04:21', icon: CupertinoIcons.sunrise),
  PrayerTimeData(name: 'Dzuhur', time: '11:34', icon: CupertinoIcons.sun_max),
  PrayerTimeData(name: 'Ashar', time: '14:43', icon: CupertinoIcons.cloud_sun),
  PrayerTimeData(name: 'Maghrib', time: '17:26', icon: CupertinoIcons.sunset),
  PrayerTimeData(name: 'Isya', time: '18:53', icon: CupertinoIcons.moon_stars),
];

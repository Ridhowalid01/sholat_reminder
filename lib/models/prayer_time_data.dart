import 'package:flutter/cupertino.dart';

class PrayerTimeData {
  final String name;
  final String time;
  final IconData icon;
  final bool isDone;

  PrayerTimeData({
    required this.name,
    required this.time,
    required this.icon,
    this.isDone = false,
  });
  PrayerTimeData copyWith({bool? isDone}) {
    return PrayerTimeData(
      name: name,
      time: time,
      icon: icon,
      isDone: isDone ?? this.isDone,
    );
  }
}

List<PrayerTimeData> buildPrayerTimeList(Map<String, String> prayerMap) {
  return [
    PrayerTimeData(name: 'Subuh', time: prayerMap['Subuh'] ?? '-', icon: CupertinoIcons.sunrise),
    PrayerTimeData(name: 'Dzuhur', time: prayerMap['Dzuhur'] ?? '-', icon: CupertinoIcons.sun_max),
    PrayerTimeData(name: 'Ashar', time: prayerMap['Ashar'] ?? '-', icon: CupertinoIcons.cloud_sun),
    PrayerTimeData(name: 'Maghrib', time: prayerMap['Maghrib'] ?? '-', icon: CupertinoIcons.sunset),
    PrayerTimeData(name: 'Isya\'', time: prayerMap['Isya\''] ?? '-', icon: CupertinoIcons.moon_stars),
  ];
}


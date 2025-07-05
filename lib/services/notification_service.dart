import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

Future<void> showPrayerTimeNotification(
    String prayerName, String prayerTime) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'prayer_time_channel_id',
    'Prayer Time Notifications',
    channelDescription: 'Channel for prayer time reminders',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  int notificationId = prayerName.hashCode;

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    'Waktu $prayerName sudah tiba',
    'Jangan lupa sholat $prayerName ya',
    platformChannelSpecifics,
  );
}

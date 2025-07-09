import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Future<void> showPrayerTimeNotification(String prayerName) async {
    final notificationId = prayerName.hashCode;

    await FlutterLocalNotificationsPlugin().show(
      notificationId,
      "Waktu sholat $prayerName sudah tiba",
      "Jangan lupa sholat ya",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Waktu Sholat',
          channelDescription: 'Notifikasi waktu sholat',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
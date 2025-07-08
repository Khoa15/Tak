import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/widgets.dart';

class NotificationService {
  final plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await plugin.initialize(
      initializationSettings,
    );
  }

    Future<void> isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      
      print('Android notifications enabled: $granted');
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS){
      await plugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true
          );

    }else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      
      print("Android notification permission granted: $grantedNotificationPermission");
    }
  }

  Future<void> cancelNotification(int id) async {
    await plugin.cancel(id);
  }

  Future<void> scheduleDailyNotification({
    int id = 0,
    String title = "Tak",
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    final scheduledTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
    final androidDetails = AndroidNotificationDetails(
      'todo_channel',
      'Todo Deadlines',
      channelDescription: 'Notifications for todo deadlines',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    await plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showNotification({
    int id=0,
    String title = "Tak",
    required String body,
  }) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await plugin.show(
      id,
      title,
      body,
      notificationDetails,
      // payload: 'item x'
      );
  }

  Future<void> cancelAllNotifications() async {
    await plugin.cancelAll();
  }

  Future<void> scheduleWeeklyNotification({
    int id = 0,
    String title = "Tak",
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    final scheduledTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
    final androidDetails = AndroidNotificationDetails(
      'todo_channel',
      'Todo Deadlines',
      channelDescription: 'Notifications for todo deadlines',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    await plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }  
}

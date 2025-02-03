import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> initializePlatformNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
    );
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {}

  void selectNotification(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      behaviorSubject.add(payload);
    }
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.max,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      playSound: true,
      ticker: 'ticker',
      color: Colors.deepPurple,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      silent: false,
      vibrationPattern: Int64List.fromList([0, 1000]),
    );

    DarwinNotificationDetails iosNotificationDetails =
        const DarwinNotificationDetails(
      threadIdentifier: "thread1",
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.critical,
      sound: 'alarm',
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosNotificationDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleMedicationNotification({
    required String medicationName,
    required TimeOfDay time,
    required int notificationId,
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'medication_channel',
      'Medication Reminder',
      channelDescription: 'Channel for medication reminders',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      playSound: true,
      ticker: 'ticker',
      color: Colors.deepPurple,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      silent: false,
      vibrationPattern: Int64List.fromList([0, 1000]),
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Calculate the next occurrence of the time today
    final now = DateTime.now();
    final scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    await _localNotifications.zonedSchedule(
      notificationId,
      'Medication Reminder',
      'Time to take your medication: $medicationName',
      tz.TZDateTime.from(scheduleTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int notificationID) async {
    await _localNotifications.cancel(notificationID);
  }

  Future<void> scheduleMedicationNotifications(
    String medicationName,
    List<TimeOfDay> times,
  ) async {
    for (int i = 0; i < times.length; i++) {
      await scheduleMedicationNotification(
        medicationName: medicationName,
        time: times[i],
        notificationId: i,
      );
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

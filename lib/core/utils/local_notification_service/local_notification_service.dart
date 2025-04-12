import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_medicine_tracker/features/medication/services/medication_service.dart';
import 'package:flutter_medicine_tracker/firebase_options.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> initializePlatformNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
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
      onDidReceiveNotificationResponse: (details) {
        handleNotificationTap(details);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> cancelNotification(int notificationID) async {
    await _localNotifications.cancel(notificationID);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotificationRequest() {
    return _localNotifications.pendingNotificationRequests();
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
    required String payload,
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
      actions: [
        const AndroidNotificationAction(
          'TAKEN_ACTION',
          'Taken',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'DISMISS_ACTION',
          'Dismiss',
          cancelNotification: true,
        ),
      ],
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

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
      payload: payload,
    );
  }

  Future<void> handleNotificationTap(NotificationResponse response) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    Map<String, dynamic> payload = jsonDecode(response.payload ?? "{}");
    if (response.actionId == 'TAKEN_ACTION') {
      await MedicationService.updateMedicationStatusInFirestore(
        response.id!,
        payload["medicationName"],
        payload["member"],
        payload["dosageTime"],
        true,
      );
    } else if (response.actionId == 'DISMISS_ACTION') {
      await MedicationService.updateMedicationStatusInFirestore(
        response.id!,
        payload["medicationName"],
        payload["member"],
        payload["dosageTime"],
        false,
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Map<String, dynamic> payload = jsonDecode(response.payload ?? "{}");
  if (response.actionId == 'TAKEN_ACTION') {
    await MedicationService.updateMedicationStatusInFirestore(
      response.id!,
      payload["medicationName"],
      payload["member"],
      payload["dosageTime"],
      true,
    );
  } else if (response.actionId == 'DISMISS_ACTION') {
    await MedicationService.updateMedicationStatusInFirestore(
      response.id!,
      payload["medicationName"],
      payload["member"],
      payload["dosageTime"],
      false,
    );
  }
}

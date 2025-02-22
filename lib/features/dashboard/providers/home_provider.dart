import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/local_notification_service/local_notification_service.dart';
import '../services/home_service.dart';

class HomeProvider with ChangeNotifier {
  final HomeService homeService = HomeService();

  Future<void> loadNotifications() async {
    LocalNotificationService lns = LocalNotificationService();
    lns.initializePlatformNotifications();

    // Step 1: Get all user medications
    QuerySnapshot<Map<String, dynamic>> medList =
        await homeService.getAllUserMedication();

    // Step 2: Get pending notifications
    List<PendingNotificationRequest> pendingNotifications =
        await lns.getPendingNotificationRequest();

    // Store existing notification IDs to avoid duplicates
    Set<int> existingNotificationIds = {
      for (var n in pendingNotifications) n.id
    };

    // Step 3: Loop through medications and schedule missing notifications
    for (var tmp in medList.docs) {
      List<dynamic> dosages = tmp['dosages'] ?? [];

      for (var dosage in dosages) {
        if (dosage.containsKey('notification_id')) {
          int notificationId = dosage['notification_id'];

          // Skip if the notification already exists
          if (existingNotificationIds.contains(notificationId)) continue;

          // Extract medication name & dosage time
          String medicationName = tmp['medication_name'];
          String member = tmp['member'];
          String time = dosage['time'];

          // Schedule the notification
          lns.scheduleMedicationNotification(
            medicationName: medicationName,
            time: _parseTime(time),
            notificationId: notificationId,
            payload: jsonEncode({
              "medicationName": medicationName,
              "member": member,
              "dosageTime": time,
            }),
          );
        }
      }
    }
  }

  TimeOfDay _parseTime(String time) {
    try {
      time = time.trim();

      final format = DateFormat("hh:mm a");
      DateTime dateTime = format.parse(time);

      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getMedication() {
    return homeService.getMedicationStream();
  }
}

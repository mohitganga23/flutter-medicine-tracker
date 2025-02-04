import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/local_notification_service/local_notification_service.dart';

class HomeProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> loadNotifications() async {
    LocalNotificationService lns = LocalNotificationService();
    lns.initializePlatformNotifications();

    final email = auth.currentUser!.email;
    final firestore = FirebaseFirestore.instance;

    // Step 1: Get all user medications
    QuerySnapshot<Map<String, dynamic>> medList = await firestore
        .collection('medications')
        .doc(email)
        .collection('user_medications')
        .get();

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
          String time = dosage['time'];

          // Schedule the notification
          lns.scheduleMedicationNotification(
            medicationName: medicationName,
            time: _parseTime(time),
            notificationId: notificationId,
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
    return FirebaseFirestore.instance
        .collection('medications')
        .doc(auth.currentUser!.email)
        .collection('user_medications')
        .snapshots();
  }
}

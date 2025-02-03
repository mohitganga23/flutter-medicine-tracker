import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/local_notification_service/local_notification_service.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../medication/screens/add_medication.dart';
import '../../widgets/medication_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loadNotification();
  }

  Future<void> loadNotification() async {
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
        await FlutterLocalNotificationsPlugin().pendingNotificationRequests();

    // Store existing notification IDs to avoid duplicates
    Set<int> existingNotificationIds = {
      for (var notif in pendingNotifications) notif.id
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

          // Schedule the notification (Modify scheduling logic as needed)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontSize: 36),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Add Medication"),
        icon: const Icon(Icons.add_outlined, size: 24),
        onPressed: () {
          NavigationHelper.push(context, const AddMedicationForm());
        },
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('medications')
            .doc(auth.currentUser!.email)
            .collection('user_medications')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((document) {
                return MedicationCard(document: document);
              }).toList(),
            );
          } else {
            return const Center(child: Text("No medications available"));
          }
        },
      ),
    );
  }

  Widget medicationCard(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    String medicationName = document['medication_name'];

    List<TimeOfDay> dosages = parseDosages(document['dosage']);

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(width: 0.25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medication',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              medicationName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (dosages.isNotEmpty) ...[
              Wrap(
                spacing: 5,
                children: List.generate(
                  dosages.length,
                  (index) {
                    return Chip(label: Text(dosages[index].format(context)));
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<TimeOfDay> parseDosages(String dosageString) {
    // Remove the brackets and whitespace
    dosageString = dosageString.replaceAll(RegExp(r'[\[\] ]'), '');

    // Split the string into individual time components
    List<String> timeStrings = dosageString.split(',');

    // Convert each time string into a TimeOfDay object
    List<TimeOfDay> dosages = timeStrings.map((timeString) {
      // Extract hours and minutes
      final time = timeString.replaceAll('TimeOfDay(', '').replaceAll(')', '');
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    }).toList();

    return dosages;
  }
}

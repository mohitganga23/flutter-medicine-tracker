import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/core/constants/routes.dart';
import 'package:flutter_medicine_tracker/core/utils/exception_handler/exception_handler.dart';
import 'package:flutter_medicine_tracker/core/utils/ui_helper/dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/local_notification_service/local_notification_service.dart';
import '../../../core/utils/navigation_helper.dart';
import '../providers/medication_provider.dart';

class MedicationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAndScheduleMedication(
      BuildContext ctx,
      String selectedMember,
      String medicationName,
      String attachNote,
      List<TimeOfDay> dosageTiming,
      ) async {
    MedicationProvider medicationProvider = Provider.of<MedicationProvider>(
      ctx,
      listen: false,
    );

    medicationProvider.toggleLoading();

    LocalNotificationService lns = LocalNotificationService();

    try {
      String userEmail = _auth.currentUser!.email.toString();

      // Create Medication document
      DocumentReference medicationRef = await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('user_medications')
          .add({
        'medicationName': medicationName,
        'member': selectedMember,
        'notes': attachNote,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Store dosages in a separate sub collection
      for (var time in dosageTiming) {
        if (!ctx.mounted) return;
        String formattedTime = time.format(ctx);

        // Unique notification ID based on hash
        int notificationId = '${medicationName}_$formattedTime'.hashCode;

        await medicationRef.collection('dosages').add({
          'time': formattedTime,
          'status': 'pending',
          'notificationId': notificationId,
        });

        // Schedule Notification
        lns.scheduleMedicationNotification(
          medicationName: medicationName,
          time: time,
          notificationId: notificationId,
          payload: jsonEncode({
            "medicationName": medicationName,
            "member": selectedMember,
            "dosageTime": formattedTime,
          }),
        );
      }

      // Reset UI State
      if (!ctx.mounted) return;
      medicationProvider.resetProvider();

      DialogHelper.showSuccessDialog(
        context: ctx,
        title: "Medication added successfully.",
        message: "Your medication has been added and scheduled.",
        onPressed: () => NavigationHelper.pushAndRemoveUntilNamed(
          ctx,
          AppRoutes.dashboard,
              (route) => false,
        ),
      );
    } catch (e) {
      ExceptionHandler.onException(ctx, e);
    } finally {
      medicationProvider.toggleLoading();
    }
  }

  static Future<void> updateMedicationStatusInFirestore(
      int notificationId,
      String medicationId,
      String dosageId,
      String dosageTime,
      bool isTaken,
      ) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String userEmail = auth.currentUser!.email!;

      // Step 1: Query all user medications
      QuerySnapshot medicationQuery = await firestore
          .collection('medications')
          .doc(userEmail)
          .collection('user_medications')
          .get();

      for (var medicationDoc in medicationQuery.docs) {
        List<dynamic> dosages = medicationDoc['dosages'] ?? [];

        // Step 2: Find the correct dosage in the array
        for (int i = 0; i < dosages.length; i++) {
          if (dosages[i]['notification_id'] == notificationId) {
            // Step 3: Modify the dosage entry
            dosages[i]['tracked'] ??= [];
            dosages[i]['tracked'].add(
              {
                'dateTime': Timestamp.now(),
                'status': isTaken ? 'taken' : 'missed',
              },
            );

            // Step 4: Update Firestore document with modified dosages array
            await medicationDoc.reference.update({'dosages': dosages});

            print("Medication status updated successfully!");
            return; // Exit once we update the correct dosage
          }
        }
      }

      print("No matching medication found for notificationId: $notificationId");
    } catch (e) {
      print("Error updating medication tracking: $e");
    }
  }

  Future<Map<String, int>> calculateMedicationStats() async {
    try {
      int takenCount = 0;
      int missedCount = 0;

      DateTime today = DateTime.now();

      // Fetch medications for user
      QuerySnapshot medicationQuery = await _firestore
          .collection('medications')
          .doc(_auth.currentUser!.email.toString())
          .collection('user_medications')
          .get();

      for (var medicationDoc in medicationQuery.docs) {
        List<dynamic> dosages = medicationDoc['dosages'] ?? [];
        DateTime createdAt =
        (medicationDoc['created_at'] as Timestamp).toDate();

        for (DateTime date = createdAt;
        date.isBefore(today) || date.isAtSameMomentAs(today);
        date = date.add(Duration(days: 1))) {
          String dateKey = DateFormat('yyyy-MM-dd').format(date);

          for (var dosage in dosages) {
            String time = dosage['time']; // e.g. "11:00 AM"
            int notificationId = dosage['notification_id'];

            // Check if this dosage was tracked
            bool isTaken = dosage['tracked']?.any((entry) =>
            (entry['dateTime'] as Timestamp).toDate().toLocal().day ==
                date.day &&
                (entry['dateTime'] as Timestamp).toDate().toLocal().month ==
                    date.month &&
                (entry['dateTime'] as Timestamp).toDate().toLocal().year ==
                    date.year) ??
                false;

            if (isTaken) {
              takenCount++;
            } else {
              missedCount++;
            }
          }
        }
      }

      return {
        "taken": takenCount,
        "missed": missedCount,
      };
    } catch (e) {
      print("Error calculating medication stats: $e");
      return {};
    }
  }
}
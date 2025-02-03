import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/features/medication/data/providers/medication_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/local_notification_service/local_notification_service.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/utils/ui_helper.dart';
import '../models/medication_model.dart';

class MedicationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAndScheduleMedication(
    BuildContext context,
    String selectedMember,
    String medicationName,
    String attachNote,
    List<TimeOfDay> dosageTiming,
  ) async {
    MedicationProvider medicationProvider = Provider.of<MedicationProvider>(
      context,
      listen: false,
    );

    medicationProvider.toggleLoading();

    LocalNotificationService lns = LocalNotificationService();
    lns.initializePlatformNotifications();

    try {
      List<Dosage> dosages = [];

      for (var time in dosageTiming) {
        final String formattedTime = time.format(context);

        // Generate a unique notification ID for each dosage
        int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
              2147483647,
            );

        // Create Dosage object
        dosages.add(
          Dosage(
            time: formattedTime,
            status: 'pending',
            notificationId: notificationId,
          ),
        );

        // Schedule Notification
        lns.scheduleMedicationNotification(
          medicationName: medicationName,
          time: time,
          notificationId: notificationId,
        );
      }

      // Create Medication object with nested dosages
      Medication medication = Medication(
        member: selectedMember,
        medicationName: medicationName,
        notes: attachNote,
        createdAt: DateTime.now(),
        dosages: dosages,
      );

      // Save the medication and its dosages in Firestore as a single document
      await _firestore
          .collection('medications')
          .doc(_auth.currentUser!.email.toString())
          .collection('user_medications')
          .add(medication.toMap());

      if (!context.mounted) return;
      showCustomSnackBar(
        context,
        'Medication added successfully!',
        Colors.green,
      );

      medicationProvider.resetProvider();

      await Future.delayed(const Duration(seconds: 2));

      if (!context.mounted) return;
      NavigationHelper.pop(context);
    } catch (e) {
      showCustomSnackBar(
        context,
        'Failed to add medication...',
        Colors.red,
      );
    } finally {
      medicationProvider.toggleLoading();
    }
  }
}

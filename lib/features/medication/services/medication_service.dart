import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/core/constants/routes.dart';
import 'package:flutter_medicine_tracker/core/utils/exception_handler/exception_handler.dart';
import 'package:flutter_medicine_tracker/core/utils/ui_helper/dialog.dart';
import 'package:flutter_medicine_tracker/features/medication/models/medication_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

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
      List<Dosage> dosages = [];
      String userEmail = _auth.currentUser!.email.toString();

      // Store dosages in a separate sub collection
      for (var time in dosageTiming) {
        if (!ctx.mounted) return;
        String formattedTime = time.format(ctx);

        // Unique notification ID based on hash
        int notificationId = '${medicationName}_$formattedTime'.hashCode;

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
          payload: jsonEncode({
            "medicationName": medicationName,
            "member": selectedMember,
            "dosageTime": formattedTime,
          }),
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
          .doc(userEmail)
          .collection('user_medications')
          .add(medication.toMap());

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

            debugPrint("Medication status updated successfully!");
            return; // Exit once we update the correct dosage
          }
        }
      }

      debugPrint(
          "No matching medication found for notificationId: $notificationId");
    } catch (e) {
      debugPrint("Error updating medication tracking: $e");
    }
  }

  Future<Map<String, dynamic>> calculateMedicationStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Map<String, Map<String, List<Map<String, dynamic>>>> dateWiseStats = {};
      int totalTaken = 0;
      int totalMissed = 0;

      final DateTime now = DateTime.now();
      final DateTime effectiveStartDate =
          startDate ?? now.subtract(Duration(days: 6));
      final DateTime effectiveEndDate = endDate ?? now;

      QuerySnapshot medicationQuery = await _firestore
          .collection('medications')
          .doc(_auth.currentUser!.email.toString())
          .collection('user_medications')
          .get();

      final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

      for (var medicationDoc in medicationQuery.docs) {
        final String medicationName = medicationDoc['medication_name'];
        final List<dynamic> dosages = medicationDoc['dosages'] ?? [];
        final DateTime createdAt =
            (medicationDoc['created_at'] as Timestamp).toDate();

        DateTime currentDate = effectiveStartDate;
        while (currentDate.isBefore(effectiveEndDate) ||
            currentDate.isAtSameMomentAs(effectiveEndDate)) {
          if (currentDate.isAfter(createdAt) ||
              currentDate.isAtSameMomentAs(createdAt)) {
            String dateKey = dateFormatter.format(currentDate);

            dateWiseStats[dateKey] ??= {};
            dateWiseStats[dateKey]![medicationName] ??= [];

            for (var dosage in dosages) {
              String dosageTime = dosage['time'];
              List<dynamic> trackedEntries = dosage['tracked'] ?? [];

              var trackingEntry = trackedEntries.firstWhereOrNull((entry) {
                DateTime entryDate = (entry['dateTime'] as Timestamp).toDate();
                return dateFormatter.format(entryDate) == dateKey;
              });

              Map<String, dynamic> dosageStatus = {
                'time': dosageTime,
                'status': trackingEntry != null
                    ? trackingEntry['status']
                    : (currentDate.isAfter(createdAt) ? 'missed' : 'pending'),
              };

              if (trackingEntry != null) {
                if (trackingEntry['status'] == 'taken') {
                  totalTaken++;
                } else if (trackingEntry['status'] == 'missed') {
                  totalMissed++;
                } else {
                  totalMissed++;
                }
              } else if (currentDate.isAfter(createdAt)) {
                totalMissed++;
              }

              dateWiseStats[dateKey]![medicationName]!.add(dosageStatus);
            }
          }
          currentDate = currentDate.add(Duration(days: 1));
        }
      }

      return {
        'dateWiseStats': dateWiseStats,
        'summary': {
          'totalTaken': totalTaken,
          'totalMissed': totalMissed,
          'complianceRate': totalTaken + totalMissed > 0
              ? (totalTaken / (totalTaken + totalMissed) * 100)
                  .toStringAsFixed(1)
              : '0.0'
        },
        'dateRange': {
          'start': dateFormatter.format(effectiveStartDate),
          'end': dateFormatter.format(effectiveEndDate),
        }
      };
    } catch (e) {
      debugPrint("Error calculating medication stats: $e");
      return {
        'dateWiseStats': {},
        'summary': {'totalTaken': 0, 'totalMissed': 0, 'complianceRate': '0.0'},
        'dateRange': {'start': '', 'end': ''},
      };
    }
  }

  Future<Map<String, dynamic>> calculateMedicationStats1({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Initialize result structure
      Map<String, Map<String, Map<String, int>>> dateWiseStats = {};
      int totalTaken = 0;
      int totalMissed = 0;

      // Set default date range if not provided (last 7 days)
      final DateTime now = DateTime.now();
      final DateTime effectiveStartDate =
          startDate ?? now.subtract(Duration(days: 6));
      final DateTime effectiveEndDate = endDate ?? now;

      // Fetch medications for user
      QuerySnapshot medicationQuery = await _firestore
          .collection('medications')
          .doc(_auth.currentUser!.email.toString())
          .collection('user_medications')
          .get();

      // Format dates for comparison
      final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

      for (var medicationDoc in medicationQuery.docs) {
        final String medicationName = medicationDoc['medication_name'];
        final List<dynamic> dosages = medicationDoc['dosages'] ?? [];
        final DateTime createdAt =
            (medicationDoc['created_at'] as Timestamp).toDate();

        // Iterate through each day in the date range
        DateTime currentDate = effectiveStartDate;
        while (currentDate.isBefore(effectiveEndDate) ||
            currentDate.isAtSameMomentAs(effectiveEndDate)) {
          if (currentDate.isAfter(createdAt) ||
              currentDate.isAtSameMomentAs(createdAt)) {
            String dateKey = dateFormatter.format(currentDate);

            // Initialize date entry if not exists
            dateWiseStats[dateKey] ??= {};
            dateWiseStats[dateKey]![medicationName] ??= {
              'taken': 0,
              'missed': 0
            };

            for (var dosage in dosages) {
              String dosageTime = dosage['time'];
              List<dynamic> trackedEntries = dosage['tracked'] ?? [];

              // Find tracking entry for this specific date
              var trackingEntry = trackedEntries.firstWhereOrNull((entry) {
                DateTime entryDate = (entry['dateTime'] as Timestamp).toDate();
                return dateFormatter.format(entryDate) == dateKey;
              });

              if (trackingEntry != null) {
                // Medication was tracked on this date
                if (trackingEntry['status'] == 'taken') {
                  dateWiseStats[dateKey]![medicationName]!['taken'] =
                      dateWiseStats[dateKey]![medicationName]!['taken']! + 1;
                  totalTaken++;
                } else {
                  dateWiseStats[dateKey]![medicationName]!['missed'] =
                      dateWiseStats[dateKey]![medicationName]!['missed']! + 1;
                  totalMissed++;
                }
              } else if (currentDate.isAfter(createdAt)) {
                // Medication was scheduled but not tracked (missed)
                dateWiseStats[dateKey]![medicationName]!['missed'] =
                    dateWiseStats[dateKey]![medicationName]!['missed']! + 1;
                totalMissed++;
              }
            }
          }
          currentDate = currentDate.add(Duration(days: 1));
        }
      }

      return {
        'dateWiseStats': dateWiseStats,
        'summary': {
          'totalTaken': totalTaken,
          'totalMissed': totalMissed,
          'complianceRate': totalTaken + totalMissed > 0
              ? (totalTaken / (totalTaken + totalMissed) * 100)
                  .toStringAsFixed(1)
              : '0.0'
        },
        'dateRange': {
          'start': dateFormatter.format(effectiveStartDate),
          'end': dateFormatter.format(effectiveEndDate),
        }
      };
    } catch (e) {
      debugPrint("Error calculating medication stats: $e");
      return {
        'dateWiseStats': {},
        'summary': {'totalTaken': 0, 'totalMissed': 0, 'complianceRate': '0.0'},
        'dateRange': {'start': '', 'end': ''},
      };
    }
  }
}

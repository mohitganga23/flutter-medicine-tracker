import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../../core/utils/navigation_helper.dart';
import '../../../../../core/utils/ui_helper/snackbar.dart';

class MedicationDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;

  const MedicationDetailScreen({super.key, required this.document});

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> deleteMedication() async {
    try {
      // Step 1: Fetch all dosages from the document
      List<dynamic> dosages = widget.document['dosages'] ?? [];

      // Step 2: Cancel all scheduled notifications
      for (var dosage in dosages) {
        if (dosage.containsKey('notification_id')) {
          int notificationId = dosage['notification_id'];
          await FlutterLocalNotificationsPlugin().cancel(notificationId);
        }
      }

      // Step 3: Delete the entire medication document from Firestore
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(auth.currentUser!.email)
          .collection('user_medications')
          .doc(widget.document.id)
          .delete();

      // Step 4: Close the screen and show success message
      if (!mounted) return;
      NavigationHelper.pop(context);
      showCustomSnackBar(
        context,
        '${widget.document['medication_name']} deleted successfully!',
        Colors.green,
      );
    } catch (e) {
      // Step 5: Handle errors
      if (!mounted) return;
      showCustomSnackBar(
        context,
        'Failed to delete medication!',
        Colors.red,
      );
    }
  }

  Future<void> deleteDosage(int index) async {
    List<dynamic> dosages = widget.document['dosages'] ?? [];

    if (index >= 0 && index < dosages.length) {
      // Get the notification ID
      int notificationId = dosages[index]['notification_id'];

      // Step 1: Cancel the scheduled notification
      await FlutterLocalNotificationsPlugin().cancel(notificationId);

      // Step 2: Remove the selected dosage from the list
      dosages.removeAt(index);

      // Step 3: Update Firestore with the modified list
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(auth.currentUser!.email)
          .collection('user_medications')
          .doc(widget.document.id)
          .update({'dosages': dosages});

      // Step 4: Update the UI
      setState(() {});

      // Step 5: Show success message
      if (!mounted) return;
      showCustomSnackBar(
        context,
        'Dosage deleted successfully!',
        Colors.green,
      );

      // Step 6: If no dosages are left, delete the entire medication
      if (dosages.isEmpty) {
        await deleteMedication();
      } else {
        if (mounted) NavigationHelper.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String medicationName = widget.document['medication_name'];
    String notes = widget.document['notes'];
    List<dynamic> dosages = widget.document['dosages'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(medicationName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await deleteMedication();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (notes.isNotEmpty) ...[
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                notes,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Dosages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            dosages.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: dosages.length,
                      itemBuilder: (context, index) {
                        String time = dosages[index]['time'];
                        String status = dosages[index]['status'];

                        return ListTile(
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_outlined,
                                color: Colors.blueGrey,
                                size: 21,
                              ),
                              const SizedBox(width: 3),
                              Text(time),
                            ],
                          ),
                          subtitle: Text('Status: $status'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await deleteDosage(index);

                              // Check if all dosages are deleted
                              if (dosages.length == 1) {
                                await deleteMedication();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  )
                : const Text("No dosages available"),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/navigation_helper.dart';
import '../screens/dashboard_pages/home/medication_details.dart';

class MedicationCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;

  const MedicationCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    String medicationName = document['medication_name'];
    String notes = document['notes'];
    String memberName =
        document.data().containsKey("member") ? document['member'] : "";

    // Fetch the embedded dosage data
    List<dynamic> dosages =
        document.data().containsKey('dosages') ? document['dosages'] : [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: GestureDetector(
        onTap: () {
          NavigationHelper.push(
            context,
            MedicationDetailScreen(document: document),
          );
        },
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(width: 0.25),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medication',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          medicationName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                if (memberName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Member', style: Theme.of(context).textTheme.bodyMedium),
                  Text(memberName,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notes', style: Theme.of(context).textTheme.bodyMedium),
                  Text(notes, style: Theme.of(context).textTheme.bodyLarge),
                ],
                const SizedBox(height: 8),
                Text(
                  'Dosages:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (dosages.isNotEmpty)
                  Wrap(
                    spacing: 5,
                    children: dosages.map((dosage) {
                      String time = dosage['time'];
                      String status = dosage['status'];
                      return Chip(
                        label: Text('$time - $status'),
                      );
                    }).toList(),
                  )
                else
                  const Text("No dosages available"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
